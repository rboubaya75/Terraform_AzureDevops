terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  required_version = ">= 0.15.0"
}
provider "azurerm" {
  features {}
  subscription_id             = $subscription
  client_id                   = $client
  tenant_id                   = $tenant
}
resource "azurerm_resource_group" "main" {
  name     = "example-resources"
  location = "West Europe"
}
resource "azurerm_virtual_network" "main" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}
resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
  count =2
  name                =  "nic${count.index}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          ="internal"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_security_group" "Rachid" {
  count =2
   resource_group_name ="${azurerm_resource_group.main.name}"
   name                      = "${var.prefix}-SG-${count.index}"
   location                  = "${var.location}"
   security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.source_network}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.source_network}"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "Rachid" {
    network_interface_id      = azurerm_network_interface.main[count.index].id
    network_security_group_id = azurerm_network_security_group.Rachid[count.index].id
  count =2 
}

resource "azurerm_public_ip" "internal" {
  name                = "internal"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

}
resource "azurerm_lb" "main" {

    name = "${var.prefix}-lb"

    location = azurerm_resource_group.main.location

    resource_group_name = azurerm_resource_group.main.name

    frontend_ip_configuration {

    name = "PublicIPAddress"

    public_ip_address_id = azurerm_public_ip.internal.id

  }
}
resource "azurerm_lb_backend_address_pool" "main" {

    loadbalancer_id = azurerm_lb.main.id

    name = "BackendAddressPool"

}
resource "azurerm_network_interface_backend_address_pool_association" "main" {

    network_interface_id = azurerm_network_interface.main[count.index].id

    ip_configuration_name = "internal"

    backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
    count = "${var.vmcount}"
}
resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "ssh-running-probe"
  port                = 22
}
resource "azurerm_availability_set" "main" {

    name = "${var.prefix}-vmas"

    location = azurerm_resource_group.main.location

    resource_group_name = azurerm_resource_group.main.name

    tags = {

    mytag = "${var.tag}"
    }

}

//2 VM with temporary public IP


resource "azurerm_linux_virtual_machine" "main" {

    name = "${var.prefix}-vm-${count.index}"

    resource_group_name = azurerm_resource_group.main.name

    location = azurerm_resource_group.main.location

    size = "${var.vm_size}"
     network_interface_ids = [
     azurerm_network_interface.main[count.index].id
  ]

    admin_username = "${var.username}"

    admin_password = "${var.password}"

    count =2

    disable_password_authentication = false

    availability_set_id = azurerm_availability_set.main.id
    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
      }
    source_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    }
// source_image_id = data.azurerm_image.packer.id
}

# VM BASTIONS
resource "azurerm_network_interface" "Rach" {
  
   resource_group_name = "${azurerm_resource_group.main.name}"
   name                      ="${var.prefix}.NI-Bastion"
   location                  = "${var.location}"


  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.Rachid.id}"
  }

}

 resource "azurerm_public_ip" "Rachid" {
    
    resource_group_name = "${azurerm_resource_group.main.name}"
    name                      = "${var.prefix}.publicIP"
    location                  = "${var.location}"
    domain_name_label            = "${var.hostname}"
     allocation_method = "Dynamic"

 }

resource "azurerm_linux_virtual_machine" "Bast" {

    name ="${var.prefix}-VM-Bastion"

    resource_group_name = azurerm_resource_group.main.name

    location = azurerm_resource_group.main.location

    size = "${var.vm_size}"

    admin_username = "${var.username}"

    admin_password = "${var.password}"

    disable_password_authentication = false

    network_interface_ids = [
    azurerm_network_interface.Rach.id,
  ]
    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
      }
    source_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    }
// source_image_id = data.azurerm_image.packer.id
}

#VM for the database:to be configured with ansible
/*
# VM BASTIONS

resource "azurerm_network_interface" "DB" {
  
   resource_group_name = "${azurerm_resource_group.main.name}"
   name                      ="${var.prefix}.NI-DB"
   location                  = "${var.location}"

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.DB.id}"
  }
}

 resource "azurerm_public_ip" "DB" {
    
    resource_group_name = "${azurerm_resource_group.main.name}"
    name                      = "${var.prefix}.DB"
    location                  = "${var.location}"
    domain_name_label            ="databaserac"
     allocation_method = "Dynamic"

 }
resource "azurerm_linux_virtual_machine" "DB" {

    name ="${var.prefix}-VM-DB"

    resource_group_name = azurerm_resource_group.main.name

    location = azurerm_resource_group.main.location

    size = "${var.vm_size}"

    admin_username = "${var.username}"

    admin_password = "${var.password}"
    admin_ssh_key {
    username   = "rachid"
    public_key = file("./id_rsa.pub")
  }

    disable_password_authentication = true

    network_interface_ids = [
    azurerm_network_interface.DB.id,
  ]
    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
      }
    source_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    }
}

*/
