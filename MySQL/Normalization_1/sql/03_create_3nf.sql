USE normalization_1;

CREATE TABLE customers (
    customer_id   INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

CREATE TABLE products (
    product_id   INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_products_price CHECK (price >= 0)
);

CREATE TABLE reports (
    report_id   INT NOT NULL,
    report_date DATE NOT NULL,
    customer_id INT NOT NULL,
    CONSTRAINT pk_reports PRIMARY KEY (report_id),
    CONSTRAINT fk_reports_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE report_items (
    report_id  INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    CONSTRAINT pk_report_items PRIMARY KEY (report_id, product_id),
    CONSTRAINT fk_report_items_report
        FOREIGN KEY (report_id) REFERENCES reports (report_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_report_items_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_report_items_quantity CHECK (quantity > 0)
);

SHOW TABLES;

SELECT table_name, column_name, column_type, is_nullable, column_key
FROM information_schema.columns
WHERE table_schema = 'normalization_1'
  AND table_name IN ('customers', 'products', 'reports', 'report_items')
ORDER BY FIELD(table_name, 'customers', 'products', 'reports', 'report_items'), ordinal_position;

SELECT table_name, constraint_name, column_name,
       COALESCE(referenced_table_name, '-') AS references_table
FROM information_schema.key_column_usage
WHERE table_schema = 'normalization_1'
  AND table_name IN ('customers', 'products', 'reports', 'report_items')
ORDER BY table_name, constraint_name, ordinal_position;
