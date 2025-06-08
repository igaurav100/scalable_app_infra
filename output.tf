# outputs.tf
output "frontend_vmss_id" {
  description = "ID of the frontend VMSS"
  value       = module.frontend_vmss.vmss_id
}

output "backend_vmss_id" {
  description = "ID of the backend VMSS"
  value       = module.backend_vmss.vmss_id
}

output "load_balancer_public_ip" {
  description = "Public IP of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.this.name
}