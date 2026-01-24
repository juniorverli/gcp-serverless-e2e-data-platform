# Service account for Cloud Function
resource "google_service_account" "ingestion_function" {
  account_id   = "ingestion-function-${var.target}"
  display_name = "Ingestion Cloud Function Service Account (${var.target})"
}

# Cloud Function permissions - Pub/Sub Publisher
resource "google_project_iam_member" "function_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.ingestion_function.email}"
}

# Get Pub/Sub service account
data "google_project" "current" {}

locals {
  pubsub_service_account     = "service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  cloudbuild_service_account = "${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

# Pub/Sub permissions - GCS Writer (for subscriptions to write to GCS)
resource "google_project_iam_member" "pubsub_gcs_writer" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${local.pubsub_service_account}"
}

# Pub/Sub permissions - Legacy Bucket Reader (required for GCS subscription)
resource "google_storage_bucket_iam_member" "pubsub_bucket_reader" {
  bucket = google_storage_bucket.bronze.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${local.pubsub_service_account}"
}

# Cloud Build permissions - Logging
resource "google_project_iam_member" "cloudbuild_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.cloudbuild_service_account}"

  depends_on = [google_project_service.cloudbuild]
}

# Cloud Build permissions - Artifact Registry
resource "google_project_iam_member" "cloudbuild_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.cloudbuild_service_account}"

  depends_on = [google_project_service.cloudbuild]
}

# Cloud Build permissions - Storage
resource "google_project_iam_member" "cloudbuild_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${local.cloudbuild_service_account}"

  depends_on = [google_project_service.cloudbuild]
}

# Compute Engine default service account (used by Cloud Functions Gen2 for build)
locals {
  compute_service_account = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# Compute Engine SA - Logging
resource "google_project_iam_member" "compute_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.compute_service_account}"

  depends_on = [google_project_service.cloudfunctions]
}

# Compute Engine SA - Artifact Registry Reader
resource "google_project_iam_member" "compute_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${local.compute_service_account}"

  depends_on = [google_project_service.cloudfunctions]
}

# Compute Engine SA - Storage Object Admin (for build artifacts)
resource "google_project_iam_member" "compute_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${local.compute_service_account}"

  depends_on = [google_project_service.cloudfunctions]
}

# Cloud Build - Builder role
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${local.compute_service_account}"
}
# Cloud Function Invoker - Allow unauthenticated invocations (for testing in dev)
resource "google_cloud_run_service_iam_member" "invoker" {
  for_each = var.target == "dev" ? toset(var.tpch_tables) : []

  project  = var.project_id
  location = var.region
  service  = google_cloudfunctions2_function.ingestion[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Service Account for Workflows
resource "google_service_account" "workflow" {
  account_id   = "ingestion-workflow-${var.target}"
  display_name = "Ingestion Workflow Service Account (${var.target})"
}

# Workflow permissions - Invoke Cloud Functions
resource "google_project_iam_member" "workflow_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Workflow permissions - BigQuery Data Editor (create tables)
resource "google_project_iam_member" "workflow_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Workflow permissions - BigQuery Job User (run queries)
resource "google_project_iam_member" "workflow_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Workflow permissions - Logging
resource "google_project_iam_member" "workflow_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Workflow permissions - Storage Object Viewer (check files in GCS)
resource "google_project_iam_member" "workflow_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Workflow permissions - BigQuery Connection Admin (required for BigLake delegation via API)
resource "google_project_iam_member" "workflow_connection_user" {
  project = var.project_id
  role    = "roles/bigquery.connectionAdmin"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

# Grant BigLake connection access to read from bronze bucket
# Moved from bigquery.tf
resource "google_storage_bucket_iam_member" "biglake_reader" {
  bucket = google_storage_bucket.bronze.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_bigquery_connection.biglake.cloud_resource[0].service_account_id}"

  depends_on = [time_sleep.wait_for_biglake_sa]
}
