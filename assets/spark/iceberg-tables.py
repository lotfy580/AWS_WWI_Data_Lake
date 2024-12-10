# Description: spark script to create all iceberg tables
# Author: Lotfy Ashmawy


from pyspark import SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, expr, lit
from datetime import datetime, timedelta
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DateType
import os

spark = (
    SparkSession.builder 
    .appName("Create iceberg tables")  
    .getOrCreate()
     )
    
bucket  = "devwwidatalakehouse"

    
# CREATE raw glue database which will be a snapshot of the source system without any changes
spark.sql(f"CREATE DATABASE IF NOT EXISTS glue_iceberg.wwi_raw LOCATION 's3://{bucket}/wwi_raw/';")
    
##################################
# CREATE raw zone iceberg tables #
##################################
spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.cities (
    city_id int NOT NULL,
    city_name string,
    stateprovince_id int,
    location string,
    latest_recorded_population bigint,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/cities/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (stateprovince_id)
"""
)
    
spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.countries (
    country_id int NOT NULL,
    country_name string NOT NULL,
    formal_name string NOT NULL,
    iso_alpha3_code string,
    iso_decimal_code int,
    country_type string,
    latest_recorded_population bigint,
    continent string NOT NULL,
    region string NOT NULL,
    subregion string NOT NULL,
    border string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/countries/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (continent)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.delivery_methods (
    delivery_method_id int NOT NULL,
    delivery_method_name string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/delivery_methods/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.payment_methods (
    payment_method_id int NOT NULL,
    payment_method_name string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/payment_methods/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.people (
    person_id int NOT NULL,
    full_name string NOT NULL,
    preferred_name string NOT NULL,
    search_name string NOT NULL,
    is_permitted_to_logon boolean NOT NULL,
    Logon_name string,
    is_external_logon_provider boolean NOT NULL,
    hashed_password binary,
    is_system_user boolean NOT NULL,
    is_employee boolean NOT NULL,
    is_sales_person boolean NOT NULL,
    user_preferences string,
    phone_number string,
    fax_number string,
    email_address string,
    photo binary,
    custom_fields string,
    other_languages string,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/people/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.state_provinces (
    state_provinces_id int NOT NULL,
    state_province_code string NOT NULL,
    state_province_name string NOT NULL,
    country_id int NOT NULL,
    sales_territory string NOT NULL,
    border string,
    latest_recorded_population bigint,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/state_provinces/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.system_parameters (
    system_parameter_id int NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_city_id int NOT NULL,
	delivery_postal_code string NOT NULL,
	delivery_location string NOT NULL,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_city_id int NOT NULL,
	postal_postal_code string NOT NULL,
	application_settings string NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/system_parameters/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.transaction_types (
    transaction_type_id int NOT NULL,
	transaction_type_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp,
	valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/transaction_types/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.purchase_order_lines (
    purchase_order_line_id int NOT NULL,
	purchase_order_id int NOT NULL,
	stock_item_id int NOT NULL,
	ordered_outers int NOT NULL,
	description string NOT NULL,
	received_outers int NOT NULL,
	package_type_id int NOT NULL,
	expected_unit_price_per_outer decimal(18, 2),
	last_receipt_date date,
	is_order_line_finalized boolean NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/purchase_order_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(last_receipt_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.purchase_orders (
    purchase_order_id int NOT NULL,
	supplier_id int NOT NULL,
	order_date date NOT NULL,
	delivery_method_id int NOT NULL,
	contactPerson_id int NOT NULL,
	expected_delivery_date date,
	supplier_reference string,
	is_order_finalized boolean NOT NULL,
	comments string,
	internal_comments string,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/purchase_orders/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(order_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.supplier_categories (
    supplier_category_id int NOT NULL,
	supplier_category_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp  NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/supplier_categories/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.suppliers (
    supplier_id int NOT NULL,
	supplier_name string NOT NULL,
	supplier_category_id int NOT NULL,
	primary_contact_person_id int NOT NULL,
	alternate_contact_person_id int NOT NULL,
	delivery_method_id int,
	delivery_city_id int NOT NULL,
	postal_city_id int NOT NULL,
	supplier_reference string,
	bank_account_name string,
	bank_account_branch string,
	bank_account_code string,
	bank_account_number string,
	bank_international_code string,
	payment_days int NOT NULL,
	internal_comments string,
	phone_number string NOT NULL,
	fax_number string NOT NULL,
	website_url string NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_postal_code string NOT NULL,
	delivery_location string,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_postal_code string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/suppliers/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.supplier_transactions (
    supplier_transaction_id int NOT NULL,
	supplier_id int NOT NULL,
	transaction_type_id int NOT NULL,
	purchase_order_id int,
	payment_method_id int,
	supplier_invoice_number string,
	transaction_date date NOT NULL,
	amount_excluding_tax decimal(18, 2) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	transaction_amount decimal(18, 2) NOT NULL,
	outstanding_balance decimal(18, 2) NOT NULL,
	finalization_date date,
	is_finalized boolean,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/supplier_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.buying_groups (
    buying_group_id int NOT NULL,
	buying_group_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/buying_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.customer_categories (
    customer_category_id int NOT NULL,
	customer_category_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/customer_categories/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.customers (
    customer_id int NOT NULL,
	customer_name string NOT NULL,
	bill_to_customer_id int NOT NULL,
	customer_category_id int NOT NULL,
	buying_group_id int,
	primary_contact_person_id int NOT NULL,
	alternate_contact_person_id int,
	delivery_method_id int NOT NULL,
	delivery_city_id int NOT NULL,
	postal_city_id int NOT NULL,
	credit_limit decimal(18, 2),
	accountOpened_date date NOT NULL,
	standard_discount_percentage decimal(18, 3) NOT NULL,
	is_statement_sent boolean NOT NULL,
	is_on_credit_hold boolean NOT NULL,
	payment_days int NOT NULL,
	phone_number string NOT NULL,
	fax_number string NOT NULL,
	delivery_run string,
	run_position string,
	website_url string NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_postal_code string NOT NULL,
	delivery_location string,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_postal_code string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/customers/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (buying_group_id)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.customer_transactions (
    customer_transaction_id int NOT NULL,
	customer_id int NOT NULL,
	transaction_type_id int NOT NULL,
	invoice_id int,
	payment_method_id int,
	transaction_date date NOT NULL,
	amount_excluding_tax decimal(18, 2) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	transaction_amount decimal(18, 2) NOT NULL,
	outstanding_balance decimal(18, 2) NOT NULL,
	finalization_date date,
	is_finalized boolean,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/customer_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.invoice_lines (
    invoiceLine_id int NOT NULL,
	invoice_id int NOT NULL,
	stockItem_id int NOT NULL,
	description string NOT NULL,
	package_type_id int NOT NULL,
	quantity int NOT NULL,
	unit_price decimal(18, 2),
	tax_rate decimal(18, 3) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	line_profit decimal(18, 2) NOT NULL,
	extended_price decimal(18, 2) NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/invoice_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, invoice_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.invoices (
    invoice_id int NOT NULL,
	customer_id int NOT NULL,
	billTo_customer_id int NOT NULL,
	order_id int,
	delivery_method_id int NOT NULL,
	contact_person_id int NOT NULL,
	accounts_person_id int NOT NULL,
	salesperson_person_id int NOT NULL,
	packed_by_person_id int NOT NULL,
	invoice_date date NOT NULL,
	customer_purchase_order_number string,
	is_credit_note boolean NOT NULL,
	credit_note_reason string,
	comments string,
	delivery_instructions string,
	internal_comments string,
	total_dry_items int NOT NULL,
	total_chiller_items int NOT NULL,
	delivery_run string,
	run_position string,
	returned_delivery_data string,
	confirmed_delivery_time timestamp,
	confirmed_received_by string,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/invoices/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, invoice_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.order_lines (
    order_line_id int NOT NULL,
	order_id int NOT NULL,
	stock_item_id int NOT NULL,
	description string NOT NULL,
	package_type_id int NOT NULL,
	quantity int NOT NULL,
	unit_price decimal(18, 2),
	tax_rate decimal(18, 3) NOT NULL,
	picked_quantity int NOT NULL,
	picking_completed_when timestamp,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/order_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, order_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.orders (
    order_id int NOT NULL,
	customer_id int NOT NULL,
	salesperson_person_id int NOT NULL,
	picked_by_person_id int,
	contact_person_id int NOT NULL,
	backorder_order_id int,
	order_date date NOT NULL,
	expected_delivery_date date NOT NULL,
	customer_purchase_order_number string,
	is_undersupply_backordered boolean NOT NULL,
	comments string,
	delivery_instructions string,
	internal_comments string,
	picking_completed_when timestamp,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/orders/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, order_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.special_deals (
    special_deal_id int NOT NULL,
	stock_item_id int,
	customer_id int,
	buying_group_id int,
	customer_category_id int,
	stock_group_id int,
	deal_description string NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	discount_amount decimal(18, 2),
	discount_percentage decimal(18, 3),
	unit_price decimal(18, 2),
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/special_deals/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.colors (
    color_id int NOT NULL,
	color_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/colors/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.package_types (
    package_type_id int NOT NULL,
	package_type_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/package_types/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.stock_groups (
    stock_group_id int NOT NULL,
    stock_group_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/stock_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.stock_item_holdings (
    stock_item_id int NOT NULL,
    quantity_on_hand int NOT NULL,
    bin_location string NOT NULL,
    last_stock_take_quantity int NOT NULL,
    last_cost_price decimal(18, 2) NOT NULL,
    reorder_level int NOT NULL,
    target_stock_level int NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/stock_item_holdings/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.stock_items(
    stock_item_id int NOT NULL,
    stock_item_name string NOT NULL,
    supplier_id int NOT NULL,
    color_id int,
    unit_package_id int NOT NULL,
    outer_package_id int NOT NULL,
    brand string,
    size string,
    lead_time_days int NOT NULL,
    quantity_perouter int NOT NULL,
    is_chiller_stock decimal(1,0) NOT NULL,
    barcode string,
    tax_rate decimal(18,3) NOT NULL,
    unit_price decimal(18,2) NOT NULL,
    recommended_retail_price decimal(18,2),
    typical_weight_per_unit decimal(18,3) NOT NULL,
    marketing_comments string,
    internal_comments string,
    photo binary,
    custom_fields string,
    tags string,
    search_details string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/stock_items/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.stock_item_stock_groups (
    stock_item_stock_group_id int NOT NULL ,
    stock_item_id int NOT NULL,
    stock_group_id int NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/stock_item_stock_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_raw.stock_item_transactions (
    stock_item_transaction_id int NOT NULL,
    stock_item_id int NOT NULL,
    transaction_type_id int NOT NULL,
    customer_id int,
    invoice_id int,
    supplier_id int,
    purchase_order_id int,
    transaction_occurred_when timestamp NOT NULL,
    quantity decimal(18,3) NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_raw/stock_item_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_occurred_when))
"""
)



