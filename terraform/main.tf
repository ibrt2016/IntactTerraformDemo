resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# module "acr" {
#   source              = "./acr"
#   resource_group_name = azurerm_resource_group.example.name
#   container_registry_config = {
#     name                          = "acr1221"
#     admin_enabled                 = true
#     sku                           = "Premium"
#     public_network_access_enabled = false
#   }


#   tags = {
#     ProjectName  = "demo-internal"
#     Env          = "dev"
#     Owner        = "user@example.com"
#     BusinessUnit = "CORP"
#     ServiceClass = "Gold"
#   }
#   depends_on = [azurerm_resource_group.example]

# }

# module "apgw" {
#   source               = "./ApplicationGateway"
#   resource_group_name  = azurerm_resource_group.example.name
#   location             = azurerm_resource_group.example.location
#   virtual_network_name = "vnet"
#   subnet_name          = "AzureApplicationGateway"
#   app_gateway_name     = "AppGw1221"
#   sku = {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }
#   backend_address_pools = [
#     {
#       name  = "appgw-testgateway-eastus-bapool01"
#       fqdns = ["example1.com", "example2.com"]
#     },
#     {
#       name         = "appgw-testgateway-eastus-bapool02"
#       ip_addresses = ["1.2.3.4", "2.3.4.5"]
#     }
#   ]

#   backend_http_settings = [
#     {
#       name                  = "appgw-testgateway-eastus-be-http-set1"
#       cookie_based_affinity = "Disabled"
#       path                  = "/"
#       enable_https          = false
#       request_timeout       = 30
#       # probe_name            = "appgw-testgateway-westeurope-probe1" # Remove this if `health_probes` object is not defined.
#       connection_draining = {
#         enable_connection_draining = true
#         drain_timeout_sec          = 300

#       }
#     },
#     {
#       name                  = "appgw-testgateway-eastus-be-http-set2"
#       cookie_based_affinity = "Enabled"
#       path                  = "/"
#       enable_https          = false
#       request_timeout       = 30
#     }
#   ]

#   http_listeners = [
#     {
#       name      = "appgw-testgateway-eastus-be-htln01"
#       host_name = null
#     }
#   ]

#   request_routing_rules = [
#     {
#       name                       = "appgw-testgateway-eastus-be-rqrt"
#       rule_type                  = "Basic"
#       http_listener_name         = "appgw-testgateway-eastus-be-htln01"
#       backend_address_pool_name  = "appgw-testgateway-eastus-bapool01"
#       backend_http_settings_name = "appgw-testgateway-eastus-be-http-set1"
#     },
#     {
#       name                       = "appgw-testgateway-eastus-be-rqrt2"
#       rule_type                  = "Basic"
#       http_listener_name         = "appgw-testgateway-eastus-be-htln01"
#       backend_address_pool_name  = "appgw-testgateway-eastus-bapool02"
#       backend_http_settings_name = "appgw-testgateway-eastus-be-http-set2"
#     }
#   ]

#   tags = {
#     ProjectName  = "demo-internal"
#     Env          = "dev"
#     Owner        = "user@example.com"
#     BusinessUnit = "CORP"
#     ServiceClass = "Gold"
#   }
#   depends_on = [azurerm_resource_group.example]

# }
locals {
  user_assigned_identity = toset(var.user_assigned_identity)
}
resource "azurerm_user_assigned_identity" "example" {
  for_each            = local.user_assigned_identity
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  name                = each.key
}

module "sacc" {
  source = "./StorageAccount"

  resource_group_name  = azurerm_resource_group.example.name
  location             = var.location
  storage_account_name = var.storage_account_name

  enable_advanced_threat_protection = true

  containers_list = [
    { name = "mystore250", access_type = "private" },
    { name = "blobstore251", access_type = "blob" },
    { name = "containter252", access_type = "container" }
  ]

  file_shares = [
    { name = "smbfileshare1", quota = 50 },
    { name = "smbfileshare2", quota = 50 }
  ]

  tables = ["table1", "table2", "table3"]
  queues = ["queue1", "queue2"]

  # managed_identity_type = "UserAssigned"
  # managed_identity_ids  = [for k in azurerm_user_assigned_identity.example : k.id]

  lifecycles = [
    {
      prefix_match               = ["mystore250/folder_path1"]
      tier_to_cool_after_days    = 0
      tier_to_archive_after_days = 50
      delete_after_days          = 100
      snapshot_delete_after_days = 30
    },
    {
      prefix_match               = ["blobstore251/another_path"]
      tier_to_cool_after_days    = 0
      tier_to_archive_after_days = 30
      delete_after_days          = 75
      snapshot_delete_after_days = 30
    }
  ]

  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }

  depends_on = [azurerm_resource_group.example]

}

