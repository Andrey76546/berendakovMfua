-- Этап 3. Схема в третьей нормальной форме.
USE sales_norm_2;

CREATE TABLE clients (
    client_id   INT          NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    client_city VARCHAR(100) NOT NULL,
    CONSTRAINT pk_clients PRIMARY KEY (client_id)
);

CREATE TABLE products (
    product_id   INT           NOT NULL,
    product_name VARCHAR(100)  NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_products_unit_price CHECK (unit_price >= 0)
);

CREATE TABLE sales (
    sale_id   INT  NOT NULL,
    sale_date DATE NOT NULL,
    client_id INT  NOT NULL,
    CONSTRAINT pk_sales PRIMARY KEY (sale_id),
    CONSTRAINT fk_sales_client
        FOREIGN KEY (client_id) REFERENCES clients (client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE sale_items (
    sale_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    CONSTRAINT pk_sale_items PRIMARY KEY (sale_id, product_id),
    CONSTRAINT fk_sale_items_sale
        FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sale_items_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_sale_items_quantity CHECK (quantity > 0)
);

SELECT table_name, engine, table_collation
FROM information_schema.tables
WHERE table_schema = 'sales_norm_2'
ORDER BY table_name;
