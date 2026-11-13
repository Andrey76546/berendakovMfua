USE normalization_1;

INSERT INTO customers (customer_id, customer_name)
SELECT DISTINCT customer_id, customer_name
FROM sales_unnormalized_2;

INSERT INTO products (product_id, product_name, price)
SELECT DISTINCT product_id, product_name, price
FROM sales_unnormalized_2;

INSERT INTO reports (report_id, report_date, customer_id)
SELECT DISTINCT report_id, report_date, customer_id
FROM sales_unnormalized_2;

INSERT INTO report_items (report_id, product_id, quantity)
SELECT report_id, product_id, quantity
FROM sales_unnormalized_2;

SELECT (SELECT COUNT(*) FROM customers) AS customers_inserted,
       (SELECT COUNT(*) FROM products) AS products_inserted,
       (SELECT COUNT(*) FROM reports) AS reports_inserted,
       (SELECT COUNT(*) FROM report_items) AS report_items_inserted;
