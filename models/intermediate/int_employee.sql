WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_employee') }}
)
SELECT
  employee,
  SAFE_CAST(is_salesperson AS BOOLEAN) AS is_salesperson,
  photo,
  preferred_name,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(wwi_employee_id AS INT64) AS wwi_employee_id
FROM
  source