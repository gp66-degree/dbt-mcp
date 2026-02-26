WITH source AS (
  SELECT
    *
  FROM
    {{ source('wwi', 'city') }}
)
SELECT
  CAST(City AS STRING) AS city,
  CAST(Continent AS STRING) AS continent,
  CAST(Country AS STRING) AS country,
  SAFE_CAST(`Latest Recorded Population` AS INT64) AS latest_recorded_population,
  CAST(Location AS STRING) AS location,
  CAST(Region AS STRING) AS region,
  CAST(`Sales Territory` AS STRING) AS sales_territory,
  CAST(`State Province` AS STRING) AS state_province,
  CAST(Subregion AS STRING) AS subregion,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid From` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid From` AS STRING)), SAFE_CAST(`Valid From` AS TIMESTAMP)) AS valid_from,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S%Ez', CAST(`Valid To` AS STRING)), SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S', CAST(`Valid To` AS STRING)), SAFE_CAST(`Valid To` AS TIMESTAMP)) AS valid_to,
  SAFE_CAST(`WWI City ID` AS INT64) AS wwi_city_id
FROM
  source
WHERE
  SAFE_CAST(`WWI City ID` AS INT64) IS NOT NULL