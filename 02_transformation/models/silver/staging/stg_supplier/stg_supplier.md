{% docs stg_supplier %}
Staging model for supplier data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `supplier_id` keeping the most recent record.

**Granularity:** One row per supplier.

**Source:** `bronze.supplier`
{% enddocs %}

{% docs stg_supplier_supplier_name %}
Full name of the supplier.
{% enddocs %}

{% docs stg_supplier_supplier_address %}
Physical address of the supplier.
{% enddocs %}

{% docs stg_supplier_supplier_phone %}
Phone number of the supplier.
{% enddocs %}

{% docs stg_supplier_supplier_comment %}
Free-text comment associated with the supplier record.
{% enddocs %}
