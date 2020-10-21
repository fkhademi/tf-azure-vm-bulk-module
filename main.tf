resource "azurerm_network_interface" "nic" {
  count = var.num_vms

  name                = "${var.hostname}-nic-${count.index}"
  location            = var.region
  resource_group_name = var.rg

  ip_configuration {
    name                          = "${var.hostname}-nic-${count.index}"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "instance" {
  count = var.num_vms

  name                  = "${var.hostname}-srv-${count.index}"
  location              = var.region
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size               = var.instance_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.hostname}-${count.index}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = "ubuntu"
    admin_password = "Password123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_key
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update > /tmp/apt_update || cat /tmp/apt_update",
      "sudo apt install -y iperf3 > /tmp/apt_install_perf"
    ]
    connection {
      type     = "ssh"
      host     = azurerm_network_interface.nic[count.index].private_ip_address
      user     = "ubuntu"
      password = "Password123"
    }

  }
}

resource "aws_route53_record" "srv" {
  count = var.num_vms

  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = "${var.hostname}${count.index}.${data.aws_route53_zone.domain_name.name}"
  type    = "A"
  ttl     = "1"
  records = [azurerm_network_interface.nic[count.index].private_ip_address]
}