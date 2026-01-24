output "function_urls" {
  description = "Cloud Function URLs"
  value       = { for k, v in google_cloudfunctions2_function.ingestion : k => v.service_config[0].uri }
}

output "bronze_bucket" {
  description = "Bronze bucket name"
  value       = google_storage_bucket.bronze.name
}

output "source_bucket" {
  description = "Source bucket name"
  value       = google_storage_bucket.source.name
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
