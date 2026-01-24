# Pub/Sub topics - one per TPC-H table
resource "google_pubsub_topic" "tpch_tables" {
  for_each = toset(var.tpch_tables)

  name = "ingestion-tpch-${each.key}-${var.target}"

  depends_on = [google_project_service.pubsub]
}

# Pub/Sub subscriptions - write to GCS in AVRO format
resource "google_pubsub_subscription" "tpch_to_gcs" {
  for_each = toset(var.tpch_tables)

  name  = "ingestion-tpch-${each.key}-${var.target}"
  topic = google_pubsub_topic.tpch_tables[each.key].id

  cloud_storage_config {
    bucket          = google_storage_bucket.bronze.name
    filename_prefix = "${each.key}/"
    filename_suffix = ".avro"

    avro_config {
      write_metadata = true
    }

    max_bytes    = var.pubsub_max_bytes
    max_duration = var.pubsub_max_duration
  }

  ack_deadline_seconds       = 600
  message_retention_duration = "${var.pubsub_retention_days * 86400}s" # Convert local days to seconds
  retain_acked_messages      = false

  depends_on = [google_project_iam_member.pubsub_gcs_writer]
}
