
/*

resource "azurerm_storage_account" "example" {
  name                = "${var.prefix}storageacct"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  access_tier               = "Hot"
  allow_blob_public_access  = true
}

resource "azurerm_storage_container" "example" {
  name                  = "${var.prefix}storagecontainer"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
}

*/