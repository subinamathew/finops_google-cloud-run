terraform {
  # Enforce a minimum Terraform core version
  required_version = ">= 1.11.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      # Pin the major version to prevent breaking changes from provider updates
      version = ">= 6.47.0, < 7.0.0" # tftest
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.47.0, < 7.0.0" # tftest
    }
  }
}
