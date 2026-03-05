{% docs stg_partsupp %}
Staging model for part-supplier relationship data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by the composite key (`part_id`, `supplier_id`) keeping the most recent record.

**Granularity:** One row per part-supplier combination.

**Source:** `bronze.partsupp`
{% enddocs %}

{% docs stg_partsupp_available_quantity %}
Quantity of the part available from the supplier.
{% enddocs %}

{% docs stg_partsupp_supply_cost_value %}
Cost charged by the supplier for a single unit of the part.
{% enddocs %}

{% docs stg_partsupp_part_supplier_comment %}
Free-text comment associated with the part-supplier relationship.
{% enddocs %}
