{% docs stg_part %}
Staging model for part data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `part_id` keeping the most recent record.

**Granularity:** One row per part.

**Source:** `bronze.part`
{% enddocs %}

{% docs stg_part_part_name %}
Name of the part.
{% enddocs %}

{% docs stg_part_manufacturer_name %}
Name of the manufacturer.
{% enddocs %}

{% docs stg_part_brand_name %}
Brand name of the part.
{% enddocs %}

{% docs stg_part_part_type_name %}
Type classification of the part.
{% enddocs %}

{% docs stg_part_part_size %}
Size of the part.
{% enddocs %}

{% docs stg_part_container_name %}
Container type used for the part.
{% enddocs %}

{% docs stg_part_retail_price_value %}
Suggested retail price of the part.
{% enddocs %}

{% docs stg_part_part_comment %}
Free-text comment associated with the part record.
{% enddocs %}
