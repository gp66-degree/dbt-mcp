WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_customer') }}
)
SELECT
  SAFE_CAST(bill_to_customer AS STRING) AS bill_to_customer,
  SAFE_CAST(buying_group AS STRING) AS buying_group,
  SAFE_CAST(category AS STRING) AS category,
  SAFE_CAST(customer AS STRING) AS customer,
  SAFE_CAST(postal_code AS STRING) AS postal_code,
  SAFE_CAST(primary_contact AS STRING) AS primary_contact,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%F%Ez', valid_from),
    SAFE_CAST(valid_from AS TIMESTAMP)
  ) AS valid_from,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%F%Ez', valid_to),
    SAFE_CAST(valid_to AS TIMESTAMP)
  ) AS valid_to,
  SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id
FROM
  source