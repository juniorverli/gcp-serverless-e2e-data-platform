{% docs stg_nation %}
Staging model for nation reference data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `nation_id` keeping the most recent record.

**Granularity:** One row per nation.

**Source:** `bronze.nation`
{% enddocs %}

{% docs stg_nation_nation_name %}
Name of the nation.
{% enddocs %}

{% docs stg_nation_nation_comment %}
Free-text comment associated with the nation record.
{% enddocs %}
