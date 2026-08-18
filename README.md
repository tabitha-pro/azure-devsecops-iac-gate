# Azure DevSecOps IaC Security Gate

Automated DevSecOps CI/CD pipeline enforcing static code analysis and security guardrails for Azure Infrastructure as Code (IaC) using Terraform, GitHub Actions, and Checkov.

---

## Architecture & Project Overview

* **Infrastructure Definition:** Azure resources configured via Terraform (`main.tf`).
* **CI/CD Automation:** GitHub Actions workflow (`devsecops-gate.yml`) executing static analysis on every code `push` and `pull_request` to `main`.
* **Static Code Analysis:** Checkov security scanner enforcing policy controls, flagging misconfigurations, and acting as a deployment security gate.

---

## Technical Implementation & Remediation Details

### Security Controls Enforced
* **Encryption Standards:** Configured `min_tls_version = "TLS1_2"` to enforce modern encryption protocol usage.
* **Network & Storage Hardening:** Configured `public_network_access_enabled = false` and `allow_nested_items_to_be_public = false`.
* **Authentication Hardening:** Explicitly disabled shared key authorization (`shared_access_key_enabled = false`).
* **Data Retention & Recovery:** Configured 7-day retention policies for container and blob soft deletion within `blob_properties`.
* **Policy Suppressions:** Implemented `#checkov:skip=` inline annotations for standard enterprise policies managed by external resources (Key Vault Customer Managed Keys, SAS policies, and VNet Private Endpoints).

### Pipeline Execution Log
1. **Build #1 & #2:** Caught YAML workflow syntax and file duplicate errors during pipeline initialization.
2. **Build #3:** Triggered security gate failure via Checkov due to non-compliant storage account misconfigurations.
3. **Build #4:** Verified zero severity failures after code hardening, passing all pipeline checks in 38 seconds.

---

## File Structure

```text
.
├── .github/
│   └── workflows/
│       └── devsecops-gate.yml
└── main.tf

## Workflow Configuration (devsecops-gate.yml)

name: DevSecOps IaC Security Gate

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  checkov-scan:
    name: Run IaC Security Scans
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Run Checkov Static Analysis
        uses: bridgecrewio/checkov-action@master
        with:
          framework: terraform
          output_format: cli
          soft_fail: false

## Local Verification Commands

# Install Checkov scanner
pip install checkov

# Initialize Terraform workspace
terraform init

# Run local static code scan
checkov -d . --framework terraform

## Pipeline Status

Status: SUCCESS

Branch: main

Scan Duration: 38s
