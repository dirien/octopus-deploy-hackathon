locals {
  location = "westeurope"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = local.location
}
