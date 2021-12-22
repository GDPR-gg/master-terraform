/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#############
# Modules
#############

locals {
  memcached_hostname_prefix = "${var.location_code}-${var.env}-${var.app_name}-${format("%04d", var.cluster_id + 0)}"
}

//data "google_compute_zones" "available" {}

data "google_compute_image" "image" {
  project = "${var.img_src_project}"
  name    = "${var.image_name}"
}

resource "google_compute_instance" "memcached" {
  count                     = "${length(var.memcached_ips)}"
  name                      = "${local.memcached_hostname_prefix}-${format("%03d", count.index + 1)}"
  zone                      = "${var.zone}"
  project                   = "${var.project_name}"
  tags                      = "${var.app_tags}"
  machine_type              = "${var.machine_type}"
  allow_stopping_for_update = "${var.allow_stopping_for_update}"

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.image.self_link}"
      size  = "${var.boot_disk_size}"
      type  = "${var.boot_disk_type}"
    }
  }

  network_interface {
    subnetwork    = "${var.subnetwork}"
    address       = "${var.memcached_ips[count.index]}"
    access_config = {}                                  // use this only if you want External ip for you Instance
  }

  metadata_startup_script = "${file("${path.module}/files/init.sh")}"

  labels = {
    environment = "${var.env}"
  }

  service_account {
    email  = "${element(var.service_account["email"],0)}"
    scopes = ["cloud-platform"]
  }
}
