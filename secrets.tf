resource "google_project_service" "secrets_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"  # Service name for Secrets API

  disable_dependent_services = false
}



