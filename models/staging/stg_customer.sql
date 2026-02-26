WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'customer') }}
)
SELECT
  CAST(`Bill To Customer` AS STRING) AS bill_to_customer,
  CAST(`Buying Group` AS STRING) AS buying_group,
  CAST(Category AS STRING) AS category,
  CAST(Customer AS STRING) AS customer,
  CAST(`Postal Code` AS STRING) AS postal_code,
  CAST(`Primary Contact` AS STRING) AS primary_contact,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Customer ID` AS INT64) AS wwi_customer_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Customer ID` AS INT64) IS NOT NULL