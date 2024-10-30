resource "azapi_update_resource" "deploymentsetting" {
  count = var.is_exported || var.operation_type == "ClusterUpgrade" ? 0 : 1

  type = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2024-04-01"
  body = {
    properties = {
      deploymentMode = "Deploy"
    }
  }
  name      = "default"
  parent_id = azapi_resource.cluster.id

  timeouts {
    create = "24h"
    delete = "60m"
  }

  depends_on = [azapi_resource.validatedeploymentsetting]
}
