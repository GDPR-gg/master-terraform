resource "google_cloud_run_service" "website" {
  name     = "website"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/terraforming-with-freeman/web:v0.0.2"
        ports {
          container_port = 3000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "noauth-website" {
  location = google_cloud_run_service.website.location
  project  = google_cloud_run_service.website.project
  service  = google_cloud_run_service.website.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "website_url" {
  value = google_cloud_run_service.website.status[0].url
}