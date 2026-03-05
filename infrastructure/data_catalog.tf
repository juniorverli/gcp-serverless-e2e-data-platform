# =============================================================================
# Dynamic Data Masking — PII Taxonomy & Policy Tags
# =============================================================================

# Taxonomy for PII classification
resource "google_data_catalog_taxonomy" "pii" {
  project      = var.project_id
  region       = var.region
  display_name = "PII - ${var.target}"
  description  = "Taxonomy for Personally Identifiable Information"

  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]

  depends_on = [google_project_service.datacatalog]
}

# Policy Tag for customer names
resource "google_data_catalog_policy_tag" "name" {
  taxonomy     = google_data_catalog_taxonomy.pii.id
  display_name = "customer_name"
  description  = "Policy tag for customer name columns — custom proportional masking"
}

# =============================================================================
# Data Policies
# =============================================================================

resource "google_bigquery_datapolicy_data_policy" "name_mask" {
  location         = var.region
  data_policy_id   = "name_mask_${var.target}"
  policy_tag       = google_data_catalog_policy_tag.name.name
  data_policy_type = "DATA_MASKING_POLICY"

  data_masking_policy {
    routine = google_bigquery_routine.mask_name.id
  }

  depends_on = [google_project_service.bigquerydatapolicy]
}
