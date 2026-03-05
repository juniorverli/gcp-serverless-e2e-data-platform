import os
import sys
from pathlib import Path

class Config:
    def __init__(self):
        self.gcp_project_id = os.getenv("GCP_PROJECT_ID")
        self.target = os.getenv("TARGET", "dev")
        self.gcs_bucket = os.getenv("GCS_REPORT_BUCKET")
        self.template_dir = Path(__file__).parent.parent / "templates"
        self.output_dir = Path(__file__).parent.parent / "output"

        if not self.gcp_project_id:
            print("Error: GCP_PROJECT_ID environment variable is required.")
            sys.exit(1)
