{{ config(
  materialized='incremental',
  unique_key='transaction_key',
  incremental_strategy='merge',
  partition_by={
    "field": "date_key",
    "data_type": "date",
    "granularity": "day"
  },
  cluster_by=["bill_to_customer_key", "customer_key", "supplier_key"]
) }}

WITH source AS (
  SELECT
    *
  FROM
    {{ ref('int_transaction') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['wwi_customer_transaction_id', 'wwi_supplier_transaction_id']) }} AS transaction_key,
  SAFE_CAST(bill_to_customer_key AS INT64) AS bill_to_customer_key,
  SAFE_CAST(customer_key AS INT64) AS customer_key,
  SAFE_CAST(date_key AS DATE) AS date_key,
  SAFE_CAST(is_finalized AS BOOL) AS is_finalized,
  COALESCE(SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%E*S', SAFE_CAST(last_modified_when AS STRING)), SAFE_CAST(last_modified_when AS TIMESTAMP)) AS last_modified_when,
  SAFE_CAST(outstanding_balance AS BIGNUMERIC) AS outstanding_balance,
  SAFE_CAST(payment_method_key AS INT64) AS payment_method_key,
  SAFE_CAST(supplier_invoice_number AS STRING) AS supplier_invoice_number,
  SAFE_CAST(supplier_key AS INT64) AS supplier_key,
  SAFE_CAST(tax_amount AS BIGNUMERIC) AS tax_amount,
  SAFE_CAST(total_excluding_tax AS BIGNUMERIC) AS total_excluding_tax,
  SAFE_CAST(total_including_tax AS BIGNUMERIC) AS total_including_tax,
  SAFE_CAST(transaction_type_key AS INT64) AS transaction_type_key,
  SAFE_CAST(wwi_bill_to_customer_id AS INT64) AS wwi_bill_to_customer_id,
  SAFE_CAST(wwi_customer_id AS INT64) AS wwi_customer_id,
  SAFE_CAST(wwi_customer_transaction_id AS INT64) AS wwi_customer_transaction_id,
  SAFE_CAST(wwi_invoice_id AS INT64) AS wwi_invoice_id,
  SAFE_CAST(wwi_payment_method_id AS INT64) AS wwi_payment_method_id,
  SAFE_CAST(wwi_purchase_order_id AS INT64) AS wwi_purchase_order_id,
  SAFE_CAST(wwi_supplier_id AS INT64) AS wwi_supplier_id,
  SAFE_CAST(wwi_supplier_transaction_id AS INT64) AS wwi_supplier_transaction_id,
  SAFE_CAST(wwi_transaction_type_id AS INT64) AS wwi_transaction_type_id
FROM
  source
{% if is_incremental() %}
WHERE
  SAFE_CAST(date_key AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
{% endif %}