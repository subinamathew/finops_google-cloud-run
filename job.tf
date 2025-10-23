resource "google_cloud_run_v2_job" "job" {
  provider            = google-beta
  project             = var.billing_project_id
  location            = var.app_region
  name                = var.billing_job_name
  labels              = var.labels
  deletion_protection = var.deletion_protection
  
  # Job-level configuration (e.g., how the job runs)
  template { # 1. Top-level template block (Job Definition)
    
    # Task count (belongs here)
    task_count = var.max_instance_count 

    # -----------------------------------------------------------
    # FIX: Job configuration (max_retries, timeout) needs its 
    # own nested 'template' block if the structure is simplified.
    # We use a dynamic block to skip it if job_config is empty.
    # -----------------------------------------------------------
    dynamic "template" {
      for_each = var.job_config != null ? [var.job_config] : []
      content {
        max_retries = lookup(template.value, "max_retries", null)
        timeout     = lookup(template.value, "timeout", null)
      }
    }
    
    # Execution Template (Configuration for the container)
    template { # 2. Nested template block (Task Template)
      
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
