variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "target" {
  description = "Environment target (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tpch_tables" {
  description = "List of TPC-H tables"
  type        = list(string)
  default = [
    "customer",
    "lineitem",
    "nation",
    "orders",
    "part",
    "partsupp",
    "region",
    "supplier"
  ]
}

variable "scale_factor" {
  description = "TPC-H scale factor"
  type        = string
  default     = "0.001"
}

variable "batch_size" {
  description = "Batch size for publishing"
  type        = string
  default     = "1000"
}

# Cloud Function Configurations
variable "function_memory" {
  description = "Memory allocated for the Cloud Function"
  type        = string
  default     = "1Gi"
}

variable "function_cpu" {
  description = "CPU allocated for the Cloud Function"
  type        = string
  default     = "1"
}

variable "function_timeout" {
  description = "Timeout in seconds for the Cloud Function"
  type        = number
  default     = 540
}

variable "duckdb_memory_limit" {
  description = "Memory limit for DuckDB"
  type        = string
  default     = "512MB"
}

variable "duckdb_threads" {
  description = "Number of threads for DuckDB"
  type        = string
  default     = "1"
}

# Pub/Sub GCS Push Configurations
variable "pubsub_max_bytes" {
  description = "Max bytes before Pub/Sub writes to GCS"
  type        = number
  default     = 1048576 # 1MB
}

variable "pubsub_max_duration" {
  description = "Max duration before Pub/Sub writes to GCS"
  type        = string
  default     = "60s"
}

variable "pubsub_retention_days" {
  description = "Message retention in days"
  type        = number
  default     = 7
}

# Storage Operations Configurations
variable "storage_bronze_retention_days" {
  description = "Retention period for bronze data in days"
  type        = number
  default     = 90
}

variable "storage_source_retention_days" {
  description = "Retention period for source code ZIPs in days"
  type        = number
  default     = 7
}
