resource "azurerm_key_vault" "kv" {
  # One Keyvault across all Guacamole services
  name                     = "kv-guacamole-${var.tre_id}-${var.workspace_id}"
  location                 = data.azurerm_resource_group.ws.location
  resource_group_name      = data.azurerm_resource_group.ws.name
  sku_name                 = "standard"
  purge_protection_enabled = true
  tenant_id                = data.azurerm_client_config.current.tenant_id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "vaultcore" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.ws.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "vaultcorelink" {
  name                  = "vaultcorelink-${local.service_resource_name_suffix}"
  resource_group_name   = data.azurerm_resource_group.ws.name
  private_dns_zone_name = azurerm_private_dns_zone.vaultcore.name
  virtual_network_id    = data.azurerm_virtual_network.ws.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_endpoint" "kvpe" {
  name                = "kvpe-${local.service_resource_name_suffix}"
  location            = data.azurerm_resource_group.ws.location
  resource_group_name = data.azurerm_resource_group.ws.name
  subnet_id           = data.azurerm_subnet.services.id

  lifecycle { ignore_changes = [tags] }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.vaultcore.id]
  }

  private_service_connection {
    name                           = "kvpescv-${local.service_resource_name_suffix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_access_policy" "guacamole" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_app_service.guacamole.identity.0.tenant_id
  object_id    = azurerm_app_service.guacamole.identity.0.principal_id

  secret_permissions = ["Get", "List", ]
}