{% docs stg_region %}
Staging model for region reference data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `region_id` keeping the most recent record.

**Granularity:** One row per region.

**Source:** `bronze.region`
{% enddocs %}

{% docs stg_region_region_name %}
Name of the region.
{% enddocs %}

{% docs stg_region_region_comment %}
Free-text comment associated with the region record.
{% enddocs %}
