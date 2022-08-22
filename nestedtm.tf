provider "azurerm" {
  subscription_id = "a02af6d0-f088-40bd-a65e-2afd6766b1f4"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  client_id       = "c5e5fb43-b8fb-4e1d-a931-22a2c8fa4d31"
  client_secret   = var.azure_pass
  features {
  }

}

variable azure_pass {
type = string
}
variable srcip {
  type = string
}
resource "azurerm_resource_group" "rg1" {
  name     = "eastusResourcegroup"
  location = "eastus"
}

resource "azurerm_resource_group" "rg2" {
  name     = "WestEuropeResourcegroup"
  location = "westeurope"
}


resource "azurerm_virtual_network" "vnet1" {

  name                = "lab1-vnet"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.1.2.0/24"]
}
resource "azurerm_virtual_network" "vnet2" {

  name                = "lab1-vnet2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  address_space       = ["10.1.1.0/24"]
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = "10.1.2.0/26"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = "10.1.1.0/26"
}
resource "azurerm_network_security_group" "nsg1" {
  name                = "subnetnsg"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
}
resource "azurerm_network_security_rule" "example1" {
  name                        = "test1"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = [ 80,443,3389,22,5985 ]
  source_address_prefix       = "AzureTrafficManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_network_security_rule" "example2" {
  name                        = "test2"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = [ 80,443,3389,22,5985]
  source_address_prefix       = var.srcip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}



resource "azurerm_network_security_group" "nsg2" {
  name                = "subnetnsg"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
}
resource "azurerm_network_security_rule" "example3" {
  name                        = "test1"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = [ 80,443,3389,22,5985 ]
  source_address_prefix       = "AzureTrafficManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg2.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

resource "azurerm_network_security_rule" "example4" {
  name                        = "test2"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = [3389,22,5985,80,443]
  source_address_prefix       = var.srcip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg2.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

resource "random_string" "random" {
  length           = 12
  special          = false
  upper = false
  numeric = false
}

resource "random_string" "random2" {
  length           = 12
  special          = false 
  upper = false
  numeric = false
}

resource "random_string" "random3" {
  length           = 12
  special          = false
  upper = false
  numeric = false
}


locals {
 dnsname  = random_string.random.result
  dnsname2  = random_string.random2.result
dnsname3 = random_string.random3.result
}


resource "azurerm_public_ip" "pip" {
  name                = "linux-pip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  domain_name_label = local.dnsname

}

resource "azurerm_public_ip" "pip2" {
  name                = "win-pip"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Static"
  domain_name_label = local.dnsname2
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "main2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}




resource "azurerm_network_interface" "linuxnic" {
  name                = "linux-nic"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "winnic" {
  name                = "win-nic"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  ip_configuration {
    name                          = "nic-ipconfig"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}

resource "azurerm_virtual_machine" "main2" {

  name                         = "linuxbackend"
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = azurerm_resource_group.rg1.location
  primary_network_interface_id = azurerm_network_interface.linuxnic.id
  network_interface_ids        = [azurerm_network_interface.linuxnic.id]
  vm_size                      = "Standard_DS3_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisklinux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "firewall"
    admin_username = "testadmin"
    admin_password = "P@ssw0rd1234!"

  }
  os_profile_linux_config {
    disable_password_authentication = false
  }


  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "P@ssw0rd1234!"
      host     = azurerm_public_ip.pip.ip_address
    }

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
    ]

  }

}

resource "azurerm_virtual_machine" "main3" {

name = "winbackend"
location = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
network_interface_ids = [azurerm_network_interface.winnic.id]
vm_size = "Standard_DS1_v2"
storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskwin"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "winserver"
    admin_username = "testadmin"
    admin_password = "P@ssw0rd1234!"
  }
  os_profile_windows_config {

 provision_vm_agent        = true

    enable_automatic_upgrades = true


}

}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_virtual_machine.main3.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true
  depends_on = [ azurerm_virtual_machine.main3]

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

}

resource "azurerm_traffic_manager_profile" "tm1" {
  name                   = "tm1"
  resource_group_name    = azurerm_resource_group.rg1.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = local.dnsname
    ttl           = 100
  }


monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
tags = {
    environment = "test"
  }
}


resource "azurerm_traffic_manager_profile" "tm2" {
  name                   = "tm2"
  resource_group_name    = azurerm_resource_group.rg2.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = local.dnsname2
    ttl           = 100
  }


monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
tags = {
    environment = "test"
  }

}


resource "azurerm_traffic_manager_profile" "tm3" {
  name                   = "geotm"
  resource_group_name    = azurerm_resource_group.rg2.name
  traffic_routing_method = "Geographic"
 depends_on = [ azurerm_traffic_manager_profile.tm2, azurerm_traffic_manager_profile.tm1 ]

  dns_config {
    relative_name = local.dnsname3
    ttl           = 100
  }


monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
tags = {
    environment = "test"
  }

}

resource "azurerm_traffic_manager_endpoint" "geolocation1" {
  name               = "ep1"
  depends_on = [ azurerm_traffic_manager_profile.tm3 ]
  resource_group_name    = azurerm_resource_group.rg2.name
  profile_name = azurerm_traffic_manager_profile.tm3.name
  target_resource_id = azurerm_traffic_manager_profile.tm1.id
  type = "nestedEndpoints"
  geo_mappings = ["geo-na" ]
}

resource "azurerm_traffic_manager_endpoint" "geolocation2" {
  name               = "ep2"
  depends_on = [ azurerm_traffic_manager_profile.tm3 ]
  resource_group_name    = azurerm_resource_group.rg2.name
  profile_name = azurerm_traffic_manager_profile.tm3.name
  target_resource_id = azurerm_traffic_manager_profile.tm2.id
  type = "nestedEndpoints"
  geo_mappings = ["geo-eu" ]
}


resource "azurerm_traffic_manager_endpoint" "tm1location1" {
  name               = "ep1"
  resource_group_name    = azurerm_resource_group.rg1.name
  profile_name = azurerm_traffic_manager_profile.tm1.name
  depends_on = [azurerm_traffic_manager_profile.tm1]
  weight             = 100
  target_resource_id = azurerm_public_ip.pip.id
  type = "azureEndpoints"
}

resource "azurerm_traffic_manager_endpoint" "tm1location2" {
  name               = "ep2"
  resource_group_name    = azurerm_resource_group.rg1.name
  profile_name = azurerm_traffic_manager_profile.tm1.name
  depends_on = [azurerm_traffic_manager_endpoint.tm1location1]
  weight             = 101
  target_resource_id = azurerm_public_ip.pip2.id
  type = "azureEndpoints"
}
resource "azurerm_traffic_manager_endpoint" "tm2location1" {
  name               = "ep1"
  profile_name         = azurerm_traffic_manager_profile.tm2.name
  depends_on = [azurerm_traffic_manager_profile.tm2]
   resource_group_name    = azurerm_resource_group.rg2.name
  weight             = 101
  target_resource_id = azurerm_public_ip.pip.id
  type = "azureEndpoints"
}


resource "azurerm_traffic_manager_endpoint" "tm2location2" {
  name               = "ep2"
  profile_name         = azurerm_traffic_manager_profile.tm2.name
  depends_on = [azurerm_traffic_manager_profile.tm2]
  resource_group_name    = azurerm_resource_group.rg2.name
  weight             = 100
  target_resource_id = azurerm_public_ip.pip2.id
 type = "azureEndpoints"
}

