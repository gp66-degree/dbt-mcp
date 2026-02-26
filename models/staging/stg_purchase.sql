WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'purchase') }}
)
SELECT
  SAFE_CAST(`Date Key` AS DATE) AS date_key,
  CAST(`Is Order Line Finalized` AS BOOLEAN) AS is_order_line_finalized,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Last Modified When` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Last Modified When` AS STRING)), SAFE_CAST(`Last Modified When` AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(`Ordered Outers` AS INT64) AS ordered_outers,
  SAFE_CAST(`Ordered Quantity` AS INT64) AS ordered_quantity,
  CAST(Package AS STRING) AS package,
  SAFE_CAST(`Received Outers` AS INT64) AS received_outers,
  SAFE_CAST(`WWI Purchase Order ID` AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id,
  SAFE_CAST(`WWI Supplier ID` AS INT64) AS wwi_supplier_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Purchase Order ID` AS INT64) IS NOT NULL