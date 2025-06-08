# main.tf
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "${var.prefix}-frontend-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "${var.prefix}-backend-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "lb" {
  name                = "${var.prefix}-lb-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "frontend" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "${var.prefix}-frontend-pool"
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "${var.prefix}-backend-pool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.this.id
  name                = "http-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.frontend.id]
  probe_id                       = azurerm_lb_probe.http.id
}

# Frontend VMSS
module "frontend_vmss" {
  source = "./modules/vmss"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  prefix              = var.prefix
  tier                = "frontend"

  subnet_id           = azurerm_subnet.frontend.id
  lb_backend_pool_ids = [azurerm_lb_backend_address_pool.frontend.id]

  sku            = var.frontend_sku
  instance_count = var.frontend_instance_count
  min_instance_count = var.frontend_min_instance_count
  max_instance_count = var.frontend_max_instance_count

  custom_data = base64encode(templatefile("${path.module}/scripts/frontend-init.sh", {
    backend_address = module.backend_vmss.vmss_name
  }))

  tags = var.tags
}

# Backend VMSS
module "backend_vmss" {
  source = "./modules/vmss"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  prefix              = var.prefix
  tier                = "backend"

  subnet_id           = azurerm_subnet.backend.id
  lb_backend_pool_ids = [azurerm_lb_backend_address_pool.backend.id]

  sku            = var.backend_sku
  instance_count = var.backend_instance_count
  min_instance_count = var.backend_min_instance_count
  max_instance_count = var.backend_max_instance_count

  custom_data = base64encode(file("${path.module}/scripts/backend-init.sh"))

  tags = var.tags
}