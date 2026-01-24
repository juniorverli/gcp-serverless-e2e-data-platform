# Local for function URLs map
locals {
  function_urls = { for k, v in google_cloudfunctions2_function.ingestion : k => v.service_config[0].uri }

  function_urls_list = [for table in var.tpch_tables : {
    name = table
    url  = local.function_urls[table]
  }]
}

# Wait for Workflows API service agent to be provisioned
resource "time_sleep" "wait_for_workflows_api" {
  depends_on      = [google_project_service.workflows]
  create_duration = "60s"
}

# Wait for BigLake IAM usage permission to propagate
resource "time_sleep" "wait_for_biglake_iam" {
  depends_on      = [google_project_iam_member.workflow_connection_user]
  create_duration = "60s"
}

# Ingestion Workflow
resource "google_workflows_workflow" "ingestion" {
  name            = "ingestion-pipeline-${var.target}"
  region          = var.region
  description     = "Orchestrates TPC-H data ingestion and BigLake external table creation"
  service_account = google_service_account.workflow.id

  source_contents = templatefile("${path.module}/../04_orchestration/ingestion.yaml", {
    function_urls_list = jsonencode(local.function_urls_list)
    table_names_list   = jsonencode(var.tpch_tables)
    project_id         = var.project_id
    target             = var.target
    dataset_id         = google_bigquery_dataset.bronze.dataset_id
    bronze_bucket      = google_storage_bucket.bronze.name
    connection_id      = "${var.project_id}.${var.region}.${google_bigquery_connection.biglake.connection_id}"
  })

  depends_on = [
    time_sleep.wait_for_workflows_api,
    time_sleep.wait_for_biglake_iam,
    google_cloudfunctions2_function.ingestion,
    google_bigquery_dataset.bronze,
    google_bigquery_connection.biglake,
    google_storage_bucket_iam_member.biglake_reader,
    google_project_iam_member.workflow_bigquery_editor,
    google_project_iam_member.workflow_bigquery_job_user,
    google_project_iam_member.workflow_run_invoker,
    google_project_iam_member.workflow_logging,
    google_project_iam_member.workflow_storage_viewer,
    google_project_iam_member.workflow_connection_user
  ]
}

# Optional: Execute workflow via Terraform (when execute_workflow=true)
resource "null_resource" "execute_workflow" {
  count = var.execute_workflow ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud workflows execute ${google_workflows_workflow.ingestion.name} \
        --location=${var.region} \
        --project=${var.project_id} \
        --format="value(name)"
    EOT
  }

  depends_on = [google_workflows_workflow.ingestion]
}
