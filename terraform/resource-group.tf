resource "azurerm_resource_group" "aks_rg" {
  name     = var.aks_resource_group_name
  location = var.location_aks
}

resource "azurerm_resource_group" "kv_rg" {
  name     = var.keyvault_resource_group_name
  location = var.location_kv
}
