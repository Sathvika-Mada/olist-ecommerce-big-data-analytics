
-- 1. Clean orders
DROP TABLE IF EXISTS staging.orders;

CREATE TABLE staging.orders AS
SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    NULLIF(TRIM(customer_id), '') AS customer_id,
    NULLIF(TRIM(order_status), '') AS order_status,
    NULLIF(order_purchase_timestamp, '')::TIMESTAMP
        AS purchase_date,
    NULLIF(order_approved_at, '')::TIMESTAMP
        AS approved_date,
    NULLIF(order_delivered_carrier_date, '')::TIMESTAMP
        AS carrier_date,
    NULLIF(order_delivered_customer_date, '')::TIMESTAMP
        AS delivered_date,
    NULLIF(order_estimated_delivery_date, '')::TIMESTAMP
        AS estimated_delivery_date
FROM raw.orders;


-- 2. Clean order items
DROP TABLE IF EXISTS staging.order_items;

CREATE TABLE staging.order_items AS
SELECT
    order_id,
    order_item_id::INTEGER AS order_item_id,
    product_id,
    seller_id,
    shipping_limit_date::TIMESTAMP
        AS shipping_limit_date,
    price::NUMERIC AS price,
    freight_value::NUMERIC AS freight_value
FROM raw.order_items;


-- 3. Clean payments
DROP TABLE IF EXISTS staging.payments;

CREATE TABLE staging.payments AS
SELECT
    order_id,
    payment_sequential::INTEGER AS payment_sequential,
    payment_type,
    payment_installments::INTEGER AS payment_installments,
    payment_value::NUMERIC AS payment_value
FROM raw.payments;


-- 4. Clean reviews
DROP TABLE IF EXISTS staging.reviews;

CREATE TABLE staging.reviews AS
SELECT
    review_id,
    order_id,
    review_score::INTEGER AS review_score,
    NULLIF(review_creation_date, '')::TIMESTAMP
        AS review_creation_date,
    NULLIF(review_answer_timestamp, '')::TIMESTAMP
        AS review_answer_timestamp
FROM raw.reviews;


-- 5. Clean customers
DROP TABLE IF EXISTS staging.customers;

CREATE TABLE staging.customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM raw.customers;


-- 6. Clean sellers
DROP TABLE IF EXISTS staging.sellers;

CREATE TABLE staging.sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw.sellers;


-- 7. Clean products
DROP TABLE IF EXISTS staging.products;

CREATE TABLE staging.products AS
SELECT
    product_id,
    product_category_name,
    NULLIF(product_name_lenght, '')::INTEGER
        AS product_name_length,
    NULLIF(product_description_lenght, '')::INTEGER
        AS product_description_length,
    NULLIF(product_photos_qty, '')::INTEGER
        AS product_photos_qty,
    NULLIF(product_weight_g, '')::NUMERIC
        AS product_weight_g,
    NULLIF(product_length_cm, '')::NUMERIC
        AS product_length_cm,
    NULLIF(product_height_cm, '')::NUMERIC
        AS product_height_cm,
    NULLIF(product_width_cm, '')::NUMERIC
        AS product_width_cm
FROM raw.products;


-- 8. Clean geolocation
DROP TABLE IF EXISTS staging.geolocation;

CREATE TABLE staging.geolocation AS
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat::NUMERIC AS latitude,
    geolocation_lng::NUMERIC AS longitude,
    geolocation_city,
    geolocation_state
FROM raw.geolocation;


-- 9. Category translation
DROP TABLE IF EXISTS staging.category_translation;

CREATE TABLE staging.category_translation AS
SELECT
    product_category_name,
    product_category_name_english
FROM raw.category_translation;