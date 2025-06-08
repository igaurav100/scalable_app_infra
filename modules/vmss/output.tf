# modules/vmss/outputs.tf
output "vmss_id" {
  description = "ID of the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "vmss_principal_id" {
  description = "Principal ID of the VMSS"
  value       = try(azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id, null)
}

output "vmss_name" {
  description = "Name of the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}