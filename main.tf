terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.46.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "dirien"
    token        = "#{TOKEN}"
    workspaces {
      name = "octopus-hackathon"
    }
  }
}



provider "azurerm" {
  subscription_id = "#{Azure.SubscriptionNumber}"
  client_id       = "#{Azure.Client}"
  client_secret   = "#{Azure.Password}"
  tenant_id       = "#{Azure.TenantId}"
  features {}
}
