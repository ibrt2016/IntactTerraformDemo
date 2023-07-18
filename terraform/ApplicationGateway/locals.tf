#---------------------------
# Local declarations
#---------------------------
locals {
  frontend_port_name             = "appgw-${var.app_gateway_name}-${local.location}-feport"
  frontend_ip_configuration_name = "appgw-${var.app_gateway_name}-${local.location}-feip"
  gateway_ip_configuration_name  = "appgw-${var.app_gateway_name}-${local.location}-gwipc"

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}