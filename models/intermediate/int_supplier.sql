WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_supplier') }}
)
SELECT
  SAFE_CAST(category AS STRING) AS category,
  SAFE_CAST(payment_days AS INT64) AS payment_days,
  SAFE_CAST(postal_code AS STRING) AS postal_code,
  SAFE_CAST(primary_contact AS STRING) AS primary_contact,
  SAFE_CAST(supplier AS STRING) AS supplier,
  SAFE_CAST(supplier_reference AS STRING) AS supplier_reference,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%F', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%F', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id
FROM
  source