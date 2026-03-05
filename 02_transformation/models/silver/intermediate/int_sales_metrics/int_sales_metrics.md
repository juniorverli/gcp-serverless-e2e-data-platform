{% docs int_sales_metrics %}
Intermediate model that joins enriched line items with orders and part-supplier data to compute sales metrics. Calculates TPV, net revenue, cost, and margin at the line item level.

**Granularity:** One row per line item.

**Upstream:** `int_lineitem_enriched`, `stg_orders`, `stg_partsupp`
{% enddocs %}

{% docs int_sales_metrics_tpv_value %}
Total Payment Volume — total monetary value of the transaction before discounts. Equivalent to the extended price value.
{% enddocs %}

{% docs int_sales_metrics_net_revenue_value %}
Revenue after discounts have been applied.
{% enddocs %}

{% docs int_sales_metrics_cost_value %}
Total cost of goods, calculated as `supply_cost_value × quantity`.
{% enddocs %}

{% docs int_sales_metrics_margin_value %}
Profit margin calculated as `net_revenue_value - cost_value`.
{% enddocs %}
