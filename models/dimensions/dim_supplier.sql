{{ config(
  materialized='incremental',
  unique_key='supplier_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id,
    category,
    SAFE_CAST(payment_days AS INT64) AS payment_days,
    SAFE_CAST(postal_code AS STRING) AS postal_code,
    primary_contact,
    supplier,
    supplier_reference,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM {{ ref('int_supplier') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_supplier_id = t.wwi_supplier_id AND t.is_current = TRUE
  WHERE
    s.category <> t.category
    OR s.payment_days <> t.payment_days
    OR s.postal_code <> t.postal_code
    OR s.primary_contact <> t.primary_contact
    OR s.supplier <> t.supplier
    OR s.supplier_reference <> t.supplier_reference
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_supplier_id = t.wwi_supplier_id
  WHERE t.wwi_supplier_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_supplier_id,
    valid_from,
    valid_to,
    category,
    payment_days,
    postal_code,
    primary_contact,
    supplier,
    supplier_reference
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_supplier_id,
    valid_from,
    valid_to,
    category,
    payment_days,
    postal_code,
    primary_contact,
    supplier,
    supplier_reference
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_supplier_id', 'valid_from']) }} AS supplier_key,
    scd.wwi_supplier_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_supplier_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_supplier_id ORDER BY scd.valid_from) = CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
    scd.category,
    scd.payment_days,
    scd.postal_code,
    scd.primary_contact,
    scd.supplier,
    scd.supplier_reference
  FROM scd_union AS scd
)

SELECT
  category,
  is_current,
  payment_days,
  postal_code,
  primary_contact,
  supplier,
  supplier_key,
  supplier_reference,
  valid_from,
  valid_to,
  wwi_supplier_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_supplier_id', 'valid_from']) }} AS supplier_key,
  category,
  (valid_to = CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
  payment_days,
  primary_contact,
  postal_code,
  supplier,
  supplier_reference,
  valid_from,
  valid_to,
  wwi_supplier_id
FROM source

{% endif %}