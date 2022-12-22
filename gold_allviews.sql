-- ADDING THE ATHENA SQL SCRIPT WHICH CREATES THE `gold_allviews` TABLE:
CREATE TABLE ayobishahana_homework.gold_allviews
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://ceu-shahana/datalake/gold_allviews'
) AS SELECT
article,
sum(views) as total_top_view,
min(rank) as top_rank,
count(date) as ranked_days
FROM ayobishahana_homework.silver_views 
GROUP BY article;
SELECT * FROM ayobishahana_homework.gold_allviews;
