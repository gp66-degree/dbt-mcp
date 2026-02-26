WITH stg_stock_holding AS (
  SELECT
    *
  FROM
    {{ ref('stg_stock_holding') }}
),
dim_stock_item AS (
  SELECT
    *
  FROM
    {{ ref('dim_stock_item') }}
  WHERE
    is_current = TRUE
)
SELECT
  stg_stock_holding.bin_location,
  SAFE_CAST(stg_stock_holding.last_cost_price AS NUMERIC) AS last_cost_price,
  SAFE_CAST(stg_stock_holding.last_stocktake_quantity AS INT64) AS last_stocktake_quantity,
  SAFE_CAST(stg_stock_holding.quantity_on_hand AS INT64) AS quantity_on_hand,
  SAFE_CAST(stg_stock_holding.reorder_level AS INT64) AS reorder_level,
  COALESCE(dim_stock_item.stock_item_key, 0) AS stock_item_key,
  SAFE_CAST(stg_stock_holding.target_stock_level AS INT64) AS target_stock_level,
  SAFE_CAST(stg_stock_holding.wwi_stock_item_id AS INT64) AS wwi_stock_item_id
FROM
  stg_stock_holding
  LEFT JOIN dim_stock_item
    ON SAFE_CAST(stg_stock_holding.wwi_stock_item_id AS INT64) = dim_stock_item.wwi_stock_item_id