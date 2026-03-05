# Bronze bucket - receives AVRO from Pub/Sub subscriptions
resource "google_storage_bucket" "bronze" {
  name                        = "${var.project_id}-bronze-${var.target}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.storage_bronze_retention_days
    }
    action {
      type = "Delete"
    }
  }
}

# GCS Bucket for Silver Data Lake (Iceberg/Parquet)
resource "google_storage_bucket" "silver" {
  name                        = "${var.project_id}-silver-prod"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}

# GCS Bucket for Silver Dev environment
resource "google_storage_bucket" "silver_dev" {
  name                        = "${var.project_id}-silver-dev"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}


# GCS Bucket for Gold Data Lake (Iceberg/Parquet)
resource "google_storage_bucket" "gold" {
  name                        = "${var.project_id}-gold-prod"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}

# GCS Bucket for Gold Dev environment
resource "google_storage_bucket" "gold_dev" {
  name                        = "${var.project_id}-gold-dev"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}

# Source bucket - stores Cloud Function zip
resource "google_storage_bucket" "source" {
  name                        = "${var.project_id}-source-${var.target}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.storage_source_retention_days # Deletes old ZIPs after one week
    }
    action {
      type = "Delete"
    }
  }
}

# Reporting bucket - stores generated HTML reports
resource "google_storage_bucket" "reporting" {
  name                        = "${var.project_id}-reporting-${var.target}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}
