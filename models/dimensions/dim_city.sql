{{ config(
  materialized='incremental',
  unique_key='city_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id,
    city,
    continent,
    country,
    SAFE_CAST(latest_recorded_population AS INT64) AS latest_recorded_population,
    location,
    region,
    sales_territory,
    state_province,
    subregion,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM {{ ref('int_city') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_city_id = t.wwi_city_id AND t.is_current = TRUE
  WHERE
    s.city <> t.city
    OR s.state_province <> t.state_province
    OR s.country <> t.country
    OR s.continent <> t.continent
    OR s.sales_territory <> t.sales_territory
    OR s.region <> t.region
    OR s.subregion <> t.subregion
    OR s.latest_recorded_population <> t.latest_recorded_population
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_city_id = t.wwi_city_id
  WHERE t.wwi_city_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_city_id,
    valid_from,
    valid_to,
    city,
    continent,
    country,
    latest_recorded_population,
    location,
    region,
    sales_territory,
    state_province,
    subregion
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_city_id,
    valid_from,
    valid_to,
    city,
    continent,
    country,
    latest_recorded_population,
    location,
    region,
    sales_territory,
    state_province,
    subregion
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_city_id', 'valid_from']) }} AS city_key,
    scd.wwi_city_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_city_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) OVER (PARTITION BY scd.wwi_city_id ORDER BY scd.valid_from) = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
    scd.city,
    scd.continent,
    scd.country,
    scd.latest_recorded_population,
    scd.location,
    scd.region,
    scd.sales_territory,
    scd.state_province,
    scd.subregion
  FROM scd_union AS scd
)

SELECT
  city,
  city_key,
  continent,
  country,
  is_current,
  latest_recorded_population,
  location,
  region,
  sales_territory,
  state_province,
  subregion,
  valid_from,
  valid_to,
  wwi_city_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_city_id', 'valid_from']) }} AS city_key,
  city,
  continent,
  country,
  (valid_to = SAFE_CAST('9999-12-31 23:59:59' AS TIMESTAMP)) AS is_current,
  latest_recorded_population,
  location,
  region,
  sales_territory,
  state_province,
  subregion,
  valid_from,
  valid_to,
  wwi_city_id
FROM source

{% endif %}