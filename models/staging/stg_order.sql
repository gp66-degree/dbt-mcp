WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'order') }}
)
SELECT
  CAST(Description AS STRING) AS description,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%.f%Ez', CAST(`Last Modified When` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%.f', CAST(`Last Modified When` AS STRING)), SAFE_CAST(`Last Modified When` AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(`Order Date Key` AS DATE) AS order_date_key,
  CAST(Package AS STRING) AS package,
  SAFE_CAST(`Picked Date Key` AS DATE) AS picked_date_key,
  SAFE_CAST(Quantity AS INT64) AS quantity,
  SAFE_CAST(`Tax Amount` AS FLOAT64) AS tax_amount,
  SAFE_CAST(`Tax Rate` AS FLOAT64) AS tax_rate,
  SAFE_CAST(`Total Excluding Tax` AS FLOAT64) AS total_excluding_tax,
  SAFE_CAST(`Total Including Tax` AS FLOAT64) AS total_including_tax,
  SAFE_CAST(`Unit Price` AS FLOAT64) AS unit_price,
  SAFE_CAST(`WWI Backorder ID` AS INT64) AS wwi_backorder_id,
  SAFE_CAST(`WWI City ID` AS INT64) AS wwi_city_id,
  SAFE_CAST(`WWI Customer ID` AS INT64) AS wwi_customer_id,
  SAFE_CAST(`WWI Order ID` AS INT64) AS wwi_order_id,
  SAFE_CAST(`WWI Picker ID` AS INT64) AS wwi_picker_id,
  SAFE_CAST(`WWI Salesperson ID` AS INT64) AS wwi_salesperson_id,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Order ID` AS INT64) IS NOT NULL