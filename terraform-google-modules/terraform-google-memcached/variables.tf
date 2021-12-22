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

variable "project_name" {
  description = "Project Name"
  default     = ""
}

variable "location_code" {
  description = "A code representing a single character for the type of physical location ('g' for Google cloud, 'm' for Marketo datacenters) plus a short string indicating zone or location (e.x. gusw1, guse1, gase1, etc...). This will be used as the first segment of the machine's hostname"
}

variable "rack" {
  description = "The rack designation (either 'a' or 'b') for this component that will be used as the sixth segment of the machine's hostname. If unsure, use 'a'."
}

variable "app_name" {
  description = "The third segment of the machine's hostname, referencing the major application or project name (ex: solr , ... etc)"
}

variable "cluster_id" {
  description = "A four-digit, zero-padded number representing the pod number or cluster number for this component that will be used as the fifth segment of the machine's hostname. If unsure, use '0001'"
}

variable "region" {
  description = "Region to launch instances"
  default     = ""
}

variable "name_prefix" {
  description = "Instance name prefix"
  default     = "memcache-node"
}

variable "host_suffix" {
  description = "Instance host_suffix"
  default     = ""
}

variable "persistent_disk_size" {
  description = "Size (in Gb) of persistent disks to use for d0 and d1 mountpoints"
  default     = "100"
}

variable "zone" {
  description = "Zone to deploy to"
  default     = ""
}

variable "subnetwork" {
  description = "Subnet to deploy to"
  default     = ""
}

variable "env" {
  description = "Environment"
  default     = ""
}

// be layer

variable "layer" {
  default     = "memcache"
  description = "layer var used for ansible host inventory identification"
}

variable "img_src_project" {
  description = "source project where image resides:"
  default     = "centos-cloud"
}

variable "image_name" {
  description = "os base image name"
  default     = ""
}

variable "machine_type" {
  description = "memcache master machine type"
  default     = "n1-standard-2"
}

variable "memcached_ips" {
  description = "A list of static IP addresses for memcached."
  type        = "list"
}

variable "boot_disk_size" {
  description = "disk Size"
  default     = "100"
}

variable "boot_disk_type" {
  description = "boot_disk_type"
  default     = "pd-ssd"
}

variable "extra_tags" {
  description = "Extra tags"
  default     = []
}

variable "service_account" {
  type    = "map"
  default = {}
}

variable "app_tags" {
  description = "Application tags"
  default     = ["all", "health-check"]
}

variable "app_labels" {
  description = "app labels"
  type        = "map"

  default = {
    app = "null"
  }
}

variable "extra_labels" {
  description = "extra labels"
  type        = "map"
  default     = {}
}

variable "allow_stopping_for_update" {
  description = "Whether you will allow Terraform to stop an instance to update it (e.x. service account update)"
  default     = true
}

variable "app_name_tag" {
  description = "name used in constructing logging tags"
  default     = ""
}
