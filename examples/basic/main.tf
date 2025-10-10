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


# 2. Define Variables
variable "project_id" {
  description = "The GCP project ID to deploy to."
  type        = string
}

variable "region" {
  description = "The region for the Cloud Run Job."
  type        = string
  default     = "us-central1"
}

# 3. Call the Module
module "cloud_run_job_example" {
  # This references the parent directory, which is your module root
  source = "../../" 
  
  billing_project_id    = var.project_id
  app_region            = var.region
  billing_job_name      = "finops-cleaner-job"
  service_account_email = "my-job-sa@${var.project_id}.iam.gserviceaccount.com"
  
  # FIX: Explicitly setting iam={} removes the TFLint warning in this example context
  iam = {}

  containers = {
    "billing-manager" = {
      image = "gcr.io/cloudrun/hello" # Use a dummy image for the example
      env = {
        LOG_LEVEL = "INFO"
      }
    }
  }
}

# 4. Output values from the module
output "job_id" {
  description = "The full resource ID of the Cloud Run Job."
  value       = module.cloud_run_job_example.job_id
}
