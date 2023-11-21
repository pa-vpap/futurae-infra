#enable project artifacts API
resource "google_project_service" "artifacts_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"  # The service name for Artifacts API

  disable_dependent_services = false
}

#create artifacts registry repo to store application docker artifacts
resource "google_artifact_registry_repository" "future_app_repo" {
  repository_id = "futurae-app"
  location   = var.project_region
  description = "store futurae-app application"
  format = "DOCKER"
}

#provide write access to projct cloudbuild SA
resource "google_artifact_registry_repository_iam_member" "member" {
  project = google_artifact_registry_repository.future_app_repo.project
  location = google_artifact_registry_repository.future_app_repo.location
  repository = google_artifact_registry_repository.future_app_repo.name
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}