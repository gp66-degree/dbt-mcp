WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'transaction') }}
)
SELECT
  SAFE_CAST(`Date Key` AS DATE) AS date_key,
  CAST(`Is Finalized` AS BOOLEAN) AS is_finalized,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Last Modified When` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Last Modified When` AS STRING)), SAFE_CAST(`Last Modified When` AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(`Outstanding Balance` AS FLOAT64) AS outstanding_balance,
  CAST(`Supplier Invoice Number` AS STRING) AS supplier_invoice_number,
  SAFE_CAST(`Tax Amount` AS FLOAT64) AS tax_amount,
  SAFE_CAST(`Total Excluding Tax` AS FLOAT64) AS total_excluding_tax,
  SAFE_CAST(`Total Including Tax` AS FLOAT64) AS total_including_tax,
  SAFE_CAST(`WWI Bill To Customer ID` AS INT64) AS wwi_bill_to_customer_id,
  SAFE_CAST(`WWI Customer ID` AS INT64) AS wwi_customer_id,
  SAFE_CAST(`WWI Customer Transaction ID` AS INT64) AS wwi_customer_transaction_id,
  SAFE_CAST(`WWI Invoice ID` AS INT64) AS wwi_invoice_id,
  SAFE_CAST(`WWI Payment Method ID` AS INT64) AS wwi_payment_method_id,
  SAFE_CAST(`WWI Purchase Order ID` AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(`WWI Supplier ID` AS INT64) AS wwi_supplier_id,
  SAFE_CAST(`WWI Supplier Transaction ID` AS INT64) AS wwi_supplier_transaction_id,
  SAFE_CAST(`WWI Transaction Type ID` AS INT64) AS wwi_transaction_type_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Bill To Customer ID` AS INT64) IS NOT NULL