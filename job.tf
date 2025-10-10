resource "google_cloud_run_v2_job" "job" {
  provider            = google-beta
  project             = var.billing_project_id
  location            = var.app_region
  name                = var.billing_job_name
  labels              = var.labels
  deletion_protection = var.deletion_protection
  template {
    dynamic "template" {
      for_each = var.job_config != null ? [var.job_config] : []
      content {
        max_retries = lookup(template.value, "max_retries", null)
        timeout     = lookup(template.value, "timeout", null)
      }
    }
    template {
      service_account = var.service_account_email
      task_count      = var.max_instance_count

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

