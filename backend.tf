#declare terraform state bucket
terraform {
  backend "gcs" {
    bucket = "ABC"
    prefix = "terraform/infra"
  }
}