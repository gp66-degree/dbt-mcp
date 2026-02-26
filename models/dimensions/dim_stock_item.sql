{{ config(
  materialized='incremental',
  unique_key='stock_item_key',
  incremental_strategy='merge'
) }}

WITH source AS (
  SELECT
    SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_from), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', valid_to), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to,
    barcode,
    brand,
    buying_package,
    color,
    SAFE_CAST(is_chiller_stock AS BOOL) AS is_chiller_stock,
    SAFE_CAST(lead_time_days AS INT64) AS lead_time_days,
    photo,
    SAFE_CAST(quantity_per_outer AS INT64) AS quantity_per_outer,
    SAFE_CAST(recommended_retail_price AS NUMERIC) AS recommended_retail_price,
    selling_package,
    size,
    stock_item,
    SAFE_CAST(tax_rate AS NUMERIC) AS tax_rate,
    SAFE_CAST(typical_weight_per_unit AS NUMERIC) AS typical_weight_per_unit,
    SAFE_CAST(unit_price AS NUMERIC) AS unit_price
  FROM {{ ref('int_stock_item') }}
)

{% if is_incremental() %}

, cte_updates AS (
  SELECT
    s.*
  FROM source AS s
  INNER JOIN {{ this }} AS t
    ON s.wwi_stock_item_id = t.wwi_stock_item_id AND t.is_current = TRUE
  WHERE
    s.barcode <> t.barcode
    OR s.brand <> t.brand
    OR s.buying_package <> t.buying_package
    OR s.color <> t.color
    OR s.is_chiller_stock <> t.is_chiller_stock
    OR s.lead_time_days <> t.lead_time_days
    OR s.photo <> t.photo
    OR s.quantity_per_outer <> t.quantity_per_outer
    OR s.recommended_retail_price <> t.recommended_retail_price
    OR s.selling_package <> t.selling_package
    OR s.size <> t.size
    OR s.stock_item <> t.stock_item
    OR s.tax_rate <> t.tax_rate
    OR s.typical_weight_per_unit <> t.typical_weight_per_unit
    OR s.unit_price <> t.unit_price
)

, cte_new AS (
  SELECT
    s.*
  FROM source AS s
  LEFT JOIN {{ this }} AS t
    ON s.wwi_stock_item_id = t.wwi_stock_item_id
  WHERE t.wwi_stock_item_id IS NULL
)

, scd_union AS (
  SELECT
    wwi_stock_item_id,
    valid_from,
    valid_to,
    barcode,
    brand,
    buying_package,
    color,
    is_chiller_stock,
    lead_time_days,
    photo,
    quantity_per_outer,
    recommended_retail_price,
    selling_package,
    size,
    stock_item,
    tax_rate,
    typical_weight_per_unit,
    unit_price
  FROM cte_updates

  UNION ALL

  SELECT
    wwi_stock_item_id,
    valid_from,
    valid_to,
    barcode,
    brand,
    buying_package,
    color,
    is_chiller_stock,
    lead_time_days,
    photo,
    quantity_per_outer,
    recommended_retail_price,
    selling_package,
    size,
    stock_item,
    tax_rate,
    typical_weight_per_unit,
    unit_price
  FROM cte_new
)

, cte_final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['wwi_stock_item_id', 'valid_from']) }} AS stock_item_key,
    scd.wwi_stock_item_id,
    scd.valid_from,
    LEAD(scd.valid_from, 1, TIMESTAMP '9999-12-31 23:59:59') OVER (PARTITION BY scd.wwi_stock_item_id ORDER BY scd.valid_from) AS valid_to,
    (LEAD(scd.valid_from, 1, TIMESTAMP '9999-12-31 23:59:59') OVER (PARTITION BY scd.wwi_stock_item_id ORDER BY scd.valid_from) = TIMESTAMP '9999-12-31 23:59:59') AS is_current,
    scd.barcode,
    scd.brand,
    scd.buying_package,
    scd.color,
    scd.is_chiller_stock,
    scd.lead_time_days,
    scd.photo,
    scd.quantity_per_outer,
    scd.recommended_retail_price,
    scd.selling_package,
    scd.size,
    scd.stock_item,
    scd.tax_rate,
    scd.typical_weight_per_unit,
    scd.unit_price
  FROM scd_union AS scd
)

SELECT
  barcode,
  brand,
  buying_package,
  color,
  is_chiller_stock,
  is_current,
  lead_time_days,
  photo,
  quantity_per_outer,
  recommended_retail_price,
  selling_package,
  size,
  stock_item,
  stock_item_key,
  tax_rate,
  typical_weight_per_unit,
  unit_price,
  valid_from,
  valid_to,
  wwi_stock_item_id
FROM cte_final

{% else %}

SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_stock_item_id', 'valid_from']) }} AS stock_item_key,
  barcode,
  brand,
  buying_package,
  color,
  is_chiller_stock,
  (valid_to = TIMESTAMP '9999-12-31 23:59:59') AS is_current,
  lead_time_days,
  photo,
  quantity_per_outer,
  recommended_retail_price,
  selling_package,
  size,
  stock_item,
  tax_rate,
  typical_weight_per_unit,
  unit_price,
  valid_from,
  valid_to,
  wwi_stock_item_id
FROM source

{% endif %}