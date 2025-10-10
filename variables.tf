variable "billing_project_id" {
  description = "The ID of the Google Cloud project where the resources will be created."
  type        = string
}

variable "app_region" {
  description = "The region where the Cloud Run job will be deployed."
  type        = string
}

variable "billing_job_name" {
  description = "The name for the Cloud Run job."
  type        = string
}

variable "deletion_protection" {
  description = "Deletion protection setting for this Cloud Run job."
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "The email of the service account to be used by the job. This service account must exist."
  type        = string
  default     = null
}

variable "containers" {
  description = "A map of container definitions for the job. The map key is the container name. See `variables.tf` for the full object specification."
  type = map(object({
    image      = string
    depends_on = optional(list(string))
    command    = optional(list(string))
    args       = optional(list(string))
    env        = optional(map(string))
    env_from_key = optional(map(object({
      secret  = string
      version = string
    })))
    liveness_probe = optional(object({
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      http_get = optional(object({
        http_headers = optional(map(string))
        path         = optional(string)
        port         = optional(number)
      }))
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
    ports = optional(map(object({
      container_port = optional(number)
      name           = optional(string)
    })))
    resources = optional(object({
      limits            = optional(map(string))
      cpu_idle          = optional(bool)
      startup_cpu_boost = optional(bool)
    }))
    startup_probe = optional(object({
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      http_get = optional(object({
        http_headers = optional(map(string))
        path         = optional(string)
        port         = optional(number)
      }))
      tcp_socket = optional(object({
        port = optional(number)
      }))
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
    volume_mounts = optional(map(string))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for c in var.containers : (
        c.resources == null ? true : 0 == length(setsubtract(
          keys(lookup(c.resources, "limits", {})),
          ["cpu", "memory", "nvidia.com/gpu"]
        ))
      )
    ])
    error_message = "Only following resource limits are available: 'cpu', 'memory' and 'nvidia.com/gpu'."
  }
}


variable "iam" {
  description = "IAM bindings for the Cloud Run job in `{ROLE => [MEMBERS]}` format."
  type        = map(list(string))
  default     = {}
}

variable "job_config" {
  description = "Cloud Run Job specific configuration."
  type = object({
    max_retries = optional(number)
    task_count  = optional(number)
    timeout     = optional(string)
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.job_config.timeout == null ? true : endswith(var.job_config.timeout, "s")
    error_message = "Timeout should follow format of number with up to nine fractional digits, ending with 's'. Example: '3.5s'."
  }
}

variable "labels" {
  description = "A map of key/value labels to apply to the Cloud Run Job for cost allocation and grouping (FinOps)."
  type        = map(string)
  default     = {}
}

variable "max_instance_count" {
  description = "The maximum number of instances (tasks) that can run concurrently for this job. Essential for limiting cost."
  type        = number
  default     = 10 # A reasonable default limit
}