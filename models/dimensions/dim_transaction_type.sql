{{ config(
  materialized='incremental',
  unique_key='transaction_type_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id,
    -- Robustly parse/cast valid_from to TIMESTAMP
    COALESCE(SAFE.PARSE_TIMESTAMP('%F %T', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    -- Robustly parse/cast valid_to to TIMESTAMP
    COALESCE(SAFE.PARSE_TIMESTAMP('%F %T', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
    SAFE_CAST(transaction_type AS STRING) AS transaction_type
  FROM {{ ref('int_transaction_type') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_transaction_type_id = t.wwi_transaction_type_id AND t.is_current = TRUE
  WHERE
    s.transaction_type <> t.transaction_type
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_transaction_type_id = t.wwi_transaction_type_id
  WHERE t.wwi_transaction_type_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_transaction_type_id,
    valid_from,
    valid_to,
    transaction_type
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_transaction_type_id,
    valid_from,
    valid_to,
    transaction_type
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_transaction_type_id', 'valid_from']) }} AS transaction_type_key,
    scd.wwi_transaction_type_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_transaction_type_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_transaction_type_id ORDER BY scd.valid_from) = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
    scd.transaction_type
  FROM scd_union AS scd
)

SELECT
  is_current,
  transaction_type,
  transaction_type_key,
  valid_from,
  valid_to,
  wwi_transaction_type_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_transaction_type_id', 'valid_from']) }} AS transaction_type_key,
  (valid_to = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
  transaction_type,
  valid_from,
  valid_to,
  wwi_transaction_type_id
FROM source

{% endif %}