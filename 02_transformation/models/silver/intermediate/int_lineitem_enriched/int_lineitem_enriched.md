{% docs int_lineitem_enriched %}
Intermediate model that enriches line items with calculated discount and net sales values. Takes raw lineitem data and applies discount factor to compute net item sales.

**Granularity:** One row per line item.

**Upstream:** `stg_lineitem`
{% enddocs %}

{% docs int_lineitem_enriched_discount_factor %}
Factor applied to calculate discounted price, computed as `1 - discount_percent`.
{% enddocs %}

{% docs int_lineitem_enriched_net_item_sales_value %}
Net sales value of a line item after applying the discount, computed as `extended_price_value × discount_factor`.
{% enddocs %}
