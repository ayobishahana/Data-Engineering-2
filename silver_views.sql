-- ADDING THE ATHENA SQL SCRIPT WHICH CREATES THE `silver_views` TABLE:

CREATE TABLE ayobishahana_homework.silver_views
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://ceu-shahana/datalake/views_silver'
) AS SELECT article, views, rank, date
FROM ayobishahana_homework.bronze_views 
WHERE date IS NOT NULL;

SELECT * FROM ayobishahana_homework.silver_views;
 