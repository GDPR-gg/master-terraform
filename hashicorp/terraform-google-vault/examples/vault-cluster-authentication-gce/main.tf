# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A VAULT CLUSTER IN GOOGLE CLOUD
# This is an example of how to use the vault-cluster module to deploy a private Vault cluster in GCP. A private Vault
# cluster is the recommended approach for production usage. This cluster uses Consul, running in a separate cluster, as
# its High Availability backend.
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATES A SUBNETWORK WITH GOOGLE API ACCESS
# Necessary because the private clusters don't have internet access
# But consul and vault need to make requests to the Google API
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "private_subnet_with_google_api_access" {
  name                     = "${var.vault_cluster_name}-private-subnet-with-google-api-access"
  private_ip_google_access = true
  network                  = var.network_name
  ip_cidr_range            = var.subnet_ip_cidr_range
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A WEB CLIENT THAT AUTHENTICATES TO VAULT USING THE GCE METHOD AND FETCHES A SECRET
# For more details on how the authentication works, check the startup scripts
# ---------------------------------------------------------------------------------------------------------------------

data "google_compute_zones" "available" {
}

# Deploy web client that authenticates to vault
resource "google_compute_instance" "web_client" {
  name         = var.web_client_name
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "g1-small"
  tags         = ["web-client"]

  labels = {
    example_label = "example_value"
  }

  boot_disk {
    initialize_params {
      image = var.vault_source_image
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = data.template_file.startup_script_client.rendered

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet_with_google_api_access.self_link

    access_config {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }
}

data "template_file" "startup_script_client" {
  template = file("${path.module}/startup-script-client.sh")

  vars = {
    consul_cluster_tag_name = var.consul_server_cluster_name
    example_role_name       = "vault-test-role"
    project_id              = var.gcp_project_id
  }
}

# Allowing ingress of port 8080 on web client
resource "google_compute_firewall" "default" {
  name        = "${var.vault_cluster_name}-test-firewall"
  network     = var.network_name
  target_tags = ["web-client"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "vault_cluster" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:hashicorp/terraform-google-vault.git//modules/vault-cluster?ref=v0.0.1"
  source = "../../modules/vault-cluster"

  subnetwork_name = google_compute_subnetwork.private_subnet_with_google_api_access.name

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  cluster_name     = var.vault_cluster_name
  cluster_size     = var.vault_cluster_size
  cluster_tag_name = var.vault_cluster_name
  machine_type     = var.vault_cluster_machine_type

  source_image   = var.vault_source_image
  startup_script = data.template_file.startup_script_vault.rendered

  gcs_bucket_name          = var.vault_cluster_name
  gcs_bucket_location      = var.gcs_bucket_location
  gcs_bucket_storage_class = var.gcs_bucket_class
  gcs_bucket_force_destroy = var.gcs_bucket_force_destroy

  root_volume_disk_size_gb = var.root_volume_disk_size_gb
  root_volume_disk_type    = var.root_volume_disk_type

  # Note that the only way to reach private nodes via SSH is to first SSH into another node that is not private.
  assign_public_ip_addresses = false

  # To enable external access to the Vault Cluster, enter the approved CIDR Blocks or tags below.
  # We enable health checks from the Consul Server cluster to Vault.
  allowed_inbound_cidr_blocks_api = []

  allowed_inbound_tags_api = [var.consul_server_cluster_name]
}

# Render the Startup Script that will run on each Vault Instance on boot. This script will configure and start Vault.
data "template_file" "startup_script_vault" {
  template = file("${path.module}/startup-script-vault.sh")

  vars = {
    consul_cluster_tag_name   = var.consul_server_cluster_name
    vault_cluster_tag_name    = var.vault_cluster_name
    enable_vault_ui           = var.enable_vault_ui ? "--enable-ui" : ""
    example_role_name         = "vault-test-role"
    example_secret            = var.example_secret
    project_id                = var.gcp_project_id
    vault_auth_allowed_zones  = data.google_compute_zones.available.names[0]
    vault_auth_allowed_labels = "example_label:example_value"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER CLUSTER
# Note that we make use of the terraform-google-consul module!
# ---------------------------------------------------------------------------------------------------------------------

module "consul_cluster" {
  source = "git::git@github.com:hashicorp/terraform-google-consul.git//modules/consul-cluster?ref=v0.4.0"

  subnetwork_name  = google_compute_subnetwork.private_subnet_with_google_api_access.name
  gcp_project_id   = var.gcp_project_id
  gcp_region       = var.gcp_region
  cluster_name     = var.consul_server_cluster_name
  cluster_tag_name = var.consul_server_cluster_name
  cluster_size     = var.consul_server_cluster_size

  source_image = var.consul_server_source_image
  machine_type = var.consul_server_machine_type

  startup_script = data.template_file.startup_script_consul.rendered

  # Note that the only way to reach private nodes via SSH is to first SSH into another node that is not private.
  assign_public_ip_addresses = false

  allowed_inbound_tags_dns      = [var.vault_cluster_name]
  allowed_inbound_tags_http_api = [var.vault_cluster_name]
}

# This Startup Script will run at boot to configure and start Consul on the Consul Server cluster nodes.
data "template_file" "startup_script_consul" {
  template = file("${path.module}/startup-script-consul.sh")

  vars = {
    cluster_tag_name = var.consul_server_cluster_name
  }
}
