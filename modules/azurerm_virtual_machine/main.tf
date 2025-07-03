resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    subnet_id                     = data.azurerm_subnet.subnet.id
    public_ip_address_id          = data.azurerm_public_ip.pip.id
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = data.azurerm_key_vault_secret.username.value
  admin_password                  = data.azurerm_key_vault_secret.password.value
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic.id, ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  custom_data = base64encode(<<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y nginx
  systemctl enable nginx
  systemctl start nginx
  EOF
  )
}
