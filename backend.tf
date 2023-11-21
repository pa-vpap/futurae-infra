#declare terraform state bucket
terraform {
  backend "gcs" {
    bucket = "prj-futurae-terraform-state-d51c"
    prefix = "terraform/infra"
  }
}