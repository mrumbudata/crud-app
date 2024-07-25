provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "crud-app" {
  name     = "crud-app-resources"
  location = "West Europe"
}

output "resource_group_name" {
  value = azurerm_resource_group.crud-app.name
}
