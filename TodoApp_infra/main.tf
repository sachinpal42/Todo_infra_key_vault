module "resource_group" {
  source                  = "../modules/azurerm_resource_group"
  resource_group_name     = "todoapp-rg"
  resource_group_location = "east us"
}

module "virtual_network" {
  depends_on               = [module.resource_group]
  source                   = "../modules/azurerm_virtual_network"
  virtual_network_name     = "todoapp-vnet"
  virtual_network_location = "east us"
  resource_group_name      = "todoapp-rg"
  address_space            = ["10.0.0.0/16"]
}

module "frontend_subnet" {
  depends_on           = [module.virtual_network]
  source               = "../modules/azurerm_subnet"
  resource_group_name  = "todoapp-rg"
  virtual_network_name = "todoapp-vnet"
  subnet_name          = "frontend-subnet"
  address_prefixes     = ["10.0.1.0/24"]
}

module "backend_subnet" {
  depends_on           = [module.virtual_network]
  source               = "../modules/azurerm_subnet"
  resource_group_name  = "todoapp-rg"
  virtual_network_name = "todoapp-vnet"
  subnet_name          = "backend-subnet"
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip_frontend" {
  depends_on          = [module.resource_group]
  source              = "../modules/azurerm_public_ip"
  public_ip_name      = "todoapp-frontend-pip"
  resource_group_name = "todoapp-rg"
  location            = "east us"
  allocation_method   = "Static"
}

module "public_ip_backend" {
  depends_on          = [module.resource_group]
  source              = "../modules/azurerm_public_ip"
  public_ip_name      = "todoapp-backend-pip"
  resource_group_name = "todoapp-rg"
  location            = "east us"
  allocation_method   = "Static"
}

module "frontend_vm" {
  depends_on           = [module.frontend_subnet, module.key_vault, module.vm_username, module.vm_password]
  source               = "../modules/azurerm_virtual_machine"
  resource_group_name  = "todoapp-rg"
  location             = "east us"
  vm_name              = "todoapp-frontend-vm"
  vm_size              = "Standard_B1s"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-frontend"
  virtual_network_name = "todoapp-vnet"
  subnet_name          = "frontend-subnet"
  pip_name             = "todoapp-frontend-pip"
}

module "backend_vm" {
  depends_on           = [module.backend_subnet, module.key_vault, module.vm_username, module.vm_password]
  source               = "../modules/azurerm_virtual_machine"
  resource_group_name  = "todoapp-rg"
  location             = "east us"
  vm_name              = "todoapp-backend-vm"
  vm_size              = "Standard_B1s"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-backend"
  virtual_network_name = "todoapp-vnet"
  subnet_name          = "backend-subnet"
  pip_name             = "todoapp-backend-pip"
}

module "sql_server" {
  depends_on          = [module.resource_group, module.key_vault, module.sql_username, module.sql_password]
  source              = "../modules/azurerm_sql_server"
  sql_server_name     = "todoapp-sql-server10"
  resource_group_name = "todoapp-rg"
  location            = "east us"
  key_vault_name      = "todoapp-key"
}

module "sql_database" {
  depends_on          = [module.sql_server, module.key_vault, module.sql_username, module.sql_password]
  source              = "../modules/azurerm_sql_database"
  sql_server_name     = "todoapp-sql-server10"
  sql_database_name   = "todo-db"
  resource_group_name = "todoapp-rg"
}

module "key_vault" {
  source              = "../modules/azurerm_key_vault"
  depends_on          = [module.resource_group]
  key_vault_name      = "todoapp-key"
  location            = "east us"
  resource_group_name = "todoapp-rg"
}

module "vm_username" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "todoapp-key"
  resource_group_name = "todoapp-rg"
  secret_name         = "vm-username"
  secret_value        = "sachin-devops"
}

module "vm_password" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "todoapp-key"
  resource_group_name = "todoapp-rg"
  secret_name         = "vm-password"
  secret_value        = "Sach.bun1012"
}

module "sql_username" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "todoapp-key"
  resource_group_name = "todoapp-rg"
  secret_name         = "sql-username"
  secret_value        = "sachindb-devops"
}

module "sql_password" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "todoapp-key"
  resource_group_name = "todoapp-rg"
  secret_name         = "sql-password"
  secret_value        = "Sach.bun1012"
}