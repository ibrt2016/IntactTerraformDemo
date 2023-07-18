#---------------------------------------------------------
# Resource Group selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  name = var.resource_group_name
}