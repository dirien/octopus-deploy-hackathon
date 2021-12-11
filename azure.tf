locals {
  location = "westeurope"
}

resource "azurerm_resource_group" "octopus-deploy-rg" {
  name     = "octopus-deploy-rg"
  location = local.location
}


resource "azurerm_app_service_plan" "octopus-deploy-asp" {
  name                = "octopus-deploy-asp"
  location            = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name = azurerm_resource_group.octopus-deploy-rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_application_insights" "octopus-deploy-appinsights" {
  name                = "octopus-deploy-appinsights"
  location            = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name = azurerm_resource_group.octopus-deploy-rg.name
  application_type    = "web"

  tags = {
    environment = "octopus-deploy-hackathon"
  }
}

resource "azurerm_log_analytics_workspace" "octopus-deploy-loganalytics" {
  name                = "octopus-deploy-loganalytics"
  location            = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name = azurerm_resource_group.octopus-deploy-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_app_service" "octopus-deploy-as" {
  name                    = "octopus-deploy-as"
  location                = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name     = azurerm_resource_group.octopus-deploy-rg.name
  app_service_plan_id     = azurerm_app_service_plan.octopus-deploy-asp.id
  https_only              = true
  client_affinity_enabled = true
  site_config {
    always_on        = "true"
    linux_fx_version = "DOCKER|dirien/simple-go:latest"

    health_check_path        = "/health"
    ftps_state               = "Disabled"
    php_version              = "7.4"
    python_version           = "3.4"
    dotnet_framework_version = "v4.0"
    http2_enabled            = true
  }
  client_cert_enabled     = false
  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled = true
    http_logs {
      file_system {
        retention_in_days = 4
        retention_in_mb   = 25
      }
    }
  }
  auth_settings {
    enabled = false
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings            = {
    WEBSITES_PORT                         = "8080"
    DOCKER_REGISTRY_SERVER_URL            = "https://index.docker.io/v1/"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.octopus-deploy-appinsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.octopus-deploy-appinsights.connection_string
  }
}