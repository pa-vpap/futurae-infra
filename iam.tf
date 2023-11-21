resource "google_service_account" "bucket_enum_sa" {
  project = var.project_id
  account_id = "bucket-enum-sa"
  display_name = "bucket_enum_sa"
  description = "SA to enum bucket contents"
}