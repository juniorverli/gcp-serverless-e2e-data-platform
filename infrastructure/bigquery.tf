# BigQuery Dataset for Bronze layer (external tables)
resource "google_bigquery_dataset" "bronze" {
  dataset_id                 = "bronze_${var.target}"
  friendly_name              = "Bronze Layer (${var.target})"
  description                = "External tables pointing to AVRO files in GCS"
  location                   = var.region
  delete_contents_on_destroy = true

  labels = {
    environment = var.target
    layer       = "bronze"
  }

  depends_on = [google_project_service.bigquery]
}

# BigLake Connection for external tables
resource "google_bigquery_connection" "biglake" {
  connection_id = "biglake-${var.target}"
  location      = var.region
  friendly_name = "BigLake Connection (${var.target})"
  description   = "Connection for BigLake external tables"

  cloud_resource {}

  depends_on = [google_project_service.bigqueryconnection]
}

# Wait for BigLake service account to be fully provisioned
resource "time_sleep" "wait_for_biglake_sa" {
  depends_on      = [google_bigquery_connection.biglake]
  create_duration = "30s"
}