# CREATE validated glue database which will be a snapshot of the source system without any changes
spark.sql(f"CREATE DATABASE IF NOT EXISTS glue_iceberg.wwi_validated LOCATION 's3://{bucket}/wwi_validated/';")
    
##################################
# CREATE validated zone iceberg tables #
##################################
spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.cities (
    city_id int NOT NULL,
    city_name string,
    stateprovince_id int,
    location string,
    latest_recorded_population bigint,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/cities/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (stateprovince_id)
"""
)
    
spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.countries (
    country_id int NOT NULL,
    country_name string NOT NULL,
    formal_name string NOT NULL,
    iso_alpha3_code string,
    iso_decimal_code int,
    country_type string,
    latest_recorded_population bigint,
    continent string NOT NULL,
    region string NOT NULL,
    subregion string NOT NULL,
    border string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/countries/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (continent)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.delivery_methods (
    delivery_method_id int NOT NULL,
    delivery_method_name string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/delivery_methods/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.payment_methods (
    payment_method_id int NOT NULL,
    payment_method_name string NOT NULL,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/payment_methods/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.people (
    person_id int NOT NULL,
    full_name string NOT NULL,
    preferred_name string NOT NULL,
    search_name string NOT NULL,
    is_permitted_to_logon boolean NOT NULL,
    Logon_name string,
    is_external_logon_provider boolean NOT NULL,
    hashed_password binary,
    is_system_user boolean NOT NULL,
    is_employee boolean NOT NULL,
    is_sales_person boolean NOT NULL,
    user_preferences string,
    phone_number string,
    fax_number string,
    email_address string,
    photo binary,
    custom_fields string,
    other_languages string,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/people/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.state_provinces (
    state_provinces_id int NOT NULL,
    state_province_code string NOT NULL,
    state_province_name string NOT NULL,
    country_id int NOT NULL,
    sales_territory string NOT NULL,
    border string,
    latest_recorded_population bigint,
    last_edited_by int,
    valid_from timestamp,
    valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/state_provinces/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.system_parameters (
    system_parameter_id int NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_city_id int NOT NULL,
	delivery_postal_code string NOT NULL,
	delivery_location string NOT NULL,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_city_id int NOT NULL,
	postal_postal_code string NOT NULL,
	application_settings string NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/system_parameters/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.transaction_types (
    transaction_type_id int NOT NULL,
	transaction_type_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp,
	valid_to timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/transaction_types/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.purchase_order_lines (
    purchase_order_line_id int NOT NULL,
	purchase_order_id int NOT NULL,
	stock_item_id int NOT NULL,
	ordered_outers int NOT NULL,
	description string NOT NULL,
	received_outers int NOT NULL,
	package_type_id int NOT NULL,
	expected_unit_price_per_outer decimal(18, 2),
	last_receipt_date date,
	is_order_line_finalized boolean NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/purchase_order_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(last_receipt_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.purchase_orders (
    purchase_order_id int NOT NULL,
	supplier_id int NOT NULL,
	order_date date NOT NULL,
	delivery_method_id int NOT NULL,
	contactPerson_id int NOT NULL,
	expected_delivery_date date,
	supplier_reference string,
	is_order_finalized boolean NOT NULL,
	comments string,
	internal_comments string,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/purchase_orders/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(order_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.supplier_categories (
    supplier_category_id int NOT NULL,
	supplier_category_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp  NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/supplier_categories/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.suppliers (
    supplier_id int NOT NULL,
	supplier_name string NOT NULL,
	supplier_category_id int NOT NULL,
	primary_contact_person_id int NOT NULL,
	alternate_contact_person_id int NOT NULL,
	delivery_method_id int,
	delivery_city_id int NOT NULL,
	postal_city_id int NOT NULL,
	supplier_reference string,
	bank_account_name string,
	bank_account_branch string,
	bank_account_code string,
	bank_account_number string,
	bank_international_code string,
	payment_days int NOT NULL,
	internal_comments string,
	phone_number string NOT NULL,
	fax_number string NOT NULL,
	website_url string NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_postal_code string NOT NULL,
	delivery_location string,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_postal_code string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/suppliers/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.supplier_transactions (
    supplier_transaction_id int NOT NULL,
	supplier_id int NOT NULL,
	transaction_type_id int NOT NULL,
	purchase_order_id int,
	payment_method_id int,
	supplier_invoice_number string,
	transaction_date date NOT NULL,
	amount_excluding_tax decimal(18, 2) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	transaction_amount decimal(18, 2) NOT NULL,
	outstanding_balance decimal(18, 2) NOT NULL,
	finalization_date date,
	is_finalized boolean,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/supplier_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.buying_groups (
    buying_group_id int NOT NULL,
	buying_group_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/buying_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.customer_categories (
    customer_category_id int NOT NULL,
	customer_category_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/customer_categories/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.customers (
    customer_id int NOT NULL,
	customer_name string NOT NULL,
	bill_to_customer_id int NOT NULL,
	customer_category_id int NOT NULL,
	buying_group_id int,
	primary_contact_person_id int NOT NULL,
	alternate_contact_person_id int,
	delivery_method_id int NOT NULL,
	delivery_city_id int NOT NULL,
	postal_city_id int NOT NULL,
	credit_limit decimal(18, 2),
	accountOpened_date date NOT NULL,
	standard_discount_percentage decimal(18, 3) NOT NULL,
	is_statement_sent boolean NOT NULL,
	is_on_credit_hold boolean NOT NULL,
	payment_days int NOT NULL,
	phone_number string NOT NULL,
	fax_number string NOT NULL,
	delivery_run string,
	run_position string,
	website_url string NOT NULL,
	delivery_address_line1 string NOT NULL,
	delivery_address_line2 string,
	delivery_postal_code string NOT NULL,
	delivery_location string,
	postal_address_line1 string NOT NULL,
	postal_address_line2 string,
	postal_postal_code string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/customers/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (buying_group_id)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.customer_transactions (
    customer_transaction_id int NOT NULL,
	customer_id int NOT NULL,
	transaction_type_id int NOT NULL,
	invoice_id int,
	payment_method_id int,
	transaction_date date NOT NULL,
	amount_excluding_tax decimal(18, 2) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	transaction_amount decimal(18, 2) NOT NULL,
	outstanding_balance decimal(18, 2) NOT NULL,
	finalization_date date,
	is_finalized boolean,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/customer_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_date))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.invoice_lines (
    invoiceLine_id int NOT NULL,
	invoice_id int NOT NULL,
	stockItem_id int NOT NULL,
	description string NOT NULL,
	package_type_id int NOT NULL,
	quantity int NOT NULL,
	unit_price decimal(18, 2),
	tax_rate decimal(18, 3) NOT NULL,
	tax_amount decimal(18, 2) NOT NULL,
	line_profit decimal(18, 2) NOT NULL,
	extended_price decimal(18, 2) NOT NULL,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/invoice_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, invoice_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.invoices (
    invoice_id int NOT NULL,
	customer_id int NOT NULL,
	billTo_customer_id int NOT NULL,
	order_id int,
	delivery_method_id int NOT NULL,
	contact_person_id int NOT NULL,
	accounts_person_id int NOT NULL,
	salesperson_person_id int NOT NULL,
	packed_by_person_id int NOT NULL,
	invoice_date date NOT NULL,
	customer_purchase_order_number string,
	is_credit_note boolean NOT NULL,
	credit_note_reason string,
	comments string,
	delivery_instructions string,
	internal_comments string,
	total_dry_items int NOT NULL,
	total_chiller_items int NOT NULL,
	delivery_run string,
	run_position string,
	returned_delivery_data string,
	confirmed_delivery_time timestamp,
	confirmed_received_by string,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/invoices/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, invoice_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.order_lines (
    order_line_id int NOT NULL,
	order_id int NOT NULL,
	stock_item_id int NOT NULL,
	description string NOT NULL,
	package_type_id int NOT NULL,
	quantity int NOT NULL,
	unit_price decimal(18, 2),
	tax_rate decimal(18, 3) NOT NULL,
	picked_quantity int NOT NULL,
	picking_completed_when timestamp,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/order_lines/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, order_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.orders (
    order_id int NOT NULL,
	customer_id int NOT NULL,
	salesperson_person_id int NOT NULL,
	picked_by_person_id int,
	contact_person_id int NOT NULL,
	backorder_order_id int,
	order_date date NOT NULL,
	expected_delivery_date date NOT NULL,
	customer_purchase_order_number string,
	is_undersupply_backordered boolean NOT NULL,
	comments string,
	delivery_instructions string,
	internal_comments string,
	picking_completed_when timestamp,
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/orders/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (bucket(10, order_id))
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.special_deals (
    special_deal_id int NOT NULL,
	stock_item_id int,
	customer_id int,
	buying_group_id int,
	customer_category_id int,
	stock_group_id int,
	deal_description string NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	discount_amount decimal(18, 2),
	discount_percentage decimal(18, 3),
	unit_price decimal(18, 2),
	last_edited_by int NOT NULL,
	last_edited_when timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/special_deals/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.colors (
    color_id int NOT NULL,
	color_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/colors/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.package_types (
    package_type_id int NOT NULL,
	package_type_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/package_types/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.stock_groups (
    stock_group_id int NOT NULL,
    stock_group_name string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/stock_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.stock_item_holdings (
    stock_item_id int NOT NULL,
    quantity_on_hand int NOT NULL,
    bin_location string NOT NULL,
    last_stock_take_quantity int NOT NULL,
    last_cost_price decimal(18, 2) NOT NULL,
    reorder_level int NOT NULL,
    target_stock_level int NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/stock_item_holdings/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.stock_items(
    stock_item_id int NOT NULL,
    stock_item_name string NOT NULL,
    supplier_id int NOT NULL,
    color_id int,
    unit_package_id int NOT NULL,
    outer_package_id int NOT NULL,
    brand string,
    size string,
    lead_time_days int NOT NULL,
    quantity_perouter int NOT NULL,
    is_chiller_stock decimal(1,0) NOT NULL,
    barcode string,
    tax_rate decimal(18,3) NOT NULL,
    unit_price decimal(18,2) NOT NULL,
    recommended_retail_price decimal(18,2),
    typical_weight_per_unit decimal(18,3) NOT NULL,
    marketing_comments string,
    internal_comments string,
    photo binary,
    custom_fields string,
    tags string,
    search_details string NOT NULL,
	last_edited_by int NOT NULL,
	valid_from timestamp NOT NULL,
	valid_to timestamp NOT NULL,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/stock_items/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.stock_item_stock_groups (
    stock_item_stock_group_id int NOT NULL ,
    stock_item_id int NOT NULL,
    stock_group_id int NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/stock_item_stock_groups/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_validated.stock_item_transactions (
    stock_item_transaction_id int NOT NULL,
    stock_item_id int NOT NULL,
    transaction_type_id int NOT NULL,
    customer_id int,
    invoice_id int,
    supplier_id int,
    purchase_order_id int,
    transaction_occurred_when timestamp NOT NULL,
    quantity decimal(18,3) NOT NULL,
    last_edited_by int NOT NULL,
    last_edited_when timestamp,
    batch_id bigint
)
USING iceberg
LOCATION 's3://{bucket}/wwi_validated/stock_item_transactions/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(transaction_occurred_when))
"""
)

