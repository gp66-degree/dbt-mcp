WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'supplier') }}
)
SELECT
  CAST(Category AS STRING) AS category,
  SAFE_CAST(`Payment Days` AS INT64) AS payment_days,
  CAST(`Postal Code` AS STRING) AS postal_code,
  CAST(`Primary Contact` AS STRING) AS primary_contact,
  CAST(Supplier AS STRING) AS supplier,
  CAST(`Supplier Reference` AS STRING) AS supplier_reference,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Supplier ID` AS INT64) AS wwi_supplier_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Supplier ID` AS INT64) IS NOT NULL