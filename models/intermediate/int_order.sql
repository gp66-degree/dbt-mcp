WITH stg_order AS (
  SELECT
    description,
    COALESCE(SAFE.PARSE_TIMESTAMP(last_modified_when, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
    SAFE_CAST(order_date_key AS INT64) AS order_date_key,
    package,
    SAFE_CAST(picked_date_key AS INT64) AS picked_date_key,
    SAFE_CAST(quantity AS NUMERIC) AS quantity,
    SAFE_CAST(tax_amount AS NUMERIC) AS tax_amount,
    SAFE_CAST(tax_rate AS NUMERIC) AS tax_rate,
    SAFE_CAST(total_excluding_tax AS NUMERIC) AS total_excluding_tax,
    SAFE_CAST(total_including_tax AS NUMERIC) AS total_including_tax,
    SAFE_CAST(unit_price AS NUMERIC) AS unit_price,
    SAFE_CAST(wwi_backorder_id AS INT64) AS wwi_backorder_id,
    SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id,
    SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
    SAFE_CAST(wwi_order_id AS INT64) AS wwi_order_id,
    SAFE_CAST(wwi_picker_id AS INT64) AS wwi_picker_id,
    SAFE_CAST(wwi_salesperson_id AS INT64) AS wwi_salesperson_id,
    SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id
  FROM
    {{ ref('stg_order') }}
),
dim_city AS (
  SELECT
    SAFE_CAST(city_key AS INT64) AS city_key,
    SAFE_CAST(wwi_city_id AS INT64) AS wwi_city_id,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_from, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_to, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM
    {{ ref('dim_city') }}
),
dim_customer AS (
  SELECT
    SAFE_CAST(customer_key AS INT64) AS customer_key,
    SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_from, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_to, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM
    {{ ref('dim_customer') }}
),
dim_employee AS (
  SELECT
    SAFE_CAST(employee_key AS INT64) AS employee_key,
    SAFE_CAST(wwi_employee_id AS INT64) AS wwi_employee_id,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_from, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_to, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM
    {{ ref('dim_employee') }}
),
dim_stock_item AS (
  SELECT
    SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
    SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_from, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_from AS TIMESTAMP)) AS valid_from,
    COALESCE(SAFE.PARSE_TIMESTAMP(valid_to, '%Y-%m-%d %H:%M:%S%.f'), SAFE_CAST(valid_to AS TIMESTAMP)) AS valid_to
  FROM
    {{ ref('dim_stock_item') }}
)
SELECT
  COALESCE(dim_city.city_key, 0) AS city_key,
  COALESCE(dim_customer.customer_key, 0) AS customer_key,
  stg_order.description,
  stg_order.last_modified_when,
  stg_order.order_date_key,
  stg_order.package,
  stg_order.picked_date_key,
  COALESCE(picker.employee_key, 0) AS picker_key,
  stg_order.quantity,
  COALESCE(salesperson.employee_key, 0) AS salesperson_key,
  COALESCE(dim_stock_item.stock_item_key, 0) AS stock_item_key,
  stg_order.tax_amount,
  stg_order.tax_rate,
  stg_order.total_excluding_tax,
  stg_order.total_including_tax,
  stg_order.unit_price,
  stg_order.wwi_backorder_id,
  stg_order.wwi_city_id,
  stg_order.wwi_customer_id,
  stg_order.wwi_order_id,
  stg_order.wwi_picker_id,
  stg_order.wwi_salesperson_id,
  stg_order.wwi_stock_item_id
FROM
  stg_order
  LEFT JOIN dim_city
    ON stg_order.wwi_city_id = dim_city.wwi_city_id
    AND stg_order.last_modified_when > dim_city.valid_from
    AND stg_order.last_modified_when <= dim_city.valid_to
  LEFT JOIN dim_customer
    ON stg_order.wwi_customer_id = dim_customer.wwi_customer_id
    AND stg_order.last_modified_when > dim_customer.valid_from
    AND stg_order.last_modified_when <= dim_customer.valid_to
  LEFT JOIN dim_stock_item
    ON stg_order.wwi_stock_item_id = dim_stock_item.wwi_stock_item_id
    AND stg_order.last_modified_when > dim_stock_item.valid_from
    AND stg_order.last_modified_when <= dim_stock_item.valid_to
  LEFT JOIN dim_employee AS salesperson
    ON stg_order.wwi_salesperson_id = salesperson.wwi_employee_id
    AND stg_order.last_modified_when > salesperson.valid_from
    AND stg_order.last_modified_when <= salesperson.valid_to
  LEFT JOIN dim_employee AS picker
    ON stg_order.wwi_picker_id = picker.wwi_employee_id
    AND stg_order.last_modified_when > picker.valid_from
    AND stg_order.last_modified_when <= picker.valid_to