WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_payment_method') }}
)
SELECT
  payment_method,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', valid_from),
    SAFE_CAST(valid_from AS TIMESTAMP)
  ) AS valid_from,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', valid_to),
    SAFE_CAST(valid_to AS TIMESTAMP)
  ) AS valid_to,
  SAFE_CAST(wwi_payment_method_id AS INT64) AS wwi_payment_method_id
FROM
  source