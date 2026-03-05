from jinja2 import Environment, FileSystemLoader
from google.cloud import storage
from src.config import Config

def render_report(config: Config, report_data: dict) -> str:
    env = Environment(loader=FileSystemLoader(config.template_dir))
    env.filters["currency"] = lambda v: f"${v:,.2f}"
    env.filters["number"] = lambda v: f"{v:,.0f}"

    template = env.get_template("report.html")
    return template.render(**report_data)

def save_report(config: Config, html_content: str) -> str:
    if config.gcs_bucket:
        return _upload_to_gcs(config, html_content)
    return _save_local(config, html_content)

def _save_local(config: Config, html_content: str) -> str:
    config.output_dir.mkdir(exist_ok=True)
    output_file = config.output_dir / "sales_report.html"
    output_file.write_text(html_content, encoding="utf-8")
    print(f"Report saved locally: {output_file}")
    return str(output_file)

def _upload_to_gcs(config: Config, html_content: str) -> str:
    client = storage.Client(project=config.gcp_project_id)
    bucket = client.bucket(config.gcs_bucket)
    blob = bucket.blob("sales_report.html")
    blob.upload_from_string(html_content, content_type="text/html")
    gcs_path = f"gs://{config.gcs_bucket}/sales_report.html"
    print(f"Report uploaded to: {gcs_path}")
    return gcs_path
