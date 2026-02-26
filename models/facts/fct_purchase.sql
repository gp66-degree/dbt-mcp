{{ config(
  materialized='incremental',
  unique_key='purchase_key',
  incremental_strategy='merge',
  partition_by={
    "field": "date_key",
    "data_type": "date",
    "granularity": "day"
  },
  cluster_by=["stock_item_key", "supplier_key"]
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_purchase') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_purchase_order_id', 'wwi_stock_item_id']) }} AS purchase_key,
  SAFE_CAST(date_key AS DATE) AS date_key,
  SAFE_CAST(is_order_line_finalized AS BOOL) AS is_order_line_finalized,
  COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', last_modified_when),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', last_modified_when),
      SAFE_CAST(last_modified_when AS TIMESTAMP)
  ) AS last_modified_when,
  SAFE_CAST(ordered_outers AS INT64) AS ordered_outers,
  SAFE_CAST(ordered_quantity AS INT64) AS ordered_quantity,
  package,
  SAFE_CAST(received_outers AS INT64) AS received_outers,
  SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
  SAFE_CAST(supplier_key AS INT64) AS supplier_key,
  SAFE_CAST(wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
  SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id
FROM
  source
{% if is_incremental() %}
WHERE
  SAFE_CAST(date_key AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
{% endif %}