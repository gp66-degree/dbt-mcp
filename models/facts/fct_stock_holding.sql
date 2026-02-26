{{ config(
  materialized='table'
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_stock_holding') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_stock_item_id']) }} AS stock_holding_key,
  SAFE_CAST(bin_location AS STRING) AS bin_location,
  SAFE_CAST(last_cost_price AS NUMERIC) AS last_cost_price,
  SAFE_CAST(last_stocktake_quantity AS BIGNUMERIC) AS last_stocktake_quantity,
  SAFE_CAST(quantity_on_hand AS BIGNUMERIC) AS quantity_on_hand,
  SAFE_CAST(reorder_level AS BIGNUMERIC) AS reorder_level,
  SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
  SAFE_CAST(target_stock_level AS BIGNUMERIC) AS target_stock_level,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id
FROM
  source