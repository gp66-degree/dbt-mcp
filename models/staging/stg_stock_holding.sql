WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'stock_holding') }}
)
SELECT
  CAST(`Bin Location` AS STRING) AS bin_location,
  SAFE_CAST(`Last Cost Price` AS INT64) AS last_cost_price,
  SAFE_CAST(`Last Stocktake Quantity` AS INT64) AS last_stocktake_quantity,
  SAFE_CAST(`Quantity On Hand` AS INT64) AS quantity_on_hand,
  SAFE_CAST(`Reorder Level` AS INT64) AS reorder_level,
  SAFE_CAST(`Target Stock Level` AS INT64) AS target_stock_level,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id
FROM
  source
WHERE
  SAFE_CAST(`Bin Location` AS STRING) IS NOT NULL