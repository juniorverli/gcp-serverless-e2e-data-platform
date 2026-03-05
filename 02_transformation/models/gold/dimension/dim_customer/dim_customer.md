{% docs dim_customer %}
Gold dimension model for customers enriched with nation and region information. Denormalizes customer, nation, and region data into a single wide customer dimension.

**Granularity:** One row per customer.

**Upstream:** `stg_customer`, `stg_nation`, `stg_region`
{% enddocs %}
