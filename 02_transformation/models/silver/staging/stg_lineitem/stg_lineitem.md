{% docs stg_lineitem %}
Staging model for line item data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by the composite key (`order_id`, `part_id`, `supplier_id`, `line_number`) keeping the most recent record.

**Granularity:** One row per line item within an order.

**Source:** `bronze.lineitem`
{% enddocs %}

{% docs stg_lineitem_quantity %}
Quantity of items.
{% enddocs %}

{% docs stg_lineitem_extended_price_value %}
Extended price of the line item before discounts (unit price × quantity).
{% enddocs %}

{% docs stg_lineitem_discount_percent %}
Discount percentage applied to the line item, expressed as a decimal (e.g. 0.05 = 5%).
{% enddocs %}

{% docs stg_lineitem_tax_percent %}
Tax percentage applied to the line item, expressed as a decimal (e.g. 0.08 = 8%).
{% enddocs %}

{% docs stg_lineitem_return_flag_code %}
Flag indicating the return status of the line item (R = returned, A = accepted, N = none).
{% enddocs %}

{% docs stg_lineitem_line_status_code %}
Status code of the line item (O = open, F = fulfilled).
{% enddocs %}

{% docs stg_lineitem_ship_date %}
Date when the line item was shipped.
{% enddocs %}

{% docs stg_lineitem_commit_date %}
Date by which the line item was committed to be delivered.
{% enddocs %}

{% docs stg_lineitem_receipt_date %}
Date when the line item was received by the customer.
{% enddocs %}

{% docs stg_lineitem_ship_instructions_name %}
Shipping instructions for the line item (e.g. DELIVER IN PERSON, COLLECT COD).
{% enddocs %}

{% docs stg_lineitem_ship_mode_name %}
Shipping mode used for the line item (e.g. AIR, TRUCK, SHIP, RAIL).
{% enddocs %}

{% docs stg_lineitem_line_comment %}
Free-text comment associated with the line item.
{% enddocs %}
