# Cloud Function - TPC-H Data Generators
resource "google_cloudfunctions2_function" "ingestion" {
  for_each = toset(var.tpch_tables)

  name     = "ingestion-${each.key}-${var.target}"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "handler"

    source {
      storage_source {
        bucket = google_storage_bucket.source.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    min_instance_count             = 0
    max_instance_count             = 1
    available_memory               = var.function_memory
    available_cpu                  = var.function_cpu
    timeout_seconds                = var.function_timeout
    service_account_email          = google_service_account.ingestion_function.email
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true

    environment_variables = {
      GCP_PROJECT_ID      = var.project_id
      TARGET              = var.target
      SCALE_FACTOR        = var.scale_factor
      BATCH_SIZE          = var.batch_size
      TPCH_TABLE_NAME     = each.key
      DUCKDB_MEMORY_LIMIT = var.duckdb_memory_limit
      DUCKDB_THREADS      = var.duckdb_threads
    }
  }

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.cloudbuild,
    google_project_service.run,
    google_project_service.artifactregistry,
    google_project_iam_member.cloudbuild_logging,
    google_project_iam_member.cloudbuild_artifact_registry,
    google_project_iam_member.cloudbuild_storage,
    google_project_iam_member.compute_logging,
    google_project_iam_member.compute_artifact_registry,
    google_project_iam_member.compute_storage,
    google_project_iam_member.cloudbuild_builder
  ]
}


