resource "google_cloudbuild_trigger" "build" {
  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.website_repo.name
  }

  build {
    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["i"]
    }
    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["run", "build"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/${data.google_project.project.name}/web:v0.0.2", "."]
    }

    source {
      repo_source {
        repo_name = google_sourcerepo_repository.website_repo.name
      }
    }

    artifacts {
      images = ["gcr.io/${data.google_project.project.name}/web:v0.0.2"]
    }
  }
}