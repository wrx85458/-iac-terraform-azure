resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "test" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
}

resource "azurerm_app_service_plan" "test" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_function_app" "test" {
  name                      = var.function_app_name
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  app_service_plan_id       = azurerm_app_service_plan.test.id
  storage_account_name      = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_function_app_function" "test" {
  function_app_id = azurerm_function_app.test.id
  name            = "MyFunction"
  config_json     = <<CONFIG
    {
      "bindings": [
        {
          "name": "req",
          "type": "httpTrigger",
          "direction": "in",
          "authLevel": "anonymous"
        },
        {
          "name": "$return",
          "type": "http",
          "direction": "out"
        }
      ]
    }
  CONFIG
}

