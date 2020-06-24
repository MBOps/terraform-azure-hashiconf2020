variable "resource_prefix" {
  description = "The prefix used for all resources in this example"
  default     = "Azure-Eats"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "northeurope"
}

variable "subscription_id" {
  description = "Azure Subscription ID to be used for billing"
}

variable "mssql_user" {
  description = "Azure Subscription ID to be used for billing"
  default = mssqladmin
}

variable "mssql_password" {
  description = "Azure Subscription ID to be used for billing"
}

variable "mongodb_user" {
  description = "Azure Subscription ID to be used for billing"
  default = mongodbadmin
}

variable "mongodb_password" {
  description = "Azure Subscription ID to be used for billing"
}
