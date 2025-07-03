data "azurerm_mssql_server" "sql_server" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
    resource_group_name = "todoapp-rg"
    name = "todoapp-key"
}

data "azurerm_key_vault_secret" "sql_username" {
    name = "sql-username"
    key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "sql_password" {
    name = "sql-password"
    key_vault_id = data.azurerm_key_vault.kv.id
}