resource "azurerm_resource_group" "devlinterraformgroup" {
  name     = "devlin-tf-group"
  location = "eastus"

  tags = {
    environment = "Terraform Demo"
  }
}


resource "azurerm_virtual_network" "devlinterraformnetwork" {
  name                = "devlin-tf-network"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.devlinterraformgroup.name

  tags = {
    environment = "Terraform Demo"
  }
}


resource "azurerm_subnet" "devlinterraformsubnet" {
  name                 = "devlin-tf-subnet"
  resource_group_name  = azurerm_resource_group.devlinterraformgroup.name
  virtual_network_name = azurerm_virtual_network.devlinterraformnetwork.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "devlinterraformpublicip" {
  name                = "devlin-tf-group"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.devlinterraformgroup.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_group" "devlinterraformnsg" {
  name                = "devlin-tf-nsg"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.devlinterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "devlinterraformnic" {
  name                      = "devlin-tf-nic"
  location                  = "eastus"
  resource_group_name       = azurerm_resource_group.devlinterraformgroup.name
  network_security_group_id = azurerm_network_security_group.devlinterraformnsg.id

  ip_configuration {
    name                          = "devlin-tf-nic-configuration"
    subnet_id                     = "${azurerm_subnet.devlinterraformsubnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.devlinterraformpublicip.id}"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.devlinterraformgroup.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "devlinstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.devlinterraformgroup.name
  location                 = "eastus"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine" "devlinterraformvm" {
  name                  = "devlin-vm"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.devlinterraformgroup.name
  network_interface_ids = [azurerm_network_interface.devlinterraformnic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.devlinstorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "Terraform Demo"
  }
}

