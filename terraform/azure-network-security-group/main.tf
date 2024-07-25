provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "crud-app" {
  name     = "crud-app-resources"   
  location = "West Europe"       
}

resource "azurerm_network_security_group" "crud-app" {
  name                = "crud-app-nsg"                
  location            = azurerm_resource_group.crud-app.location
  resource_group_name = azurerm_resource_group.crud-app.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_mysql_access"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"  # Port for MySQL
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
  
}

# Output the Network Security Group ID
output "nsg_id" {
  value = azurerm_network_security_group.crud-app.id
}