module "app-isnights" {
  source              = "./ApplicationInsights"
  resource_group_name = azurerm_resource_group.example.name
  application_insights_config = {
    mydemoappinsightworkspace = {
      application_type = "web"

    }
  }
  depends_on = [ azurerm_resource_group.example ]
}

module "azmonitor-action-groups" {
  source = "./AzureMonitor/AzMonitor-ActionGroups"

  tags = {
    Application = "Azure Monitor Alerts"
    CostCentre  = "123"
    Environment = "dev"
    ManagedBy   = "Jesse Loudon"
    Owner       = "Jesse Loudon"
    Support     = "coder_au@outlook.com"
  }

  actionGroups = {
    "group1" = {
      actionGroupName      = "AlertEscalationGroup"
      actionGroupShortName = "alertesc"
      actionGroupRGName    = "AzMonitorAlertGroups"
      actionGroupEnabled   = "true"
      actionGroupEmailReceiver = [
        {
          name                    = "jloudon"
          email_address           = "coder_au@outlook.com"
          use_common_alert_schema = "true"
        }
      ]
    },
    "group2" = {
      actionGroupName      = "AlertOperationsGroup"
      actionGroupShortName = "alertops"
      actionGroupRGName    = "AzMonitorAlertGroups"
      actionGroupEnabled   = "true"
      actionGroupEmailReceiver = [
        {
          name                    = "jloudon"
          email_address           = "coder_au@outlook.com"
          use_common_alert_schema = "true"
        }
      ]
    }
  }
}

################
module "azmonitor-metric-alerts" {
  source = "./AzureMonitor/AzMonitor-MetricAlerts"

  tags = {
    Application = "Azure Monitor Alerts"
    CostCentre  = "123"
    Environment = "dev"
    ManagedBy   = "Jesse Loudon"
    Owner       = "Jesse Loudon"
    Support     = "coder_au@outlook.com"
  }

  alertScope = {
    "resource1" = {
      resourceName  = module.sacc.storage_account_name
      resourceGroup = module.sacc.resource_group_name
      resourceType  = "Microsoft.Storage/StorageAccounts"
    }
  }

  metricAlerts = {
    "alert1" = {
      alertName              = "Used_Capacity-Critical"
      alertResourceGroupName = module.sacc.resource_group_name
      alertScopes = [
        module.azmonitor-metric-alerts.alert-scope["0"].resource1.resources[0].id
      ]
      alertDescription            = "The percentage use of a storage account"
      alertEnabled                = "true"
      alertAutoMitigate           = "true"
      alertFrequency              = "PT5M"
      alertWindowSize             = "PT6H"
      alertSeverity               = 0
      alertTargetResourceType     = "Microsoft.Storage/StorageAccounts"
      alertTargetResourceLoc      = module.sacc.resource_group_location
      dynCriteriaMetricNamespace  = "Microsoft.Storage/StorageAccounts"
      dynCriteriaMetricName       = "UsedCapacity"
      dynCriteriaAggregation      = "Average"
      dynCriteriaOperator         = "GreaterThan"
      dynCriteriaThreshold        = 4947802324992
      dynCriteriaAlertSensitivity = "Medium"
      
      actionGroupID = module.azmonitor-action-groups.ag["0"].group1.id
    }
}

#######################

# module "monitor" {
#   source = "./AzureMonitoring"
#   resource_group_name = azurerm_resource_group.example.name
#   location = var.location

#   action_group = {
#     name       = "example-action-group"
#     short_name = "expaag"
#     email_receiver = {
#       email_address           = "ibrt2012@gmail.com"
#       name                    = "monitoring-team"
#       use_common_alert_schema = false
#     }
#     webhook_receiver = {
#       name                    = "ServiceNow"
#       service_uri             = "https://Event_Management_Azure:KSRQYCYkWY4wKm2uSA@tieto.service-now.com/api/global/em/inbound_event?source=AzureLogAnalyticsEvent"
#       use_common_alert_schema = false
#     }
#   }

#   metric_alerts = {
#     "Used_Capacity-Critical" = {
#       description = "The percentage use of a storage account"
#       frequency   = "PT5M"
#       severity    = 0
#       scopes      = [module.sacc.storage_account_id]
#       window_size = "PT6H"
#       criteria = {
#         metric_namespace = "Microsoft.Storage/StorageAccounts"
#         metric_name      = "UsedCapacity"
#         aggregation      = "Average"
#         operator         = "GreaterThan"
#         threshold        = 4947802324992 #Alert will be triggered once it's breach 90% of threshold
#       }
#     },
#   }
# }