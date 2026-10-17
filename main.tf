terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }


}

provider "azurerm" {
  features {}
  subscription_id     = "1f76fadb-373d-48e6-b488-499c0e51f579"
  storage_use_azuread = true
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-cloudadmin-terraform"
  location = "South India"

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    Owner       = "Personal"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-cloudadmin"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.10.0.0/16"]

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "snet-cloudadmin-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-cloudadmin-app"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }

}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH-From-My-IP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "122.164.81.19/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP-From-My-IP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "122.164.81.19/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.app.name

}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id

}

resource "azurerm_public_ip" "vm" {
  name                = "pip-cloudadmin-vm"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}


resource "azurerm_network_interface" "vm" {
  name                = "nic-cloudadmin-vm"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-cloudadmin-terraform"
  computer_name       = "cloudadminvm"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_B2ats_v2"
  admin_username      = "azureadmin"

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("C:/Users/yokes/.ssh/terraform-azure-lab.pub")

  }

  os_disk {
    name                 = "osdisk-cloudadmin-vm"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }

}

resource "azurerm_monitor_action_group" "cpu_alert" {
  name                = "ag-cloudadmin-cpu"
  resource_group_name = azurerm_resource_group.lab.name
  short_name          = "cpuAlert"

  email_receiver {
    name                    = "cloudadmin-email"
    email_address           = "yokeshjaya2003@gmail.com"
    use_common_alert_schema = true
  }

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }

}

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "alert-cloudadmin-high-cpu"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]
  description         = "Alert when VM CPU usage exceeds 80 percent."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.cpu_alert.id
  }

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }

}

resource "azurerm_storage_account" "lab" {
  name                            = "stcloudadmin444900"
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = azurerm_resource_group.lab.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  default_to_oauth_authentication = true
  local_user_enabled              = false

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_container" "lab" {
  name                  = "cloudadmin-data"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"

}

resource "azurerm_role_assignment" "vm_blob_contributor" {
  scope                = azurerm_storage_container.lab.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id

}

resource "azurerm_recovery_services_vault" "vm_backup" {
  name                = "rsv-cloudadmin-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "policy-cloudadmin-daily"
  resource_group_name = azurerm_resource_group.lab.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_backup.name

  backup {
    frequency = "Daily"
    time      = "22:00"
  }

  retention_daily {
    count = 7
  }
}


resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = azurerm_resource_group.lab.name
  recovery_vault_name = azurerm_recovery_services_vault.vm_backup.name
  source_vm_id        = azurerm_linux_virtual_machine.vm.id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}


resource "azurerm_storage_account" "restore_staging" {
  name                     = "stcloudrestore271026"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true
  local_user_enabled              = false

  tags = {
    project     = "CloudAdmin-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
    Purpose     = "BackupRestoreStaging"
  }
}
