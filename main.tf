terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 2.26" 
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features{     
  }
}

resource "azurerm_resource_group" "rg-aulainfracloud" {
  name     = "aulainfracloudterraform"
  location = "West Europe"
}

//rede virtual
resource "azurerm_virtual_network" "vnet-aulainfra" {
  name                = "vnet-aula"
  location            = azurerm_resource_group.rg-aulainfracloud.location
  resource_group_name = azurerm_resource_group.rg-aulainfracloud.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
    faculdade = "Impacta"
    turma = "ES23"
  }
}

//rede subnet1
resource "azurerm_subnet" "sub-aulainfra" {
  name                 = "sub-aula"
  resource_group_name  = azurerm_resource_group.rg-aulainfracloud.name
  virtual_network_name = azurerm_virtual_network.vnet-aulainfra.name
  address_prefixes     = ["10.0.1.0/24"]
}

//rede pulica
resource "azurerm_public_ip" "ip-aulainfra" {
  name                = "ip-aula"
  resource_group_name = azurerm_resource_group.rg-aulainfracloud.name
  location            = azurerm_resource_group.rg-aulainfracloud.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

//securitygroup
resource "azurerm_network_security_group" "nsg-aulainfra" {
  name                = "nsg-aula"
  location            = azurerm_resource_group.rg-aulainfracloud.location
  resource_group_name = azurerm_resource_group.rg-aulainfracloud.name

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

  security_rule {
    name                       = "web"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_network_interface" "nic-aulainfra" {
  name                = "nic-aula"
  location            = azurerm_resource_group.rg-aulainfracloud.location
  resource_group_name = azurerm_resource_group.rg-aulainfracloud.name

  ip_configuration {
    name                            = "ip-aula-nic"
    subnet_id                       = azurerm_subnet.sub-aulainfra.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.ip-aulainfra.id
  }
}

//interface com security
resource "azurerm_network_interface_security_group_association" "nic-nsg-aulainfra" {
  network_interface_id      = azurerm_network_interface.nic-aulainfra.id
  network_security_group_id = azurerm_network_security_group.nsg-aulainfra.id
}

//maquinaVirtual
resource "azurerm_virtual_machine" "vm-aulainfra" {
  name                  = "vm-aula"
  location              = azurerm_resource_group.rg-aulainfracloud.location
  resource_group_name   = azurerm_resource_group.rg-aulainfracloud.name
  network_interface_ids = [azurerm_network_interface.nic-aulainfra.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.user
    admin_password = var.pwd_user
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags = {
    environment = "staging"
  }
}

//guardar o ip publico em uma variavel
data "azurerm_public_ip" "ip-aula"{
    name = azurerm_public_ip.ip-aulainfra.name
    resource_group_name = azurerm_resource_group.rg-aulainfracloud.name
}

//conectar na maquina e instalar o apache
resource "null_resource" "install-apache" {
  connection {
    type = "ssh"
    host = data.azurerm_public_ip.ip-aula.ip_address
    user = var.user
    password = var.pwd_user
  }
   provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
    ]
  }

   depends_on = [
    azurerm_virtual_machine.vm-aulainfra
  ]
}