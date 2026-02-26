WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'employee') }}
)
SELECT
  CAST(Employee AS STRING) AS employee,
  SAFE_CAST(`Is Salesperson` AS BOOLEAN) AS is_salesperson,
  CAST(Photo AS BYTES) AS photo,
  CAST(`Preferred Name` AS STRING) AS preferred_name,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI Employee ID` AS INT64) AS wwi_employee_id
FROM
  source
WHERE
  SAFE_CAST(`WWI Employee ID` AS INT64) IS NOT NULL