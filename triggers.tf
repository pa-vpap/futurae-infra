#-----------CI ----------------------- 
 resource "google_cloudbuild_trigger" "futurae-ci-pr" {
  project = var.project_id
  location = var.project_region
  name        = "futurae-ci-pr"
  description = "ci PR futurae"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.futurae-source.id
    pull_request {
      branch = "^main$"
    }
  }
  filename = "cloudbuild.build.yaml"
}


 resource "google_cloudbuild_trigger" "futurae-ci-push" {
  project = var.project_id
  location = var.project_region
  name        = "futurae-ci-push"
  description = "ci push futurae"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.futurae-source.id
    push {
      tag = "^([0-9]+)\\.([0-9]+)\\.([0-9]+)(-rc[0-9]+)?$"
    }
  }
  filename = "cloudbuild.push.yaml"
}