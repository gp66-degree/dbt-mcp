WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_transaction_type') }}
)
SELECT
  SAFE_CAST(transaction_type AS STRING) AS transaction_type,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id
FROM
  source