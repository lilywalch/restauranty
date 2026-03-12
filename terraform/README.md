## Infrastructure as Code (Terraform)

To improve reproducibility and maintainability of the cloud infrastructure, Terraform was introduced as an Infrastructure as Code (IaC) tool.

The Restauranty platform runs on **Azure Kubernetes Service (AKS)** and uses additional Azure services such as **Azure Key Vault** for secret management. Initially, these resources were provisioned manually using the Azure CLI during development. Terraform was later introduced to manage the existing infrastructure declaratively.

### Managed Resources

The Terraform configuration currently manages the following Azure resources:

- Azure Resource Group for AKS
- Azure Kubernetes Service (AKS) cluster
- Azure Resource Group for shared services
- Azure Key Vault

Terraform files are located in the `/terraform` directory.

```
terraform/
│
├ providers.tf
├ variables.tf
├ resource_groups.tf
├ aks.tf
├ keyvault.tf
├ outputs.tf
└ .gitignore
```

### Importing Existing Infrastructure

Because the infrastructure already existed before Terraform was introduced, the resources were imported into the Terraform state using the `terraform import` command.

Example imports:

```bash
terraform import azurerm_resource_group.aks_rg \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-bel-rg

terraform import azurerm_kubernetes_cluster.aks \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-bel-rg/providers/Microsoft.ContainerService/managedClusters/restauranty-lily-aks

terraform import azurerm_resource_group.kv_rg \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-rg

terraform import azurerm_key_vault.kv \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-rg/providers/Microsoft.KeyVault/vaults/RestaurantyLily
```

After importing the resources, the Terraform configuration was iteratively aligned with the existing infrastructure using:

```bash
terraform plan
terraform state show <resource>
```

This process ensured that Terraform accurately represents the deployed infrastructure.

### Running Terraform

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Preview infrastructure changes:

```bash
terraform plan
```

### Handling Existing Infrastructure Drift

Since the AKS cluster was originally provisioned outside of Terraform, a small provider-managed drift may still appear during `terraform plan`. Certain AKS configuration fields are controlled internally by Azure and may not perfectly match the Terraform configuration.

To prevent unnecessary updates, Terraform lifecycle rules are used where appropriate.

### Terraform State

Terraform state files are **not committed to the repository**.

The following files are ignored:

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

This prevents sensitive infrastructure metadata from being exposed in the repository.

### Benefits

Using Terraform provides several advantages:

- Infrastructure becomes **version controlled**
- Infrastructure changes can be **reviewed before deployment**
- The environment can be **recreated reliably**
- Configuration drift can be detected using `terraform plan`
- Infrastructure configuration is **documented as code**
