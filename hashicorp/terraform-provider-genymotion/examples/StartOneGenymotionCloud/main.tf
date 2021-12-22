provider "genymotion" {
}

variable "recipe_uuid" {
  type    = string
  default = "107d757e-463a-4a18-8667-b8dec6e4c87e"
}

resource "genymotion_cloud" "Android70" {
  recipe_uuid     = var.recipe_uuid
  name            = "DeviceConnectedWithAdb"
  adbconnect      = true
  adb_serial_port = "7090"
}

