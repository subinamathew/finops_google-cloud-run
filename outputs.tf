output "job_id" {
  description = "The fully qualified ID of the Cloud Run job."
  value       = google_cloud_run_v2_job.job.id
}
