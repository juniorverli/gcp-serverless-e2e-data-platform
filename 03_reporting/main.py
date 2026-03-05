import duckdb
import functions_framework
from flask import Request
from datetime import datetime
from src.config import Config
from src.query import get_sales_data
from src.metrics import (
    compute_kpis,
    compute_revenue_by_year,
    compute_revenue_by_month,
    compute_revenue_by_region,
    compute_revenue_by_nation,
    compute_top_customers_by_revenue,
    compute_top_customers_by_quantity,
    compute_revenue_by_segment,
)
from src.renderer import render_report, save_report

def _build_report() -> str:
    config = Config()
    arrow_table = get_sales_data(config)

    if arrow_table.num_rows == 0:
        print("Warning: No data returned from BigQuery.")

    con = duckdb.connect()
    con.register("sales", arrow_table)

    report_data = {
        "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "kpis": compute_kpis(con),
        "revenue_by_year": compute_revenue_by_year(con),
        "revenue_by_month": compute_revenue_by_month(con),
        "revenue_by_region": compute_revenue_by_region(con),
        "revenue_by_nation": compute_revenue_by_nation(con),
        "top_customers_revenue": compute_top_customers_by_revenue(con),
        "top_customers_quantity": compute_top_customers_by_quantity(con),
        "revenue_by_segment": compute_revenue_by_segment(con),
    }

    con.close()

    html = render_report(config, report_data)
    return save_report(config, html)

@functions_framework.http
def handler(request: Request) -> tuple[str, int]:
    try:
        output_path = _build_report()
        return output_path, 200
    except Exception as e:
        return str(e), 500

def main() -> None:
    _build_report()

if __name__ == "__main__":
    main()
