# Azure Cloud Infrastructure Administration, Monitoring & Backup Automation

A hands-on Microsoft Azure infrastructure project built with **Terraform**, demonstrating cloud provisioning, network security, identity and access management, monitoring, and backup and disaster recovery.

## Project Overview

This project provisions and manages Azure infrastructure using Infrastructure as Code (IaC). It demonstrates practical cloud administration tasks, including deploying a Linux virtual machine, configuring secure network access, monitoring CPU utilization, enabling VM backups, and validating recovery through an alternate VM restore.

## Technology Stack

| Technology | Purpose |
|---|---|
| Microsoft Azure | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| Ubuntu Linux 24.04 | Virtual machine operating system |
| Nginx | Web server and connectivity validation |
| Azure Virtual Network & NSG | Network isolation and traffic control |
| Azure Monitor | CPU monitoring and alerting |
| Managed Identity & Azure RBAC | Secure access to Azure Storage |
| Azure Blob Storage | Private storage container |
| Azure Backup | VM backup and recovery testing |
| Git & GitHub | Version control and project documentation |

## Architecture & Implementation

### 1. Infrastructure Provisioning
- Provisioned an Azure Resource Group, Virtual Network, subnet, and Network Security Group using Terraform.
- Deployed an Ubuntu Linux virtual machine with a static public IP address.
- Configured network interface and subnet security association.

### 2. Network Security
- Configured inbound SSH and HTTP rules with a restricted source IP.
- Used SSH key authentication and disabled SSH password authentication.
- Applied Network Security Group rules to control inbound traffic.

### 3. Web Server Deployment
- Installed and started Nginx on the Linux virtual machine.
- Verified HTTP connectivity through a browser.
- Repeated the web server availability check on the restored VM.

### 4. Identity & Storage Security
- Enabled a system-assigned managed identity for the VM.
- Created a private Azure Blob Storage container.
- Assigned the **Storage Blob Data Contributor** role at container scope.
- Configured the primary storage account to disable shared-key authorization.

### 5. Monitoring & Alerting
- Configured an Azure Monitor metric alert for average CPU utilization above 80%.
- Set a five-minute evaluation window and severity level 2.
- Created an Azure Monitor Action Group with an email receiver.

### 6. Backup & Disaster Recovery
- Configured Azure Recovery Services Vault and a daily VM backup policy.
- Triggered an on-demand backup and verified successful completion.
- Restored a recovery point to a separate virtual machine.
- Verified that the restored VM reached the running state and that Nginx responded over HTTP.

### 7. Terraform Validation
- Formatted and validated the Terraform configuration.
- Reviewed the Terraform execution plan.
- Confirmed that the configuration matched the deployed infrastructure with no pending changes.

## Security Practices

- SSH key-based authentication.
- Restricted inbound network access.
- Managed identity for Azure service access.
- Least-privilege, container-scoped Blob Storage RBAC.
- Shared-key authorization disabled on the primary storage account.
- Terraform state, saved plans, variable files, and private keys excluded through `.gitignore`.

## Repository Structure

```text
terraform-azure-cloudadmin/
├── main.tf
├── .terraform.lock.hcl
├── .gitignore
└── README.md
```

## Validation Commands

Run these commands from the project directory:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Always review the execution plan before applying infrastructure changes.

## Cost Management

Azure resources such as virtual machines, managed disks, public IP addresses, storage, and backup can incur charges. Budget notifications provide alerts but do not automatically stop resources. Review current Azure costs and remove only confirmed temporary test resources when they are no longer needed.

## Skills Demonstrated

**Azure Administration · Terraform · Linux · Networking · NSG · Managed Identity · RBAC · Azure Monitor · Alerting · Backup & Disaster Recovery · Git · Infrastructure as Code**

---

*Built as a practical cloud administration portfolio project.*
