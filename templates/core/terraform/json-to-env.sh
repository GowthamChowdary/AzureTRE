#!/bin/bash
set -e

echo "# Generated environment variables from tf output"

jq -r '
    [
        {
            "path": "core_resource_group_name",
            "env_var": "RESOURCE_GROUP_NAME"
        },
        {
            "path": "core_resource_group_location",
            "env_var": "RESOURCE_LOCATION"
        },
        {
            "path": "app_gateway_name",
            "env_var": "APPLICATION_GATEWAY"
        },
        {
            "path": "static_web_storage",
            "env_var": "STORAGE_ACCOUNT"
        },
        {
            "path": "keyvault_name",
            "env_var": "KEYVAULT"
        },
        {
            "path": "azure_tre_fqdn",
            "env_var": "FQDN"
        },
        {
            "path": "service_bus_resource_id",
            "env_var": "SERVICE_BUS_RESOURCE_ID"
        },
        {
            "path": "service_bus_workspace_queue",
            "env_var": "SERVICE_BUS_RESOURCE_REQUEST_QUEUE"
        },
        {
            "path": "service_bus_deployment_status_queue",
            "env_var": "SERVICE_BUS_DEPLOYMENT_STATUS_UPDATE_QUEUE"
        },
        {
            "path": "state_store_resource_id",
            "env_var": "STATE_STORE_RESOURCE_ID"
        },
        {
            "path": "state_store_account_name",
            "env_var": "COSMOSDB_ACCOUNT_NAME"
        },
        {
            "path": "state_store_endpoint",
            "env_var": "STATE_STORE_ENDPOINT"
        },
        {
            "path": "app_insights_instrumentation_key",
            "env_var": "APPINSIGHTS_INSTRUMENTATIONKEY"
        },
        {
            "path": "app_insights_connection_string",
            "env_var": "APPLICATIONINSIGHTS_CONNECTION_STRING"
        }
    ]
        as $env_vars_to_extract
    |
    with_entries(
        select (
            .key as $a
            |
            any( $env_vars_to_extract[]; .path == $a)
        )
        |
        .key |= . as $old_key | ($env_vars_to_extract[] | select (.path == $old_key) | .env_var)
    )
    |
    to_entries
    |
    map("\(.key)=\"\(.value.value)\"")
    |
    .[]
    ' | sed "s/\"/'/g" # replace double quote with single quote to handle special chars
