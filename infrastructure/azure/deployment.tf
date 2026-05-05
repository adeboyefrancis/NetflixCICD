###################################
# Azure Resources for Deployment
###################################

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project_name}-${var.prefix}-RG"
  location = var.location
  tags     = coalesce(var.tags, { Project = var.project_name, Environment = var.environment, Owner = var.owner_name, ManagedBy = var.managed_by })
}