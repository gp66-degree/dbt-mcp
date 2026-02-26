WITH stg_movement_raw AS (
  SELECT
    *
  FROM
    {{ ref('stg_movement') }}
),
stg_movement AS (
  SELECT
    stg_movement_raw.* EXCEPT (
      date_key,
      last_modified_when,
      quantity,
      wwi_customer_id,
      wwi_invoice_id,
      wwi_purchase_order_id,
      wwi_stock_item_id,
      wwi_stock_item_transaction_id,
      wwi_supplier_id,
      wwi_transaction_type_id
    ),
    SAFE_CAST(stg_movement_raw.date_key AS INT64) AS date_key,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%.f', stg_movement_raw.last_modified_when), SAFE_CAST(stg_movement_raw.last_modified_when AS TIMESTAMP)) AS last_modified_when,
    SAFE_CAST(stg_movement_raw.quantity AS BIGNUMERIC) AS quantity,
    SAFE_CAST(stg_movement_raw.wwi_customer_id AS INT64) AS wwi_customer_id,
    SAFE_CAST(stg_movement_raw.wwi_invoice_id AS INT64) AS wwi_invoice_id,
    SAFE_CAST(stg_movement_raw.wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
    SAFE_CAST(stg_movement_raw.wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
    SAFE_CAST(stg_movement_raw.wwi_stock_item_transaction_id AS INT64) AS wwi_stock_item_transaction_id,
    SAFE_CAST(stg_movement_raw.wwi_supplier_id AS INT64) AS wwi_supplier_id,
    SAFE_CAST(stg_movement_raw.wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id
  FROM
    stg_movement_raw
),
dim_customer AS (
  SELECT
    *
  FROM
    {{ ref('dim_customer') }}
),
dim_stock_item AS (
  SELECT
    *
  FROM
    {{ ref('dim_stock_item') }}
),
dim_supplier AS (
  SELECT
    *
  FROM
    {{ ref('dim_supplier') }}
),
dim_transaction_type AS (
  SELECT
    *
  FROM
    {{ ref('dim_transaction_type') }}
)
SELECT
  COALESCE(dim_customer.customer_key, 0) AS customer_key,
  stg_movement.date_key,
  stg_movement.last_modified_when,
  stg_movement.quantity,
  COALESCE(dim_stock_item.stock_item_key, 0) AS stock_item_key,
  COALESCE(dim_supplier.supplier_key, 0) AS supplier_key,
  COALESCE(dim_transaction_type.transaction_type_key, 0) AS transaction_type_key,
  stg_movement.wwi_customer_id,
  stg_movement.wwi_invoice_id,
  stg_movement.wwi_purchase_order_id,
  stg_movement.wwi_stock_item_id,
  stg_movement.wwi_stock_item_transaction_id,
  stg_movement.wwi_supplier_id,
  stg_movement.wwi_transaction_type_id
FROM
  stg_movement
  LEFT JOIN dim_customer
    ON stg_movement.wwi_customer_id = dim_customer.wwi_customer_id
    AND stg_movement.last_modified_when > dim_customer.valid_from
    AND stg_movement.last_modified_when <= dim_customer.valid_to
  LEFT JOIN dim_stock_item
    ON stg_movement.wwi_stock_item_id = dim_stock_item.wwi_stock_item_id
    AND stg_movement.last_modified_when > dim_stock_item.valid_from
    AND stg_movement.last_modified_when <= dim_stock_item.valid_to
  LEFT JOIN dim_supplier
    ON stg_movement.wwi_supplier_id = dim_supplier.wwi_supplier_id
    AND stg_movement.last_modified_when > dim_supplier.valid_from
    AND stg_movement.last_modified_when <= dim_supplier.valid_to
  LEFT JOIN dim_transaction_type
    ON stg_movement.wwi_transaction_type_id = dim_transaction_type.wwi_transaction_type_id
    AND stg_movement.last_modified_when > dim_transaction_type.valid_from
    AND stg_movement.last_modified_when <= dim_transaction_type.valid_to