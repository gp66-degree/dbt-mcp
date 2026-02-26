{{ config(
  materialized='incremental',
  unique_key='customer_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
    bill_to_customer,
    buying_group,
    category,
    customer,
    postal_code,
    primary_contact
  FROM {{ ref('int_customer') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_customer_id = t.wwi_customer_id AND t.is_current = TRUE
  WHERE
    s.bill_to_customer <> t.bill_to_customer
    OR s.buying_group <> t.buying_group
    OR s.category <> t.category
    OR s.customer <> t.customer
    OR s.postal_code <> t.postal_code
    OR s.primary_contact <> t.primary_contact
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_customer_id = t.wwi_customer_id
  WHERE t.wwi_customer_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_customer_id,
    valid_from,
    valid_to,
    bill_to_customer,
    buying_group,
    category,
    customer,
    postal_code,
    primary_contact
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_customer_id,
    valid_from,
    valid_to,
    bill_to_customer,
    buying_group,
    category,
    customer,
    postal_code,
    primary_contact
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_customer_id', 'valid_from']) }} AS customer_key,
    scd.wwi_customer_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, TIMESTAMP '9999-12-31 23:59:59') OVER (PARTITION BY scd.wwi_customer_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, TIMESTAMP '9999-12-31 23:59:59') OVER (PARTITION BY scd.wwi_customer_id ORDER BY scd.valid_from) = TIMESTAMP '9999-12-31 23:59:59') AS is_current,
    scd.bill_to_customer,
    scd.buying_group,
    scd.category,
    scd.customer,
    scd.postal_code,
    scd.primary_contact
  FROM scd_union AS scd
)

SELECT
  bill_to_customer,
  buying_group,
  category,
  customer,
  customer_key,
  is_current,
  postal_code,
  primary_contact,
  valid_from,
  valid_to,
  wwi_customer_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_customer_id', 'valid_from']) }} AS customer_key,
  bill_to_customer,
  buying_group,
  category,
  customer,
  (valid_to = TIMESTAMP '9999-12-31 23:59:59') AS is_current,
  postal_code,
  primary_contact,
  valid_from,
  valid_to,
  wwi_customer_id
FROM source

{% endif %}