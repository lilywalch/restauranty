output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
