{% docs obt_sales %}
Gold One Big Table (OBT) combining `fact_sales`, `dim_calendar`, and `dim_customer` into a single denormalized table optimized for analytics and reporting.

**Granularity:** One row per customer per order date.

**Upstream:** `fact_sales`, `dim_calendar`, `dim_customer`
{% enddocs %}

{% docs obt_sales_order_year %}
Year when the order was placed, derived from the calendar dimension.
{% enddocs %}

{% docs obt_sales_order_month %}
Month number (1-12) when the order was placed, derived from the calendar dimension.
{% enddocs %}

{% docs obt_sales_order_month_name %}
Full month name when the order was placed (e.g. January, February), derived from the calendar dimension.
{% enddocs %}

{% docs obt_sales_revenue_quantity %}
Total quantity of items sold, aggregated from line items.
{% enddocs %}

{% docs obt_sales_customer_nation_name %}
Name of the nation the customer belongs to.
{% enddocs %}

{% docs obt_sales_customer_region_name %}
Name of the region the customer belongs to.
{% enddocs %}
