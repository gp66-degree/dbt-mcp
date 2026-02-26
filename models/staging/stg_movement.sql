WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'movement') }}
)
SELECT
  SAFE_CAST(`Date Key` AS DATE) AS date_key,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Last Modified When` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Last Modified When` AS STRING)), SAFE_CAST(`Last Modified When` AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(Quantity AS INT64) AS quantity,
  SAFE_CAST(`WWI Customer ID` AS INT64) AS wwi_customer_id,
  SAFE_CAST(`WWI Invoice ID` AS INT64) AS wwi_invoice_id,
  SAFE_CAST(`WWI Purchase Order ID` AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(`WWI Stock Item ID` AS INT64) AS wwi_stock_item_id,
  SAFE_CAST(`WWI Stock Item Transaction ID` AS INT64) AS wwi_stock_item_transaction_id,
  SAFE_CAST(`WWI Supplier ID` AS INT64) AS wwi_supplier_id,
  SAFE_CAST(`WWI Transaction Type ID` AS INT64) AS wwi_transaction_type_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Stock Item Transaction ID` AS INT64) IS NOT NULL