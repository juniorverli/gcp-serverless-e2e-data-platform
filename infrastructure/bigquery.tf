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

# =============================================================================
# Data Masking — BigQuery Resources
# =============================================================================

# Dataset to host the masking UDFs
resource "google_bigquery_dataset" "data_masking" {
  dataset_id                 = "data_masking_${var.target}"
  friendly_name              = "Data Masking routines (${var.target})"
  description                = "Dataset for custom data masking UDFs"
  location                   = var.region
  delete_contents_on_destroy = true

  depends_on = [google_project_service.bigquery]
}

resource "google_bigquery_routine" "mask_name" {
  dataset_id           = google_bigquery_dataset.data_masking.dataset_id
  routine_id           = "mask_name"
  routine_type         = "SCALAR_FUNCTION"
  language             = "SQL"
  data_governance_type = "DATA_MASKING"

  definition_body = <<-SQL
CONCAT(
  CASE
    WHEN LENGTH(REGEXP_EXTRACT(name, r'^([^\s,]+)')) > 5
    THEN CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^([^\s,]+)'), r'^.{2}(.*).$'), r'.', '*'), REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^([^\s,]+)'), r'(.)$'))
    ELSE CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^([^\s,]+)'), r'^.{2}(.+)$'), r'.', '*'))
  END,
  CASE WHEN REGEXP_EXTRACT(name, r'^([^\s,]+),') IS NOT NULL THEN ',' ELSE '' END,

  CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)') IS NOT NULL THEN CONCAT(' ',
    CASE
      WHEN LENGTH(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)')) > 5
      THEN CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.*).$'), r'.', '*'), REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)'), r'(.)$'))
      ELSE CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.+)$'), r'.', '*'))
    END,
    CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+([^\s,]+),') IS NOT NULL THEN ',' ELSE '' END
  ) ELSE '' END,

  CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)') IS NOT NULL THEN CONCAT(' ',
    CASE
      WHEN LENGTH(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)')) > 5
      THEN CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.*).$'), r'.', '*'), REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'(.)$'))
      ELSE CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.+)$'), r'.', '*'))
    END,
    CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+),') IS NOT NULL THEN ',' ELSE '' END
  ) ELSE '' END,

  CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)') IS NOT NULL THEN CONCAT(' ',
    CASE
      WHEN LENGTH(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)')) > 5
      THEN CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.*).$'), r'.', '*'), REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'(.)$'))
      ELSE CONCAT(SUBSTR(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), 1, 2), REGEXP_REPLACE(REGEXP_EXTRACT(REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+)'), r'^.{2}(.+)$'), r'.', '*'))
    END,
    CASE WHEN REGEXP_EXTRACT(name, r'^[^\s,]+[\s,]+[^\s,]+[\s,]+[^\s,]+[\s,]+([^\s,]+),') IS NOT NULL THEN ',' ELSE '' END
  ) ELSE '' END
)
  SQL

  arguments {
    name      = "name"
    data_type = jsonencode({ typeKind = "STRING" })
  }

  return_type = jsonencode({ typeKind = "STRING" })
}
