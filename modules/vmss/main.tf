# modules/vmss/main.tf
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = "${var.prefix}-${var.tier}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.instance_count
  admin_username      = var.admin_username
  admin_password      = var.use_ssh_key ? null : var.admin_password
  disable_password_authentication = var.use_ssh_key

  dynamic "admin_ssh_key" {
    for_each = var.use_ssh_key ? [1] : []
    content {
      username   = var.admin_username
      public_key = file(var.ssh_public_key_path)
    }
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    storage_account_type = var.os_disk_type
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.prefix}-${var.tier}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.lb_backend_pool_ids
      application_gateway_backend_address_pool_ids = var.agw_backend_pool_ids
    }
  }

  custom_data = var.custom_data

  tags = merge(var.tags, { tier = var.tier })
}

resource "azurerm_monitor_autoscale_setting" "this" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "${var.prefix}-${var.tier}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "default"

    capacity {
      default = var.instance_count
      minimum = var.min_instance_count
      maximum = var.max_instance_count
    }

    dynamic "rule" {
      for_each = var.autoscale_rules
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
          time_grain         = rule.value.time_grain
          statistic          = rule.value.statistic
          time_window        = rule.value.time_window
          time_aggregation   = rule.value.time_aggregation
          operator           = rule.value.operator
          threshold          = rule.value.threshold
        }

        scale_action {
          direction = rule.value.scale_direction
          type      = "ChangeCount"
          value     = rule.value.scale_count
          cooldown  = rule.value.cooldown
        }
      }
    }
  }
}