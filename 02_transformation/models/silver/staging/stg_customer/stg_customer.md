{% docs stg_customer %}
Staging model for customer data. Parses raw JSON from the bronze layer, casts data types, and deduplicates by `customer_id` keeping the most recent record.

**Granularity:** One row per customer.

**Source:** `bronze.customer`
{% enddocs %}

{% docs stg_customer_customer_name %}
Full name of the customer.
{% enddocs %}

{% docs stg_customer_customer_email_address %}
Email address of the customer.
{% enddocs %}

{% docs stg_customer_customer_address %}
Physical address of the customer.
{% enddocs %}

{% docs stg_customer_customer_phone %}
Phone number of the customer.
{% enddocs %}

{% docs stg_customer_account_balance_value %}
Current account balance in the system currency.
{% enddocs %}

{% docs stg_customer_market_segment_name %}
Market segment the customer belongs to.
{% enddocs %}

{% docs stg_customer_customer_comment %}
Free-text comment associated with the customer record.
{% enddocs %}