validation_tables=["buying_groups", "cities", "countries", "customer_categories", "customer_transactions", "customers",
                   "delivery_methods", "invoice_lines", "invoices", "invoices", "order_lines", "orders", "package_types",
                   "payment_methods", "people", "purchase_order_lines", "purchase_orders", "special_deals", "state_provinces",
                   "stock_groups", "stock_item_holdings", "stock_item_stock_groups", "stock_item_transactions", "stock_items",
                   "supplier_categories", "supplier_transactions", "supplier_transactions", "suppliers", "system_parameters",
                   "transaction_types"]

for table in validation_tables:
    spark.sql(f"ALTER TABLE glue_iceberg.wwi_validated.{table} CREATE BRANCH IF NOT EXISTS main")


# CREATE DWH glue database 
spark.sql(f"CREATE DATABASE IF NOT EXISTS glue_iceberg.wwi_dwh LOCATION 's3://{bucket}/wwi_dwh/';")
    
##################################
# CREATE DWH zone iceberg tables #
##################################

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_date (
    date_key date NOT NULL,
    year int NOT NULL,
    month int NOT NULL,
    day_of_month int NOT NULL,
    month_name string NOT NULL,
    day_of_week int NOT NULL,
    day_name string NOT NULL,
    is_weekend int NOT NULL,
    quarter_of_year int NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_date/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (year, month)
"""
)

start_date = datetime(2000, 1, 1)
end_date = datetime(2030, 12, 31)

date_range = [(start_date + timedelta(days=i)) for i in range((end_date - start_date).days + 1)]

schema = StructType([
    StructField("date_key", DateType(), False),
    StructField("year", IntegerType(), False),
    StructField("month", IntegerType(), False),
    StructField("day_of_month", IntegerType(), False),
    StructField("day_of_week", IntegerType(), False),  
    StructField("month_name", StringType(), False),
    StructField("day_name", StringType(), False),
    StructField("quarter_of_year", IntegerType(), False),
    StructField("is_weekend", IntegerType(), False)  
])
date_df = spark.createDataFrame([(d,) for d in date_range], ["date_key"])
date_df = date_df \
    .withColumn("year", expr("year(date_key)")) \
    .withColumn("month", expr("month(date_key)")) \
    .withColumn("day_of_month", expr("day(date_key)")) \
    .withColumn("day_of_week", expr("dayofweek(date_key)")) \
    .withColumn("month_name", expr("date_format(date_key, 'MMMM')")) \
    .withColumn("day_name", expr("date_format(date_key, 'EEEE')")) \
    .withColumn("quarter_of_year", expr("quarter(date_key)")) \
    .withColumn("is_weekend", when(col("day_of_week").isin([1, 7]), lit(1)).otherwise(lit(0)))

date_df = spark.createDataFrame(date_df.rdd, schema=schema)

date_df.writeTo("glue_iceberg.wwi_dwh.dim_date").overwritePartitions()

spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_city (
    city_key int NOT NULL,
    city_id int NOT NULL,
    city string NOT NULL,
    state_province string NOT NULL,
    country string NOT NULL,
    continent string NOT NULL,
    sales_territory string NOT NULL,
    region string NOT NULL,
    subregion string NOT NULL,
    location string,
    latest_recorded_population bigint,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_city/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (state_province)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_customer (
    customer_key int NOT NULL,
    customer_id int NOT NULL,
    customer string NOT NULL,        
    bill_to_customer string NOT NULL,
    category string NOT NULL,
    buying_group string,     
    primary_contact string NOT NULL,  
    postal_code string NOT NULL,      
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_customer/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (category)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_employee (
    employee_key int NOT NULL,
    employee_id int NOT NULL,
    employee string NOT NULL,
    preferred_name string NOT NULL,
    is_salesperson boolean NOT NULL,
    Photo binary,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_employee/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_payment_method (
    payment_method_key int NOT NULL,
    payment_method_id int NOT NULL,
    payment_method string NOT NULL,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_payment_method/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_stock_item (
    stock_item_key int NOT NULL,
    stock_item_id int NOT NULL,
    stock_item string NOT NULL,
    color string NOT NULL,
    selling_package string NOT NULL,
    buying_package string NOT NULL,
    brand string,
    size string,
    lead_time_days int NOT NULL,
    quantity_per_outer int NOT NULL,
    is_chiller_stock boolean NOT NULL,
    barcode string,
    tax_rate decimal(18, 3) NOT NULL,
    unit_price decimal(18, 2) NOT NULL,
    recommended_retail_price decimal(18, 2),
    typical_weight_per_unit decimal(18, 3) NOT NULL,
    Photo binary,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_stock_item/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_supplier (
    supplier_key int NOT NULL,
    supplier_id int NOT NULL,
    supplier string NOT NULL,
    category string NOT NULL,
    primary_contact string NOT NULL,
    supplier_reference string,
    payment_days int NOT NULL,
    postal_code string NOT NULL,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_supplier/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.dim_transaction_type (
    transaction_type_key int NOT NULL,
    transaction_type_id int NOT NULL,
    transaction_type string NOT NULL,
    start_date timestamp NOT NULL,
    end_date timestamp,
    is_current boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/dim_transaction_type/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_movement (
    movement_key bigint NOT NULL,
    date_key date NOT NULL,
    stock_item_key int NOT NULL,
    customer_key int,
    supplier_key int,
    transaction_type_key int NOT NULL,
    stock_item_transaction_id int NOT NULL,
    Invoice_id int,
    purchase_order_id int,
    quantity int NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_movement/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (stock_item_key)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_order (
    order_key bigint NOT NULL,
    city_key int NOT NULL,
    customer_key int NOT NULL,
    stock_item_key int NOT NULL,
    order_date_key date NOT NULL,
    picked_date_key date,
    salesperson_key int NOT NULL,
    picker_key int,
    order_id int NOT NULL,
    backorder_id int,
    description string NOT NULL,
    package string NOT NULL,
    quantity int NOT NULL,
    unit_price decimal(18, 2) NOT NULL,
    tax_rate decimal(18, 3) NOT NULL,
    total_excluding_tax decimal(18, 2) NOT NULL,
    tax_amount decimal(18, 2) NOT NULL,
    total_including_tax decimal(18, 2) NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_order/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(order_date_key))
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_purchase (
    purchase_key bigint NOT NULL,
    date_key date NOT NULL,
    supplier_key int NOT NULL,
    stock_item_key int NOT NULL,
    purchase_order_id int ,
    ordered_outers int NOT NULL,
    ordered_quantity int NOT NULL,
    received_outers int NOT NULL,
    package string NOT NULL,
    is_order_finalized boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_purchase/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(date_key))
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_sales (
    sale_key bigint NOT NULL,
    city_key int NOT NULL,
    customer_key int NOT NULL,
    bill_to_customer_key int NOT NULL,
    stock_item_key int NOT NULL,
    invoice_date_key date NOT NULL,
    delivery_date_key date,
    salesperson_key int NOT NULL,
    invoice_id int NOT NULL,
    description string NOT NULL,
    package string NOT NULL,
    quantity int NOT NULL,
    unit_price decimal(18, 2) NOT NULL,
    tax_rate decimal(18, 3) NOT NULL,
    total_excluding_tax decimal(18, 2) NOT NULL,
    tax_amount decimal(18, 2) NOT NULL,
    profit decimal(18, 2) NOT NULL,
    total_including_tax decimal(18, 2) NOT NULL,
    total_dry_items int NOT NULL,
    total_chiller_items int NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_sales/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(invoice_date_key))
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_stock_holdings (
    stock_holding_key bigint NOT NULL,
    stock_item_key int NOT NULL,
    quantity_on_hand int NOT NULL,
    bin_location string NOT NULL,
    last_stocktake_quantity int NOT NULL,
    last_cost_price decimal(18, 2) NOT NULL,
    reorder_level int NOT NULL,
    target_stock_level int NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_stock_holdings/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (stock_item_key)
"""
)


