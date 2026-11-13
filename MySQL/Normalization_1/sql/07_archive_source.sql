USE normalization_1;

RENAME TABLE sales_unnormalized_2 TO sales_unnormalized_2_archived;

SHOW TABLES;
SELECT COUNT(*) AS archived_source_rows
FROM sales_unnormalized_2_archived;
