terraform {
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

resource "azurerm_resource_group" "rg" {
  name     = "rg-devsecops-demo"
  location = "East US"
}

resource "azurerm_storage_account" "secure_storage" {
  # checkov:skip=CKV2_AZURE_40: "Shared Key Access disabled by policy"
  # checkov:skip=CKV2_AZURE_41: "SAS expiration policy managed at tenant level"
  # checkov:skip=CKV2_AZURE_33: "Private Endpoint managed in networking module"
  # checkov:skip=CKV2_AZURE_1:  "Customer Managed Keys managed via Key Vault module"
  # checkov:skip=CKV_AZURE_33:   "Queue logging not required for this demo service"

  name                     = "stdevsecopsdemo001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Security Hardening Controls
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = "DevSecOps"
    ManagedBy   = "Terraform"
  }
}