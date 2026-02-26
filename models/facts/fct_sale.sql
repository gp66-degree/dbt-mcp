{{ config(
  materialized='incremental',
  unique_key='sale_key',
  incremental_strategy='merge',
  partition_by={
    "field": "invoice_date_key",
    "data_type": "date",
    "granularity": "day"
  },
  cluster_by=["city_key", "customer_key", "stock_item_key"]
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_sale') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_invoice_id', 'description']) }} AS sale_key,
  SAFE_CAST(bill_to_customer_key AS INT64) AS bill_to_customer_key,
  SAFE_CAST(city_key AS INT64) AS city_key,
  SAFE_CAST(customer_key AS INT64) AS customer_key,
  SAFE_CAST(delivery_date_key AS DATE) AS delivery_date_key,
  description,
  SAFE_CAST(invoice_date_key AS DATE) AS invoice_date_key,
  COALESCE(SAFE.PARSE_TIMESTAMP('%F %T', last_modified_when), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
  package,
  SAFE_CAST(profit AS NUMERIC) AS profit,
  SAFE_CAST(quantity AS INT64) AS quantity,
  SAFE_CAST(salesperson_key AS INT64) AS salesperson_key,
  SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
  SAFE_CAST(tax_amount AS NUMERIC) AS tax_amount,
  SAFE_CAST(tax_rate AS NUMERIC) AS tax_rate,
  SAFE_CAST(total_chiller_items AS INT64) AS total_chiller_items,
  SAFE_CAST(total_dry_items AS INT64) AS total_dry_items,
  SAFE_CAST(total_excluding_tax AS NUMERIC) AS total_excluding_tax,
  SAFE_CAST(total_including_tax AS NUMERIC) AS total_including_tax,
  SAFE_CAST(unit_price AS NUMERIC) AS unit_price,
  SAFE_CAST(wwi_bill_to_customer_id AS INT64) AS wwi_bill_to_customer_id,
  SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id,
  SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
  SAFE_CAST(wwi_invoice_id AS INT64) AS wwi_invoice_id,
  SAFE_CAST(wwi_salesperson_id AS INT64) AS wwi_salesperson_id,
  SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id
FROM
  source
{% if is_incremental() %}
WHERE
  invoice_date_key >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
{% endif %}