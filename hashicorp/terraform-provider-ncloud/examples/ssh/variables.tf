variable "access_key" { # export TF_VAR_access_key=...
}

variable "secret_key" { # export TF_VAR_secret_key=...
}

variable "region" {
  default = "KR"
}

variable "login_key_name" {
  default = "tf-sshtest-key"
}

variable "server_name" {
  default = "tf-sshtest-vm"
}

variable "server_image_product_code" {
  default = "SPSW0LINUX000032"
}

variable "server_product_code" {
  default = "SPSVRSTAND000004" #SPSVRSTAND000056
}

variable "port_forwarding_external_port" {
  default = "6088"
}

