resource "google_cloud_run_v2_job" "job" {
  provider            = google-beta
  project             = var.billing_project_id
  location            = var.app_region
  name                = var.billing_job_name
  labels              = var.labels
  deletion_protection = var.deletion_protection

  template {
    labels = var.labels
    
    task_count = var.job_config.task_count 

    template { 
      service_account = var.service_account_email 
      max_retries = lookup(var.job_config, "max_retries", null)
      timeout     = lookup(var.job_config, "timeout", null)

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
          
          dynamic "resources" {
            for_each = containers.value.resources == null ? [] : [""]
            content {
              limits = containers.value.resources.limits
            }
          }
        }
      }
    } 
  }
}
