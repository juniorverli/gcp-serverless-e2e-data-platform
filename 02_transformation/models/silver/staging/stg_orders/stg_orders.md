{% docs stg_orders %}
Staging model for order data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `order_id` keeping the most recent record.

**Granularity:** One row per order.

**Source:** `bronze.orders`
{% enddocs %}

{% docs stg_orders_order_date %}
Date when the order was placed.
{% enddocs %}

{% docs stg_orders_order_status_code %}
Status code of the order (O = open, F = fulfilled, P = partially fulfilled).
{% enddocs %}

{% docs stg_orders_total_price_value %}
Total monetary value of the order.
{% enddocs %}

{% docs stg_orders_order_priority_code %}
Priority level of the order (e.g. 1-URGENT, 2-HIGH, 3-MEDIUM).
{% enddocs %}

{% docs stg_orders_clerk_name %}
Name of the clerk responsible for the order.
{% enddocs %}

{% docs stg_orders_ship_priority %}
Shipping priority level of the order.
{% enddocs %}

{% docs stg_orders_order_comment %}
Free-text comment associated with the order.
{% enddocs %}
