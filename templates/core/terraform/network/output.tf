output "core_vnet_id" {
  value = azurerm_virtual_network.core.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "azure_firewall_subnet_id" {
  value = azurerm_subnet.azure_firewall.id
}

output "azure_firewall_subnet_address_prefixes" {
  value = azurerm_subnet.azure_firewall.address_prefixes
}

output "app_gw_subnet_id" {
  value = azurerm_subnet.app_gw.id
}

output "app_gw_subnet_address_prefixes" {
  value = azurerm_subnet.app_gw.address_prefixes
}

output "web_app_subnet_id" {
  value = azurerm_subnet.web_app.id
}

output "web_app_subnet_address_prefixes" {
  value = azurerm_subnet.web_app.address_prefixes
}

output "shared_subnet_id" {
  value = azurerm_subnet.shared.id
}

output "shared_subnet_address_prefixes" {
  value = azurerm_subnet.shared.address_prefixes
}

output "private_dns_zone_azurewebsites_id" {
  value = azurerm_private_dns_zone.azurewebsites.id
}

output "private_dns_zone_mysql_id" {
  value = azurerm_private_dns_zone.mysql.id
}

output "resource_processor_subnet_id" {
  value = azurerm_subnet.resource_processor.id
}

output "resource_processor_subnet_address_prefixes" {
  value = azurerm_subnet.resource_processor.address_prefixes
}

output "azure_monitor_dns_zone_id" {
  value = azurerm_private_dns_zone.azure_monitor.id
}

output "azure_monitor_oms_opinsights_dns_zone_id" {
  value = azurerm_private_dns_zone.azure_monitor_oms_opinsights.id
}

output "azure_monitor_ods_opinsights_dns_zone_id" {
  value = azurerm_private_dns_zone.azure_monitor_ods_opinsights.id
}

output "azure_monitor_agentsvc_dns_zone_id" {
  value = azurerm_private_dns_zone.azure_monitor_agentsvc.id
}

output "blob_core_dns_zone_id" {
  value = azurerm_private_dns_zone.blobcore.id
}

output "azurewebsites_dns_zone_id" {
  value = azurerm_private_dns_zone.azurewebsites.id
}

output "static_web_dns_zone_id" {
  value = azurerm_private_dns_zone.static_web.id
}
