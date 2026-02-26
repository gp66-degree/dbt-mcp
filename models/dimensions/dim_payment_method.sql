{{ config(
  materialized='incremental',
  unique_key='payment_method_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    wwi_payment_method_id,
    -- Robustly parse/cast valid_from to TIMESTAMP
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    -- Robustly parse/cast valid_to to TIMESTAMP
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
    payment_method
  FROM {{ ref('int_payment_method') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_payment_method_id = t.wwi_payment_method_id AND t.is_current = TRUE
  WHERE
    s.payment_method <> t.payment_method
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_payment_method_id = t.wwi_payment_method_id
  WHERE t.wwi_payment_method_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_payment_method_id,
    valid_from,
    valid_to,
    payment_method
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_payment_method_id,
    valid_from,
    valid_to,
    payment_method
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_payment_method_id', 'valid_from']) }} AS payment_method_key,
    scd.wwi_payment_method_id,
    scd.valid_from,
    -- Cast default value to TIMESTAMP
    LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_payment_method_id ORDER BY scd.valid_from) AS valid_to,
    -- Compare TIMESTAMP with TIMESTAMP
    (LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_payment_method_id ORDER BY scd.valid_from) = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
    scd.payment_method
  FROM scd_union AS scd
)

SELECT
  is_current,
  payment_method,
  payment_method_key,
  valid_from,
  valid_to,
  wwi_payment_method_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_payment_method_id', 'valid_from']) }} AS payment_method_key,
  -- Compare TIMESTAMP with TIMESTAMP
  (valid_to = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
  payment_method,
  valid_from,
  valid_to,
  wwi_payment_method_id
FROM source

{% endif %}