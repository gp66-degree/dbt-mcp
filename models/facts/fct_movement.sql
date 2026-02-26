{{ config(
  materialized='incremental',
  unique_key='movement_key',
  incremental_strategy='merge',
  partition_by={
    "field": "date_key",
    "data_type": "date",
    "granularity": "day"
  },
  cluster_by=["customer_key", "stock_item_key", "supplier_key"]
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_movement') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_stock_item_transaction_id']) }} AS movement_key,
  SAFE_CAST(customer_key AS INT64) AS customer_key,
  SAFE_CAST(date_key AS DATE) AS date_key,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', last_modified_when), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(quantity AS INT64) AS quantity,
  SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
  SAFE_CAST(supplier_key AS INT64) AS supplier_key,
  SAFE_CAST(transaction_type_key AS INT64) AS transaction_type_key,
  SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
  SAFE_CAST(wwi_invoice_id AS INT64) AS wwi_invoice_id,
  SAFE_CAST(wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
  SAFE_CAST(wwi_stock_item_transaction_id AS INT64) AS wwi_stock_item_transaction_id,
  SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id,
  SAFE_CAST(wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id
FROM
  source
{% if is_incremental() %}
WHERE
  SAFE_CAST(date_key AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
{% endif %}