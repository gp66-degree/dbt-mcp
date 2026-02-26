WITH stg_sale AS (
  SELECT
    *
  FROM
    {{ ref('stg_sale') }}
),
dim_city AS (
  SELECT
    *
  FROM
    {{ ref('dim_city') }}
),
dim_customer AS (
  SELECT
    *
  FROM
    {{ ref('dim_customer') }}
),
dim_employee AS (
  SELECT
    *
  FROM
    {{ ref('dim_employee') }}
),
dim_stock_item AS (
  SELECT
    *
  FROM
    {{ ref('dim_stock_item') }}
)
SELECT
  COALESCE(bill_to_customer.customer_key, 0) AS bill_to_customer_key,
  COALESCE(dim_city.city_key, 0) AS city_key,
  COALESCE(dim_customer.customer_key, 0) AS customer_key,
  stg_sale.delivery_date_key,
  stg_sale.description,
  stg_sale.invoice_date_key,
  SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) AS last_modified_when,
  stg_sale.package,
  SAFE_CAST(stg_sale.profit AS NUMERIC) AS profit,
  SAFE_CAST(stg_sale.quantity AS INT64) AS quantity,
  COALESCE(dim_employee.employee_key, 0) AS salesperson_key,
  COALESCE(dim_stock_item.stock_item_key, 0) AS stock_item_key,
  SAFE_CAST(stg_sale.tax_amount AS NUMERIC) AS tax_amount,
  SAFE_CAST(stg_sale.tax_rate AS NUMERIC) AS tax_rate,
  SAFE_CAST(stg_sale.total_chiller_items AS INT64) AS total_chiller_items,
  SAFE_CAST(stg_sale.total_dry_items AS INT64) AS total_dry_items,
  SAFE_CAST(stg_sale.total_excluding_tax AS NUMERIC) AS total_excluding_tax,
  SAFE_CAST(stg_sale.total_including_tax AS NUMERIC) AS total_including_tax,
  SAFE_CAST(stg_sale.unit_price AS NUMERIC) AS unit_price,
  stg_sale.wwi_bill_to_customer_id,
  stg_sale.wwi_city_id,
  stg_sale.wwi_customer_id,
  stg_sale.wwi_invoice_id,
  stg_sale.wwi_salesperson_id,
  stg_sale.wwi_stock_item_id
FROM
  stg_sale
  LEFT JOIN dim_city
    ON stg_sale.wwi_city_id = dim_city.wwi_city_id
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) > SAFE_CAST(dim_city.valid_from AS TIMESTAMP)
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) <= SAFE_CAST(dim_city.valid_to AS TIMESTAMP)
  LEFT JOIN dim_customer
    ON stg_sale.wwi_customer_id = dim_customer.wwi_customer_id
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) > SAFE_CAST(dim_customer.valid_from AS TIMESTAMP)
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) <= SAFE_CAST(dim_customer.valid_to AS TIMESTAMP)
  LEFT JOIN dim_customer AS bill_to_customer
    ON stg_sale.wwi_bill_to_customer_id = bill_to_customer.wwi_customer_id
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) > SAFE_CAST(bill_to_customer.valid_from AS TIMESTAMP)
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) <= SAFE_CAST(bill_to_customer.valid_to AS TIMESTAMP)
  LEFT JOIN dim_stock_item
    ON stg_sale.wwi_stock_item_id = dim_stock_item.wwi_stock_item_id
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) > SAFE_CAST(dim_stock_item.valid_from AS TIMESTAMP)
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) <= SAFE_CAST(dim_stock_item.valid_to AS TIMESTAMP)
  LEFT JOIN dim_employee
    ON stg_sale.wwi_salesperson_id = dim_employee.wwi_employee_id
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) > SAFE_CAST(dim_employee.valid_from AS TIMESTAMP)
    AND SAFE_CAST(stg_sale.last_modified_when AS TIMESTAMP) <= SAFE_CAST(dim_employee.valid_to AS TIMESTAMP)