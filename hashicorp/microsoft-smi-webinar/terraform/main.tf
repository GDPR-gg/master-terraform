module "aks" {
  source             = "Azure/aks/azurerm"
  version            = "1.0.0"
  prefix             = "${var.prefix}"
  location           = "${var.location}"
  kubernetes_version = "${var.kubernetes_version}"
  CLIENT_ID          = "${var.CLIENT_ID}"
  CLIENT_SECRET      = "${var.CLIENT_SECRET}"
}

output "cluster_ca_certificate" {
  value = "${module.aks.cluster_ca_certificate}"
}

output "client_certificate" {
  value = "${module.aks.client_certificate}"
}

output "resource_group" {
  value = "${module.aks.node_resource_group}"
}

output "client_key" {
  value = "${module.aks.client_key}"
}

output "host" {
  value = "${module.aks.host}"
}

output "user" {
  value = "${module.aks.username}"
}

output "password" {
  value = "${module.aks.password}"
}
