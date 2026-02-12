#############################################
# Provider & HCP Remote Backend Configuration
#############################################

terraform {
  cloud {
    organization = "touchedbyfrancisblog"
    workspaces {
      name = "cicd-infra"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}