#----------------------------------------------------------
# Resource Group, VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.vnet_resource_group_name == null ? local.resource_group_name : var.vnet_resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

#-----------------------------------
# Public IP for application gateway
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  name                = lower("${var.app_gateway_name}-${local.location}-gw-pip")
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = var.sku.tier == "Standard" ? "Dynamic" : "Static"
  sku                 = var.sku.tier == "Standard" ? "Basic" : "Standard"
  domain_name_label   = var.domain_name_label
  tags                = merge({ "ResourceName" = lower("${var.app_gateway_name}-${local.location}-gw-pip") }, var.tags, )
}