WITH stg_purchase AS (
  SELECT
    *
  FROM
    {{ ref('stg_purchase') }}
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
casted_stg_purchase AS (
  SELECT
    SAFE_CAST(date_key AS DATE) AS date_key,
    SAFE_CAST(is_order_line_finalized AS BOOL) AS is_order_line_finalized,
    COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E6S', last_modified_when), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
    SAFE_CAST(ordered_outers AS INT64) AS ordered_outers,
    SAFE_CAST(ordered_quantity AS INT64) AS ordered_quantity,
    package,
    SAFE_CAST(received_outers AS INT64) AS received_outers,
    SAFE_CAST(wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
    SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
    SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id
  FROM
    stg_purchase
),
casted_dim_stock_item AS (
  SELECT
    SAFE_CAST(stock_item_key AS INT64) AS stock_item_key,
    SAFE_CAST(wwi_stock_item_id AS INT64) AS wwi_stock_item_id,
    SAFE_CAST(valid_from AS TIMESTAMP) AS valid_from,
    SAFE_CAST(valid_to AS TIMESTAMP) AS valid_to
  FROM
    dim_stock_item
),
casted_dim_supplier AS (
  SELECT
    SAFE_CAST(supplier_key AS INT64) AS supplier_key,
    SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id,
    SAFE_CAST(valid_from AS TIMESTAMP) AS valid_from,
    SAFE_CAST(valid_to AS TIMESTAMP) AS valid_to
  FROM
    dim_supplier
)
SELECT
  casted_stg_purchase.date_key,
  casted_stg_purchase.is_order_line_finalized,
  casted_stg_purchase.last_modified_when,
  casted_stg_purchase.ordered_outers,
  casted_stg_purchase.ordered_quantity,
  casted_stg_purchase.package,
  casted_stg_purchase.received_outers,
  COALESCE(casted_dim_stock_item.stock_item_key, 0) AS stock_item_key,
  COALESCE(casted_dim_supplier.supplier_key, 0) AS supplier_key,
  casted_stg_purchase.wwi_purchase_order_id,
  casted_stg_purchase.wwi_stock_item_id,
  casted_stg_purchase.wwi_supplier_id
FROM
  casted_stg_purchase
  LEFT JOIN casted_dim_supplier
    ON casted_stg_purchase.wwi_supplier_id = casted_dim_supplier.wwi_supplier_id
    AND casted_stg_purchase.last_modified_when > casted_dim_supplier.valid_from
    AND casted_stg_purchase.last_modified_when <= casted_dim_supplier.valid_to
  LEFT JOIN casted_dim_stock_item
    ON casted_stg_purchase.wwi_stock_item_id = casted_dim_stock_item.wwi_stock_item_id
    AND casted_stg_purchase.last_modified_when > casted_dim_stock_item.valid_from
    AND casted_stg_purchase.last_modified_when <= casted_dim_stock_item.valid_to