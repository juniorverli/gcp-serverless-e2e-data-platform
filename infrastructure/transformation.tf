# Wait for Artifact Registry IAM to propagate before pushing images
resource "time_sleep" "wait_for_artifact_registry_iam" {
  depends_on      = [google_project_iam_member.compute_artifact_registry]
  create_duration = "60s"
}

# Null resource to build and push Docker image
resource "null_resource" "transformation_image" {
  triggers = {
    dockerfile_hash = filemd5("${path.module}/../02_transformation/Dockerfile")
    pyproject_hash  = filemd5("${path.module}/../02_transformation/pyproject.toml")
    uvlock_hash     = filemd5("${path.module}/../02_transformation/uv.lock")
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../02_transformation"
    command     = <<-EOT
      gcloud builds submit \
        --project ${var.project_id} \
        --tag ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.transformation.repository_id}/dbt-runner:latest \
        --machine-type=e2-highcpu-8 \
        --quiet
    EOT
  }

  depends_on = [
    google_artifact_registry_repository.transformation,
    time_sleep.wait_for_artifact_registry_iam
  ]
}

# Cloud Run Job for dbt transformations
resource "google_cloud_run_v2_job" "transformation" {
  name     = "transformation-${var.target}"
  location = var.region

  template {
    parallelism = 1
    task_count  = 1

    template {
      timeout         = "1800s"
      max_retries     = 1
      service_account = google_service_account.transformation.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.transformation.repository_id}/dbt-runner:latest"

        resources {
          limits = {
            cpu    = "4"
            memory = "4Gi"
          }
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }
      }
    }
  }

  depends_on = [
    google_project_service.run,
    null_resource.transformation_image,
    google_project_iam_member.transformation_bigquery,
    google_project_iam_member.transformation_bigquery_user
  ]
}

# Optional: Execute the job after terraform apply
resource "null_resource" "execute_transformation" {
  count = var.execute_transformation ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      gcloud run jobs execute ${google_cloud_run_v2_job.transformation.name} \
        --region=${var.region} \
        --wait
    EOT
  }

  depends_on = [google_cloud_run_v2_job.transformation]
}
