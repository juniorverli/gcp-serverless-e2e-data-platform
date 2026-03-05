import duckdb

def _fetch_dicts(rel: duckdb.DuckDBPyRelation) -> list[dict]:
    columns = [desc[0] for desc in rel.description]
    return [dict(zip(columns, row)) for row in rel.fetchall()]


def compute_kpis(con: duckdb.DuckDBPyConnection) -> dict:
    return _fetch_dicts(con.sql("""
        WITH kpis AS (

            SELECT
                COUNT(DISTINCT (customer_id, order_date)) AS total_orders,
                COUNT(DISTINCT customer_id) AS unique_customers,
                SUM(revenue_quantity) AS total_quantity,
                SUM(tpv_value) AS tpv,
                SUM(net_revenue_value) AS net_revenue,
                SUM(cost_value) AS total_cost,
                SUM(margin_value) AS total_margin
            FROM sales

        )

        SELECT
            total_orders,
            unique_customers,
            total_quantity,
            tpv,
            net_revenue,
            total_cost,
            total_margin,
            CASE
                WHEN net_revenue != 0
                THEN ROUND(total_margin / net_revenue * 100, 2)
                ELSE 0
            END AS margin_pct
        FROM kpis
    """))[0]


def compute_revenue_by_year(con: duckdb.DuckDBPyConnection) -> list[dict]:
    return _fetch_dicts(con.sql("""
        SELECT
            order_year,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(cost_value) AS cost,
            SUM(margin_value) AS margin,
            SUM(revenue_quantity) AS quantity
        FROM sales
        GROUP BY order_year
        ORDER BY order_year
    """))


def compute_revenue_by_month(con: duckdb.DuckDBPyConnection) -> list[dict]:
    return _fetch_dicts(con.sql("""
        SELECT
            order_year,
            order_month,
            order_month_name,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(margin_value) AS margin,
            order_month_name[:3] || ' ' || CAST(order_year AS VARCHAR) AS period
        FROM sales
        GROUP BY order_year, order_month, order_month_name
        ORDER BY order_year, order_month
    """))


def compute_revenue_by_region(con: duckdb.DuckDBPyConnection) -> list[dict]:
    return _fetch_dicts(con.sql("""
        SELECT
            customer_region_name,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(margin_value) AS margin,
            COUNT(DISTINCT customer_id) AS customers
        FROM sales
        GROUP BY customer_region_name
        ORDER BY gross_revenue DESC
    """))


def compute_revenue_by_nation(con: duckdb.DuckDBPyConnection) -> list[dict]:
    return _fetch_dicts(con.sql("""
        SELECT
            customer_region_name,
            customer_nation_name,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(margin_value) AS margin,
            COUNT(DISTINCT customer_id) AS customers
        FROM sales
        GROUP BY customer_region_name, customer_nation_name
        ORDER BY gross_revenue DESC
        LIMIT 15
    """))


def compute_top_customers_by_revenue(con: duckdb.DuckDBPyConnection, top_n: int = 10) -> list[dict]:
    return _fetch_dicts(con.sql(f"""
        SELECT
            ROW_NUMBER() OVER (ORDER BY SUM(tpv_value) DESC) AS rank,
            customer_id,
            customer_name,
            customer_region_name,
            customer_nation_name,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(margin_value) AS margin,
            COUNT(DISTINCT order_date) AS total_orders
        FROM sales
        GROUP BY customer_id, customer_name, customer_region_name, customer_nation_name
        ORDER BY gross_revenue DESC
        LIMIT {top_n}
    """))


def compute_top_customers_by_quantity(con: duckdb.DuckDBPyConnection, top_n: int = 10) -> list[dict]:
    return _fetch_dicts(con.sql(f"""
        SELECT
            ROW_NUMBER() OVER (ORDER BY SUM(revenue_quantity) DESC) AS rank,
            customer_id,
            customer_name,
            customer_region_name,
            customer_nation_name,
            SUM(revenue_quantity) AS quantity,
            SUM(tpv_value) AS gross_revenue,
            COUNT(DISTINCT order_date) AS total_orders
        FROM sales
        GROUP BY customer_id, customer_name, customer_region_name, customer_nation_name
        ORDER BY quantity DESC
        LIMIT {top_n}
    """))


def compute_revenue_by_segment(con: duckdb.DuckDBPyConnection) -> list[dict]:
    return _fetch_dicts(con.sql("""
        SELECT
            market_segment_name,
            SUM(tpv_value) AS gross_revenue,
            SUM(net_revenue_value) AS net_revenue,
            SUM(margin_value) AS margin,
            COUNT(DISTINCT customer_id) AS customers,
            SUM(revenue_quantity) AS quantity
        FROM sales
        GROUP BY market_segment_name
        ORDER BY gross_revenue DESC
    """))
