import pyarrow as pa
from google.cloud import bigquery
from src.config import Config

def get_sales_data(config: Config) -> pa.Table:
    client = bigquery.Client(project=config.gcp_project_id)

    query = f"""
        SELECT
            order_date,
            order_year,
            order_month,
            order_month_name,
            quarter,
            week_of_year,
            day_name,
            is_weekend,
            customer_id,
            customer_name,
            customer_nation_name,
            customer_region_name,
            market_segment_name,
            revenue_quantity,
            tpv_value,
            net_revenue_value,
            cost_value,
            margin_value
        FROM `{config.gcp_project_id}.gold_{config.target}.obt_sales`
    """

    print(f"Querying {config.gcp_project_id}.gold_{config.target}.obt_sales...")
    table = client.query(query).to_arrow()
    print(f"Loaded {table.num_rows:,} rows.")
    return table
