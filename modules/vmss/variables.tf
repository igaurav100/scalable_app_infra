# modules/vmss/variables.tf
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tier" {
  description = "Application tier (frontend, backend, etc.)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "SKU for VMSS instances"
  type        = string
  default     = "Standard_B2s"
}

variable "instance_count" {
  description = "Initial number of instances"
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "Subnet ID for instances"
  type        = string
}

variable "lb_backend_pool_ids" {
  description = "Load balancer backend pool IDs"
  type        = list(string)
  default     = []
}

variable "agw_backend_pool_ids" {
  description = "Application Gateway backend pool IDs"
  type        = list(string)
  default     = []
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "latest"
}

variable "os_disk_type" {
  description = "OS disk type"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "enable_autoscaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = true
}

variable "min_instance_count" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_instance_count" {
  description = "Maximum number of instances"
  type        = number
  default     = 5
}

variable "autoscale_rules" {
  description = "Autoscaling rules"
  type = list(object({
    metric_name       = string
    time_grain       = string
    statistic        = string
    time_window      = string
    time_aggregation = string
    operator         = string
    threshold        = number
    scale_direction  = string
    scale_count      = string
    cooldown         = string
  }))
  default = [
    {
      metric_name       = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "GreaterThan"
      threshold        = 70
      scale_direction  = "Increase"
      scale_count      = "1"
      cooldown         = "PT1M"
    },
    {
      metric_name       = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "LessThan"
      threshold        = 30
      scale_direction  = "Decrease"
      scale_count      = "1"
      cooldown         = "PT1M"
    }
  ]
}

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

variable "custom_data" {
  description = "Custom data to pass to VMs"
  type        = string
  default     = null
}