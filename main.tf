resource "azurerm_network_interface" "nic" {
  count = var.num_vms

  name                = "${var.name}-nic-${var.count}"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "${var.name}-nic-${var.count}"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "instance" {
  count = var.num_vms

  name                  = "${var.name}-srv-${var.count}"
  location              = var.region
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.instance_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.name}-${var.count}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.name
    admin_username = "ubuntu"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_key
    }
  }
}

resource "aws_route53_record" "srv" {
  count = var.num_vms

  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = "srv${var.count}.${data.aws_route53_zone.domain_name.name}"
  type    = "A"
  ttl     = "1"
  records = [azurerm_network_interface.nic.private_ip_address]
}