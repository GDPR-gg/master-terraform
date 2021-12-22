variable "app_name" {
  default = "mary"
}

variable "provider_token" {}

module "instance" {
  source  = "app.terraform.io/tfe-core-practitioner/instance/cloud"
  version = "0.0.01"

  count  = 4
  token  = "${var.provider_token}"
  region = "nyc"
  image  = "ubuntu-14-04-x64"
  name   = "${var.app_name}"
}

output "instance_ids" {
  value = "${module.instance.ids}"
}
