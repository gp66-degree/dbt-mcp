WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'stock_item') }}
)
SELECT
  CAST(Barcode AS STRING) AS barcode,
  CAST(Brand AS STRING) AS brand,
  CAST(`Buying Package` AS STRING) AS buying_package,
  CAST(Color AS STRING) AS color,
  CAST(`Is Chiller Stock` AS BOOLEAN) AS is_chiller_stock,
  SAFE_CAST(`Lead Time Days` AS INT64) AS lead_time_days,
  CAST(Photo AS BYTES) AS photo,
  SAFE_CAST(`Quantity Per Outer` AS INT64) AS quantity_per_outer,
  SAFE_CAST(`Recommended Retail Price` AS FLOAT64) AS recommended_retail_price,
  CAST(`Selling Package` AS STRING) AS selling_package,
  CAST(Size AS STRING) AS size,
  CAST(`Stock Item` AS STRING) AS stock_item,
  SAFE_CAST(`Tax Rate` AS FLOAT64) AS tax_rate,
  SAFE_CAST(`Typical Weight Per Unit` AS FLOAT64) AS typical_weight_per_unit,
  SAFE_CAST(`Unit Price` AS FLOAT64) AS unit_price,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Stock Item ID` AS INT64) IS NOT NULL