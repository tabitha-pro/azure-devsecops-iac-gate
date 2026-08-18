# 1. Tell Terraform to use Microsoft Azure as our cloud provider
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Define an Azure Resource Group (a container for cloud resources)
resource "azurerm_resource_group" "rg" {
  name     = "rg-devsecops-demo"
  location = "East US"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 3. Define an Azure Storage Account (with INTENTIONAL misconfigurations for our security scanner)
resource "azurerm_storage_account" "sa" {
  name                     = "stdevsecopsdemo001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # SECURITY VULNERABILITIES FOR TESTING:
  # - Outdated TLS version
  # - Allows public access to files
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_0"

tags = { Environment = "Dev" }
}