output "function_urls" {
  description = "Cloud Function URLs"
  value       = { for k, v in google_cloudfunctions2_function.ingestion : k => v.service_config[0].uri }
}

output "bronze_bucket" {
  description = "Bronze bucket name"
  value       = google_storage_bucket.bronze.name
}

output "silver_bucket" {
  description = "Silver bucket name"
  value       = google_storage_bucket.silver.name
}

output "silver_dev_bucket" {
  description = "Silver Dev bucket name"
  value       = google_storage_bucket.silver_dev.name
}

output "gold_bucket" {
  description = "Gold bucket name"
  value       = google_storage_bucket.gold.name
}

output "gold_dev_bucket" {
  description = "Gold Dev bucket name"
  value       = google_storage_bucket.gold_dev.name
}

output "source_bucket" {
  description = "Source bucket name"
  value       = google_storage_bucket.source.name
}

output "reporting_bucket" {
  description = "Reporting bucket name"
  value       = google_storage_bucket.reporting.name
}

output "pubsub_topics" {
  description = "Pub/Sub topic names"
  value       = { for k, v in google_pubsub_topic.tpch_tables : k => v.name }
}

output "bronze_dataset" {
  description = "Bronze BigQuery dataset ID"
  value       = google_bigquery_dataset.bronze.dataset_id
}

output "biglake_connection" {
  description = "BigLake connection ID"
  value       = google_bigquery_connection.biglake.connection_id
}

output "workflow_name" {
  description = "Ingestion workflow name"
  value       = google_workflows_workflow.ingestion.name
}

output "workflow_execute_command" {
  description = "Command to execute the ingestion workflow"
  value       = "gcloud workflows execute ${google_workflows_workflow.ingestion.name} --location=${var.region}"
}

output "reporting_function_url" {
  description = "Reporting Cloud Function URL"
  value       = google_cloudfunctions2_function.reporting.service_config[0].uri
}

# =============================================================================
# Data Masking Outputs
# =============================================================================

output "name_policy_tag" {
  description = "Full resource name of the name policy tag (use in dbt_project.yml vars)"
  value       = google_data_catalog_policy_tag.name.name
}
