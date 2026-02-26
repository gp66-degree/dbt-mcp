WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'transaction_type') }}
)
SELECT
  CAST(`Transaction Type` AS STRING) AS transaction_type,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Transaction Type ID` AS INT64) AS wwi_transaction_type_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Transaction Type ID` AS INT64) IS NOT NULL