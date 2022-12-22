-- ADDING THE ATHENA SQL SCRIPT WHICH CREATES THE `bronze_views` TABLE:
CREATE DATABASE ayobishahana_homework;

DROP TABLE ayobishahana_homework.bronze_views;
CREATE EXTERNAL TABLE
ayobishahana_homework.bronze_views (
  article STRING, 
  views INT, 
  rank INT, 
  date DATE, 
  retrieved_at TIMESTAMP
) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://ceu-shahana/datalake/views/';

 