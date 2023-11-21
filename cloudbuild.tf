locals {
  APP_INSTALLATION_ID = 44252006
}
resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  disable_on_destroy = false
}


// Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  project =  var.project_id
  secret_id = "GITHUB_TOKEN"

   replication {
    user_managed {
      replicas {
        location = var.project_region
      }
    }
  }
 depends_on = [
    google_project_service.secrets_api
 ] 
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
    secret = google_secret_manager_secret.github_token_secret.id
    secret_data = var.github_token # TF_VAR_github_token env var is needed!!!
}

data "google_iam_policy" "serviceagent_secretAccessor" {
    binding {
        role = "roles/secretmanager.secretAccessor"
        members = ["serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
    }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project = google_secret_manager_secret.github_token_secret.project
  secret_id = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.serviceagent_secretAccessor.policy_data
}

// Create the GitHub connection
resource "google_cloudbuildv2_connection" "cloudbuild-github" {
    project = var.project_id
    location = var.project_region
    name = "cloudbuild-github"

    github_config {
        app_installation_id = local.APP_INSTALLATION_ID
        authorizer_credential {
            oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
        }
    }
    depends_on = [google_secret_manager_secret_iam_policy.policy]
}

resource "google_cloudbuildv2_repository" "my-repository" {
  project = var.project_id
  location = var.project_region
  name = "futurae-source"
  parent_connection = google_cloudbuildv2_connection.cloudbuild-github.name
  remote_uri = "https://github.com/pa-vpap/futurae-source.git"
}