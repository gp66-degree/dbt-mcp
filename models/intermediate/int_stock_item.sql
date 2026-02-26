WITH source AS (
  SELECT
    *
  FROM
    {{ ref('stg_stock_item') }}
)
SELECT
  barcode,
  brand,
  buying_package,
  color,
  SAFE_CAST(is_chiller_stock AS BOOL) AS is_chiller_stock,
  SAFE_CAST(lead_time_days AS INT64) AS lead_time_days,
  photo,
  SAFE_CAST(quantity_per_outer AS INT64) AS quantity_per_outer,
  SAFE_CAST(recommended_retail_price AS BIGNUMERIC) AS recommended_retail_price,
  selling_package,
  size,
  stock_item,
  SAFE_CAST(tax_rate AS BIGNUMERIC) AS tax_rate,
  SAFE_CAST(typical_weight_per_unit AS BIGNUMERIC) AS typical_weight_per_unit,
  SAFE_CAST(unit_price AS BIGNUMERIC) AS unit_price,
  SAFE_CAST(valid_from AS TIMESTAMP) AS valid_from,
  SAFE_CAST(valid_to AS TIMESTAMP) AS valid_to,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id
FROM
  source