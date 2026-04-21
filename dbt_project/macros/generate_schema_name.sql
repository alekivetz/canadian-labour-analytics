{# =============================================================================
   Macro: generate_schema_name
   =============================================================================
   Overrides dbt's default schema naming behaviour.

   By default, dbt prepends the target schema to the custom schema name,
   resulting in names like BRONZE_SILVER or BRONZE_GOLD. This macro overrides
   that behaviour so models are created in their exact schema as defined in
   dbt_project.yml (SILVER, GOLD) without any prefix.

   Args:
       custom_schema_name: schema defined in dbt_project.yml (+schema config)
       node: the dbt model node (unused but required by dbt's macro signature)
============================================================================= #}

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}