# variables.tf
variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "location" {
  description = "Azure region to deploy to"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Terraform   = "true"
  }
}

# Frontend configuration
variable "frontend_sku" {
  description = "SKU for frontend VMSS instances"
  type        = string
  default     = "Standard_B2s"
}

variable "frontend_instance_count" {
  description = "Initial number of frontend instances"
  type        = number
  default     = 2
}

variable "frontend_min_instance_count" {
  description = "Minimum number of frontend instances"
  type        = number
  default     = 2
}

variable "frontend_max_instance_count" {
  description = "Maximum number of frontend instances"
  type        = number
  default     = 5
}

# Backend configuration
variable "backend_sku" {
  description = "SKU for backend VMSS instances"
  type        = string
  default     = "Standard_B2s"
}

variable "backend_instance_count" {
  description = "Initial number of backend instances"
  type        = number
  default     = 2
}

variable "backend_min_instance_count" {
  description = "Minimum number of backend instances"
  type        = number
  default     = 2
}

variable "backend_max_instance_count" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 5
}

# Authentication
variable "admin_username" {
  description = "Admin username for VMSS instances"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for VMSS instances"
  type        = string
  sensitive   = true
  default     = null
}

variable "use_ssh_key" {
  description = "Use SSH key for authentication"
  type        = bool
  default     = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}