{{ config(
  materialized='incremental',
  unique_key='order_key',
  incremental_strategy='merge',
  partition_by={
    "field": "order_date_key",
    "data_type": "date",
    "granularity": "day"
  },
  cluster_by=["city_key", "customer_key", "stock_item_key"]
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_order') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_order_id', 'description']) }} AS order_key,
  SAFE_CAST(city_key AS INT64) AS city_key,
  SAFE_CAST(customer_key AS INT64) AS customer_key,
  description,
  COALESCE(SAFE.PARSE_TIMESTAMP('%F %T.%E*S', last_modified_when), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
  SAFE.PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING)) AS order_date_key,
  package,
  SAFE.PARSE_DATE('%Y%m%d', CAST(picked_date_key AS STRING)) AS picked_date_key,
  SAFE_CAST(picker_key AS INT64) AS picker_key,
  SAFE_CAST(quantity AS BIGNUMERIC) AS quantity,
  SAFE_CAST(salesperson_key AS INT64) AS salesperson_key,
  SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
  SAFE_CAST(tax_amount AS BIGNUMERIC) AS tax_amount,
  SAFE_CAST(tax_rate AS BIGNUMERIC) AS tax_rate,
  SAFE_CAST(total_excluding_tax AS BIGNUMERIC) AS total_excluding_tax,
  SAFE_CAST(total_including_tax AS BIGNUMERIC) AS total_including_tax,
  SAFE_CAST(unit_price AS BIGNUMERIC) AS unit_price,
  SAFE_CAST(wwi_backorder_id AS INT64) AS wwi_backorder_id,
  SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id,
  SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
  SAFE_CAST(wwi_order_id AS INT64) AS wwi_order_id,
  SAFE_CAST(wwi_picker_id AS INT64) AS wwi_picker_id,
  SAFE_CAST(wwi_salesperson_id AS INT64) AS wwi_salesperson_id,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id
FROM
  source
{% if is_incremental() %}
WHERE
  SAFE.PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING)) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
{% endif %}