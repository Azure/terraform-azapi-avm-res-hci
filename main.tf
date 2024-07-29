# TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
# resource "azurerm_resource_group" "TODO" {
#   location = var.location
#   name     = var.name # calling code must supply the name
#   tags     = var.tags
# }

resource "azapi_resource" "cluster" {
  type = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  body = {
    properties = {}
  }
  location  = var.resourceGroup.location
  name      = var.clusterName
  parent_id = var.resourceGroup.id

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_role_assignment.ServicePrincipalRoleAssign]

  lifecycle {
    ignore_changes = [
      body.properties,
      identity[0]
    ]
  }
}

# Generate random integer suffix for storage account and key vault
resource "random_integer" "random_suffix" {
  max = 99
  min = 10
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.cluster.id # TODO: Replace with your azurerm resource name
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.cluster.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
