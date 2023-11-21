resource "google_storage_bucket" "futurae-bucket" {
  name                        = "${var.project_id}-futurae-bucket"
  project                     = var.project_id
  location                    = var.project_region
  uniform_bucket_level_access = true
}


resource "google_storage_bucket_iam_member" "futurae-bucket_viewer_iam" {
  bucket   = google_storage_bucket.futurae-bucket.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.bucket_enum_sa.email}"
}