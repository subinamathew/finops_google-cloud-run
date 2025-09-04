# Google Cloud Run v2 Job

This Terraform module provisions a Google Cloud Run v2 Job.

## Usage

Here's a basic example of how to use this module to create a Cloud Run job.

```hcl
module "cloud_run_job" {
  source                = "./"
  billing_project_id    = "your-gcp-project-id"
  app_region            = "us-central1"
  billing_job_name      = "my-billing-job"
  service_account_email = "my-service-account@your-gcp-project-id.iam.gserviceaccount.com"

  containers = {
    "billing-manager" = {
      image = "us-central1-docker.pkg.dev/your-gcp-project-id/your-artifact-repo/my-docker-image:latest"
      env = {
        GCP_PROJECT_ID      = "your-gcp-project-id"
        BIGQUERY_DATASET_ID = "your_dataset_name"
        GCS_BUCKET_NAME     = "your-gcs-bucket-name"
      }
    }
  }
}
```

<!-- BEGIN TFDOC -->
## Requirements

| Name | Version |
|------|---------|
| <a href="https://www.terraform.io">Terraform</a> | >= 1.11.4 |
| <a href="https://registry.terraform.io/providers/hashicorp/google/latest">google</a> | >= 6.47.0, < 7.0.0 |
| <a href="https://registry.terraform.io/providers/hashicorp/google-beta/latest">google-beta</a> | >= 6.47.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a href="https://registry.terraform.io/providers/hashicorp/google-beta/latest">google-beta</a> | >= 6.47.0, < 7.0.0 |

## Resources

| Name | Type |
|------|------|
| google_cloud_run_v2_job.job | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `app_region` | The region where the Cloud Run job will be deployed. | `string` | n/a | yes |
| `billing_job_name` | The name for the Cloud Run job. | `string` | n/a | yes |
| `billing_project_id` | The ID of the Google Cloud project where the resources will be created. | `string` | n/a | yes |
| `containers` | A map of container definitions for the job. The map key is the container name. See `variables.tf` for the full object specification. | `map(object({...}))` | `{}` | no |
| `deletion_protection` | Deletion protection setting for this Cloud Run job. | `bool` | `false` | no |
| `iam` | IAM bindings for the Cloud Run job in `{ROLE => [MEMBERS]}` format. | `map(list(string))` | `{}` | no |
| `job_config` | Cloud Run Job specific configuration. | `object({ max_retries = optional(number), task_count = optional(number), timeout = optional(string) })` | `{}` | no |
| `service_account_email` | The email of the service account to be used by the job. This service account must exist. | `string` | `null` | yes |

## Outputs

| Name | Description |
|------|-------------|
| `job_id` | The fully qualified ID of the Cloud Run job. |

<!-- END TFDOC -->