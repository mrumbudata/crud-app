provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "crud-app" {
  name     = "crud-app-resources"   
  location = "East US"        
}

# Define the Virtual Network
resource "azurerm_virtual_network" "crud-app" {
  name                = "crud-app-vnet"              # Replace with your desired VNet name
  address_space       = ["10.0.0.0/16"]             # Replace with your desired address space
  location            = azurerm_resource_group.crud-app.location
  resource_group_name = azurerm_resource_group.crud-app.name
}

# Define the Subnet for MySQL
resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"             # Replace with your desired subnet name
  resource_group_name  = azurerm_resource_group.crud-app.name
  virtual_network_name = azurerm_virtual_network.crud-app.name
  address_prefixes     = ["10.0.1.0/24"]            # Replace with your desired subnet address prefix
}

# Define the Network Security Group
resource "azurerm_network_security_group" "crud-app" {
  name                = "crud-app-nsg"                # Replace with your desired NSG name
  location            = azurerm_resource_group.crud-app.location
  resource_group_name = azurerm_resource_group.crud-app.name

  # Rule to allow MySQL access
  security_rule {
    name                       = "allow_mysql_access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"  # Port for MySQL
    source_address_prefix      = "10.0.0.0/16"  # Replace with your VNet address range
    destination_address_prefix = "*"
  }

  # Optional: Add more security rules or configurations as needed
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "crud-app" {
  subnet_id                 = azurerm_subnet.mysql.id
  network_security_group_id = azurerm_network_security_group.crud-app.id
}

# Define the Azure Database for MySQL
resource "azurerm_mysql_server" "crud-app" {
  name                = "crud-app-mysql-server"       
  resource_group_name = azurerm_resource_group.crud-app.name
  location            = azurerm_resource_group.crud-app.location
  version             = "8.0"                        
  sku_name            = "B_Gen5_1"                   
  storage_mb          = 5120                         
  backup_retention_days = 7                                           
  ssl_enforcement_enabled = "true"

  administrator_login    = "mysqladmin"                 
  administrator_login_password = "P@ssw0rd1234"          

}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.crud-app.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "crud-app-link"
  resource_group_name   = azurerm_resource_group.crud-app.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.crud-app.id
}

output "mysql_server_hostname" {
  value = azurerm_mysql_server.crud-app.fully_qualified_domain_name
}
