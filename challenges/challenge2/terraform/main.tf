# Deploy sample app on Azure App Services in a standalone manner, no database required.

# Configure the AzureRM provider (using v2.1)
provider "azurerm" {
    version         = "~>2.14.0"
    subscription_id = var.subscription_id
    features {}
}

# Provision a resource group to hold all Azure resources
resource "azurerm_resource_group" "rg" {
    name            = "${var.resource_prefix}-RG"
    location        = var.location
}

# Provision the App Service plan to host the App Service web app
resource "azurerm_app_service_plan" "asp" {
    name                = "${var.resource_prefix}-asp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    kind                = "Windows"

    sku {
        tier = "Standard"
        size = "S1"
    }
}

# Provision the Azure App Service to host the main web site
resource "azurerm_app_service" "webapp" {
    name                = "${var.resource_prefix}-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id

    site_config {
        always_on           = true
        default_documents   = [
            "Default.htm",
            "Default.html",
            "hostingstart.html"
        ]
    }

    app_settings = {
        "WEBSITE_NODE_DEFAULT_VERSION"  = "10.15.2"
        "ApiUrl"                        = "/api/v1"
        "ApiUrlShoppingCart"            = "/api/v1"
        "MongoConnectionString"         = ""
        "SqlConnectionString"           = ""
        "productImagesUrl"              = "https://raw.githubusercontent.com/microsoft/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail"
        "Personalizer__ApiKey"          = ""
        "Personalizer__Endpoint"        = ""
    }
}

# Azure SQL

resource “azurerm_storage_account” “storage” {
  name                     = replace(lower(“${var.resource_prefix}-storage”), “-“, “”)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = “Standard”
  account_replication_type = “LRS”
}

resource “azurerm_sql_server” “SQL” {
  name                         = lower(“${var.resource_prefix}-SQL”)
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  version                      = “12.0”
  administrator_login          = “mradministrator”
  administrator_login_password = “thisIsDog11”

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.storage.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.storage.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
}

# Azure Container Instance : MongoDB

resource “azurerm_container_group” “ACI” {
  name                = “${var.resource_prefix}-ACI”
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = “public”
  dns_name_label      = “mongodb”
  os_type             = “Linux”
  
  container {
    name   = “mongodb”
    image  = “mongo:latest”
    cpu    = “0.5”
    memory = “1.5”
    
    ports {
      port     = 27017
      protocol = “TCP”
    }
  }

}

