WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'payment_method') }}
)
SELECT
  CAST(`Payment Method` AS STRING) AS payment_method,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Payment Method ID` AS INT64) AS wwi_payment_method_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Payment Method ID` AS INT64) IS NOT NULL