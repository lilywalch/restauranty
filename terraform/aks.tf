resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  dns_prefix = "restaurant-restauranty-lily-daf9c5"

  image_cleaner_enabled        = false
  image_cleaner_interval_hours = 48

  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_B2s"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVLfQcGub8/bFKG3+OWBeiZAxh1+O9JjZOjvNg7w65+JHyc1sZ3xZ9TunX3BMD9165C8KrwYU9pxtNj9ewgF7BzFsu58ffYwuwg1OT7P9TtftV2ePcSiWgkCOw8CAGSQKWZ/pw8C9pwHctMaV8a4/jQD4EAgrQ4cm00HRW+bIx50YDRgLVAIU3C5HOcRqA1AWpBL2p6nzfSIKsAsii35p/MhaZCAfKwAYumaOVg9HKadknrDVMyxSVx2KmWvJHmsySJcfq78j8OBXczJ9+3kvZSUGLytPe9Cu1sSSL9xexurvK8PenVdm303pRqz0VhQP99bq8yqYVDo7jHlwZodB7"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"

    service_cidr = "10.0.0.0/16"
    pod_cidr     = "10.244.0.0/16"
  }

  lifecycle {
    ignore_changes = [
      image_cleaner_enabled,
      image_cleaner_interval_hours,
      api_server_access_profile
    ]
  }
}
