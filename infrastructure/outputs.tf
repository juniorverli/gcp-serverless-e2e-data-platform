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
