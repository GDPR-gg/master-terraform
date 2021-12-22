variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  default     = "consul"
}

variable "location" {
  default     = "westus2"
  description = "The location for the AKS deployment"
}

variable "CLIENT_ID" {
  description = "The Client ID (appId) for the Service Principal used for the AKS deployment"
}

variable "CLIENT_SECRET" {
  description = "The Client Secret (password) for the Service Principal used for the AKS deployment"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to install"
  default     = "1.13.5"
}
