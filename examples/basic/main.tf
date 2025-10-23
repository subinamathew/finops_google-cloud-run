terraform {
  # Enforce a minimum Terraform core version
  required_version = ">= 1.11.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      # Pin the major version to prevent breaking changes from provider updates
      version = ">= 6.47.0, < 7.0.0" # tftest
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.47.0, < 7.0.0" # tftest
    }
  }
}

variable "project_id" {
  description = "The GCP project ID to deploy to."
  type        = string
  # Example Value - Replace with your own project
  default     = "gcp-project-12345" 
}

variable "region" {
  description = "The region for the Cloud Run Job."
  type        = string
  default     = "us-central1"
}

# 3. Call the Module
module "cloud_run_job_example" {
  source = "../../" 
  
  billing_project_id    = var.project_id
  app_region            = var.region
  billing_job_name      = "finops-cleaner-job"
  service_account_email = "my-job-sa@${var.project_id}.iam.gserviceaccount.com"
  
  labels = {
    env = "dev"
  }

  # Job execution configuration (task_count is required)
  job_config = {
    task_count  = 1
    max_retries = 3
    timeout     = "600s" # 10 minutes
  }

  containers = {
    "billing-manager" = {
      image = "gcr.io/cloudrun/hello" # Use a dummy image for the example
      # Example environment variable
      env = {
        LOG_LEVEL = "INFO"
      }
      # Example resource limits
      resources = {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
  
  # IAM binding to allow a user to invoke the job
  iam = {
    "roles/run.viewer" = [
      "group:gcp-devs@example.com",
    ]
  }
}

# 4. Output values from the module
output "job_id" {
  description = "The full resource ID of the Cloud Run Job."
  value       = module.cloud_run_job_example.job_id
}
