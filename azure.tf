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

resource "azurerm_application_insights" "appinsights" {
  name                = "octopus-deploy-appinsights"
  location            = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name = azurerm_resource_group.octopus-deploy-rg.name
  application_type    = "web"

  tags = {
    environment = "octopus-deploy-hackathon"
  }
}

resource "azurerm_app_service" "my_app_service_container" {
  name                    = "octopus-deploy-as"
  location                = azurerm_resource_group.octopus-deploy-rg.location
  resource_group_name     = azurerm_resource_group.octopus-deploy-rg.name
  application_type        = "web"
  app_service_plan_id     = azurerm_app_service_plan.octopus-deploy-asp.id
  https_only              = true
  client_affinity_enabled = true
  site_config {
    always_on        = "true"
    linux_fx_version = "DOCKER|docker.io/dirien/simple-go:latest"

    health_check_path = "/health"
  }
}