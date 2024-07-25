provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "" {
  name     = "umbu-resources"   
  location = "East US"         
}

resource "azurerm_virtual_network" "crud-app" {
  name                = "crud-app-vnet"              
  address_space       = ["10.0.0.0/16"]             
  location            = azurerm_resource_group.crud-app.location
  resource_group_name = azurerm_resource_group.crud-app.name
}


output "vnet_name" {
  value = azurerm_virtual_network.crud-app.name
}

output "subnet_name" {
  value = azurerm_subnet.crud-app.name
}
