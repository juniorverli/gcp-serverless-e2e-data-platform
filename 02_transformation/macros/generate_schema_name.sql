{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set target_name = target.name -%}

    {%- if custom_schema_name is none -%}

        {{ exceptions.raise_compiler_error("Error: The model '" ~ node.name ~ "' doesn't have a schema defined.") }}

    {%- else -%}

        {%- if target_name == 'prod' -%}

            {{ custom_schema_name | trim }}

        {%- else -%}

            {{ custom_schema_name | trim }}_{{ target_name }}

        {%- endif -%}

    {%- endif -%}

{%- endmacro %}
