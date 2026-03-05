{% docs fact_sales %}
Gold fact model for aggregated sales metrics. Consolidates revenue, cost, margin, and TPV into a single fact table aggregated by customer and order date.

**Granularity:** One row per customer per order date.

**Upstream:** `int_sales_metrics`
{% enddocs %}

{% docs fact_sales_sales_uid %}
Surrogate key generated from `customer_id` and `order_date`. Uniquely identifies each row in the fact table.
{% enddocs %}
