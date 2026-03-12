variable "aks_resource_group_name" {
  description = "Name of the Azure resource group containing the AKS cluster"
  type        = string
  default     = "restauranty-lily-bel-rg"
}

variable "keyvault_resource_group_name" {
  description = "Name of the Azure resource group containing the Key Vault"
  type        = string
  default     = "restauranty-lily-rg"
}

variable "location_aks" {
  description = "Azure region for AKS resources"
  type        = string
  default     = "belgiumcentral"
}

variable "location_kv" {
  description = "Azure region for Key Vault resources"
  type        = string
  default     = "westeurope"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "restauranty-lily-aks"
}

variable "keyvault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "RestaurantyLily"
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}
