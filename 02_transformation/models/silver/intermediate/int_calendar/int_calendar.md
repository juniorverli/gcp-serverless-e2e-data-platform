{% docs int_calendar %}
Intermediate model that generates a calendar dimension using `dbt_utils.date_spine`. Produces one row per day from 1990-01-01 to 2030-12-31 with date attributes.

**Granularity:** One row per calendar day.

**Source:** Generated via `dbt_utils.date_spine`
{% enddocs %}

{% docs int_calendar_created_date %}
Calendar date. Used as the primary key in the calendar dimension.
{% enddocs %}

{% docs int_calendar_year %}
Calendar year extracted from the date.
{% enddocs %}

{% docs int_calendar_quarter %}
Calendar quarter (1-4) extracted from the date.
{% enddocs %}

{% docs int_calendar_month %}
Calendar month number (1-12) extracted from the date.
{% enddocs %}

{% docs int_calendar_month_name %}
Full name of the calendar month (e.g. January, February).
{% enddocs %}

{% docs int_calendar_week_of_year %}
Week number within the year (1-53).
{% enddocs %}

{% docs int_calendar_day_of_month %}
Day number within the month (1-31).
{% enddocs %}

{% docs int_calendar_day_of_week %}
Day number within the week (1 = Sunday, 7 = Saturday).
{% enddocs %}

{% docs int_calendar_day_name %}
Full name of the day of the week (e.g. Monday, Tuesday).
{% enddocs %}

{% docs int_calendar_is_weekend %}
Boolean flag indicating whether the date falls on a weekend (Saturday or Sunday).
{% enddocs %}
