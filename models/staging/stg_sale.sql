WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'sale') }}
)
SELECT
  SAFE_CAST(`Delivery Date Key` AS DATE) AS delivery_date_key,
  CAST(Description AS STRING) AS description,
  SAFE_CAST(`Invoice Date Key` AS DATE) AS invoice_date_key,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Last Modified When` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Last Modified When` AS STRING)), SAFE_CAST(`Last Modified When` AS TIMESTAMP)) AS last_modified_when,
  CAST(Package AS STRING) AS package,
  SAFE_CAST(Profit AS FLOAT64) AS profit,
  SAFE_CAST(Quantity AS INT64) AS quantity,
  SAFE_CAST(`Tax Amount` AS FLOAT64) AS tax_amount,
  SAFE_CAST(`Tax Rate` AS FLOAT64) AS tax_rate,
  SAFE_CAST(`Total Chiller Items` AS INT64) AS total_chiller_items,
  SAFE_CAST(`Total Dry Items` AS INT64) AS total_dry_items,
  SAFE_CAST(`Total Excluding Tax` AS FLOAT64) AS total_excluding_tax,
  SAFE_CAST(`Total Including Tax` AS FLOAT64) AS total_including_tax,
  SAFE_CAST(`Unit Price` AS FLOAT64) AS unit_price,
  SAFE_CAST(`WWI Bill To Customer ID` AS INT64) AS wwi_bill_to_customer_id,
  SAFE_CAST(`WWI City ID` AS INT64) AS wwi_city_id,
  SAFE_CAST(`WWI Customer ID` AS INT64) AS wwi_customer_id,
  SAFE_CAST(`WWI Invoice ID` AS INT64) AS wwi_invoice_id,
  SAFE_CAST(`WWI Salesperson ID` AS INT64) AS wwi_salesperson_id,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Invoice ID` AS INT64) IS NOT NULL