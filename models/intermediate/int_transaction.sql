WITH stg_transaction AS (
  SELECT
    *
  FROM
    {{ ref('stg_transaction') }}
),
dim_customer AS (
  SELECT
    *
  FROM
    {{ ref('dim_customer') }}
),
dim_payment_method AS (
  SELECT
    *
  FROM
    {{ ref('dim_payment_method') }}
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
  COALESCE(dim_customer.customer_key, 0) AS customer_key, -- bill_to_customer.customer_key was ambiguous, changed to dim_customer.customer_key
  COALESCE(bill_to_customer.customer_key, 0) AS bill_to_customer_key,
  stg_transaction.date_key, -- Assuming date_key is already an appropriate type (e.g., INT64 or DATE)
  SAFE_CAST(stg_transaction.is_finalized AS BOOLEAN) AS is_finalized,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(stg_transaction.outstanding_balance AS BIGNUMERIC) AS outstanding_balance,
  COALESCE(dim_payment_method.payment_method_key, 0) AS payment_method_key,
  stg_transaction.supplier_invoice_number, -- Assuming STRING
  COALESCE(dim_supplier.supplier_key, 0) AS supplier_key,
  SAFE_CAST(stg_transaction.tax_amount AS BIGNUMERIC) AS tax_amount,
  SAFE_CAST(stg_transaction.total_excluding_tax AS BIGNUMERIC) AS total_excluding_tax,
  SAFE_CAST(stg_transaction.total_including_tax AS BIGNUMERIC) AS total_including_tax,
  COALESCE(dim_transaction_type.transaction_type_key, 0) AS transaction_type_key,
  SAFE_CAST(stg_transaction.wwi_bill_to_customer_id AS INT64) AS wwi_bill_to_customer_id,
  SAFE_CAST(stg_transaction.wwi_customer_id AS INT64) AS wwi_customer_id,
  SAFE_CAST(stg_transaction.wwi_customer_transaction_id AS INT64) AS wwi_customer_transaction_id,
  SAFE_CAST(stg_transaction.wwi_invoice_id AS INT64) AS wwi_invoice_id,
  SAFE_CAST(stg_transaction.wwi_payment_method_id AS INT64) AS wwi_payment_method_id,
  SAFE_CAST(stg_transaction.wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(stg_transaction.wwi_supplier_id AS INT64) AS wwi_supplier_id,
  SAFE_CAST(stg_transaction.wwi_supplier_transaction_id AS INT64) AS wwi_supplier_transaction_id,
  SAFE_CAST(stg_transaction.wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id
FROM
  stg_transaction
  LEFT JOIN dim_customer
    ON SAFE_CAST(stg_transaction.wwi_customer_id AS INT64) = SAFE_CAST(dim_customer.wwi_customer_id AS INT64)
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) > dim_customer.valid_from
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) <= dim_customer.valid_to
  LEFT JOIN dim_customer AS bill_to_customer
    ON SAFE_CAST(stg_transaction.wwi_bill_to_customer_id AS INT64) = SAFE_CAST(bill_to_customer.wwi_customer_id AS INT64)
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) > bill_to_customer.valid_from
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) <= bill_to_customer.valid_to
  LEFT JOIN dim_supplier
    ON SAFE_CAST(stg_transaction.wwi_supplier_id AS INT64) = SAFE_CAST(dim_supplier.wwi_supplier_id AS INT64)
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) > dim_supplier.valid_from
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) <= dim_supplier.valid_to
  LEFT JOIN dim_transaction_type
    ON SAFE_CAST(stg_transaction.wwi_transaction_type_id AS INT64) = SAFE_CAST(dim_transaction_type.wwi_transaction_type_id AS INT64)
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) > dim_transaction_type.valid_from
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) <= dim_transaction_type.valid_to
  LEFT JOIN dim_payment_method
    ON SAFE_CAST(stg_transaction.wwi_payment_method_id AS INT64) = SAFE_CAST(dim_payment_method.wwi_payment_method_id AS INT64)
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) > dim_payment_method.valid_from
    AND COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', stg_transaction.last_modified_when), SAFE_CAST(stg_transaction.last_modified_when AS TIMESTAMP)) <= dim_payment_method.valid_to