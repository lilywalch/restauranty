resource "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  location            = azurerm_resource_group.kv_rg.location
  resource_group_name = azurerm_resource_group.kv_rg.name
  tenant_id           = var.tenant_id


  sku_name = "standard"

  enable_rbac_authorization = true
}
