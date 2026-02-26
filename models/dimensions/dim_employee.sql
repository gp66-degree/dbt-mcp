{{ config(
  materialized='incremental',
  unique_key='employee_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_employee_id AS INT64) AS wwi_employee_id,
    COALESCE(
        SAFE.PARSE_TIMESTAMP('%F %T', wwi_valid_from), -- Assuming wwi_valid_from is the column name in int_employee
        SAFE_CAST(wwi_valid_from AS TIMESTAMP)
    ) AS valid_from,
    COALESCE(
        SAFE.PARSE_TIMESTAMP('%F %T', wwi_valid_to), -- Assuming wwi_valid_to is the column name in int_employee
        SAFE_CAST(wwi_valid_to AS TIMESTAMP)
    ) AS valid_to,
    SAFE_CAST(employee AS STRING) AS employee,
    SAFE_CAST(is_salesperson AS BOOL) AS is_salesperson,
    SAFE_CAST(photo AS STRING) AS photo, -- Assuming photo is a STRING, adjust to BYTES if needed
    SAFE_CAST(preferred_name AS STRING) AS preferred_name
  FROM {{ ref('int_employee') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_employee_id = t.wwi_employee_id AND t.is_current = TRUE
  WHERE
    s.employee <> t.employee
    OR s.is_salesperson <> t.is_salesperson
    OR s.photo <> t.photo
    OR s.preferred_name <> t.preferred_name
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_employee_id = t.wwi_employee_id
  WHERE t.wwi_employee_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_employee_id,
    valid_from,
    valid_to,
    employee,
    is_salesperson,
    photo,
    preferred_name
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_employee_id,
    valid_from,
    valid_to,
    employee,
    is_salesperson,
    photo,
    preferred_name
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_employee_id', 'valid_from']) }} AS employee_key,
    scd.wwi_employee_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_employee_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_employee_id ORDER BY scd.valid_from) = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
    scd.employee,
    scd.is_salesperson,
    scd.photo,
    scd.preferred_name
  FROM scd_union AS scd
)

SELECT
  employee,
  employee_key,
  is_current,
  is_salesperson,
  photo,
  preferred_name,
  valid_from,
  valid_to,
  wwi_employee_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_employee_id', 'valid_from']) }} AS employee_key,
  employee,
  (valid_to = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
  is_salesperson,
  photo,
  preferred_name,
  valid_from,
  valid_to,
  wwi_employee_id
FROM source

{% endif %}