resource "google_cloud_run_v2_job" "job" {
  provider            = google-beta
  project             = var.billing_project_id
  location            = var.app_region
  name                = var.billing_job_name
  labels              = var.labels
  deletion_protection = var.deletion_protection
  
  template { # 1. Top-level template block (Job Definition)
    
    # Job-specific configurations that apply to the run behavior
    max_retries     = lookup(var.job_config, "max_retries", null)
    timeout         = lookup(var.job_config, "timeout", null)
    task_count      = var.max_instance_count # <--- CORRECT LOCATION (Moved from inner template)

    template { # 2. Nested template block (Task Template)
      
      # Task-specific configurations
      service_account = var.service_account_email

      dynamic "containers" {
        for_each = var.containers
        content {
          name       = containers.key
          image      = containers.value.image
          depends_on = containers.value.depends_on
          command    = containers.value.command
          args       = containers.value.args
          
          dynamic "env" {
            for_each = coalesce(containers.value.env, tomap({}))
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}
