

/*
resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-test01"
  location            = "${var.location}"
  resource_group_name = "example-resources"
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = "${var.location}"
    failover_priority = 0
  }
}

locals {
  collections = {
    "col1" : {
      "shard_key" : "shard_key",
      "throughput" : 2000
    },
    "col2" : {
      "shard_key" : "shard_key",
      "throughput" : 1000
    },
    "col3" : {
      "shard_key" : "shard_key",
      "throughput" : 1000
    },
  }
}

resource "azurerm_cosmosdb_mongo_database" "test" {
  name                = "cosmogodbtest01"
  resource_group_name = "example-resources"
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_mongo_collection" "test" {
  for_each            = local.collections
  name                = each.key
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_mongo_database.test.name

  shard_key  = each.value["shard_key"]
  throughput = each.value["throughput"]

  lifecycle {
    ignore_changes = [shard_key]
  }
}

*/