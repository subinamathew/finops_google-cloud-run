resource "google_cloud_run_v2_job_iam_binding" "job_iam" {
  for_each = var.iam
  provider = google-beta
  project  = google_cloud_run_v2_job.job.project
  location = google_cloud_run_v2_job.job.location
  name     = google_cloud_run_v2_job.job.name

  role    = each.key
  members = each.value
}