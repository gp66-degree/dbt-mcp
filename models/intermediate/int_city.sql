WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_city') }}
)
SELECT
  city,
  continent,
  country,
  SAFE_CAST(latest_recorded_population AS INT64) AS latest_recorded_population,
  SAFE_CAST(location AS GEOGRAPHY) AS location,
  region,
  sales_territory,
  state_province,
  subregion,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%E*S%F%Ez', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%E*S%F%Ez', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id
FROM
  source