# Artifact Registry for dbt transformation image
resource "google_artifact_registry_repository" "transformation" {
  location      = var.region
  repository_id = "transformation-${var.target}"
  description   = "Docker repository for dbt transformation"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 5
    }
  }

  depends_on = [google_project_service.artifactregistry]
}