spark.sql(
f"""
CREATE TABLE IF NOT EXISTS glue_iceberg.wwi_dwh.fact_transaction (
    transaction_key bigint NOT NULL,
    date_key date NOT NULL,
    customer_key int,
    bill_to_customer_key int,
    supplier_key int,
    transaction_type_key int NOT NULL,
    payment_method_key int,
    customer_transaction_id int,
    supplier_transaction_id int,
    invoice_id int,
    purchase_order_id int,
    supplier_invoice_number string,
    total_excluding_tax decimal(18, 2) NOT NULL,
    tax_amount decimal(18, 2) NOT NULL,
    total_including_tax decimal(18, 2) NOT NULL,
    outstanding_balance decimal(18, 2) NOT NULL,
    is_finalized boolean NOT NULL
)
USING iceberg
LOCATION 's3://{bucket}/wwi_dwh/fact_transaction/'
OPTIONS (
    "format-version"="2",
    'write.format.default'='parquet',
    'write.delete.format.default'='avro',
    'write.parquet.compression.codec'='snappy',
    'write.metadata.metrics.default'='none',
    'write.update.mode'='merge-on-read',
    'write.merge.mode'='merge-on-read',
    'read.parquet.vectorization.enabled'='true'
)
PARTITIONED BY (month(date_key))
"""
)

dwh_tables=[
    "dim_city", "dim_customer", "dim_employee", "dim_payment_method", "dim_stock_item", "dim_supplier",
    "dim_transaction_type", "fact_movement", "fact_order", "fact_purchase", "fact_sales", "fact_stock_holdings",
    "fact_transaction"
]

for table in dwh_tables:
    spark.sql(f"ALTER TABLE glue_iceberg.wwi_dwh.{table} CREATE BRANCH IF NOT EXISTS main")

spark.stop()

    
