output "vm" {
  description = "The created VM as an object with all of it's attributes. This was created using the azurerm_virtual_machine resource."
  value       = azurerm_virtual_machine.instance
}

output "pub_ip" {
  description = "The created Public IP as an object with all of it's attributes. This was created using the azurerm_public_ip resource."
  value       = azurerm_public_ip.pub_ip
}

output "nic" {
  description = "The created NIC as an object with all of it's attributes. This was created using the azurerm_network_interface resource."
  value       = azurerm_network_interface.nic
}