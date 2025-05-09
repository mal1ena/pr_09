CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

--Создаем таблицу с точками долготы и широты для каждого клиента
CREATE TEMP TABLE customer_points AS (
SELECT
customer_id,
point(longitude, latitude) AS lng_lat_point
FROM customers
WHERE longitude IS NOT NULL
AND latitude IS NOT NULL
);
SELECT * FROM customer_points;

--Создаем аналогичную таблицу для каждого дилерского центра
SELECT * FROM customer_points;
CREATE TEMP TABLE dealership_points AS (
SELECT
dealership_id,
point(longitude, latitude) AS lng_lat_point
FROM dealerships
);
SELECT * FROM dealership_points;

-- Объединяем эти таблицы, чтобы рассчитать расстояние от каждого клиента до каждого дилерского центра
CREATE TEMP TABLE customer_dealership_distance AS (
SELECT
customer_id,
dealership_id,
c.lng_lat_point <@> d.lng_lat_point AS distance
FROM customer_points c
CROSS JOIN dealership_points d
);
SELECT * FROM customer_dealership_distance;

-- Выбираем ближайший дилерский центр для каждого клиента
CREATE TEMP TABLE closest_dealerships AS (
SELECT DISTINCT ON (customer_id)
customer_id,
dealership_id,
distance
FROM customer_dealership_distance
ORDER BY customer_id, distance
);
SELECT * FROM closest_dealerships;

-- Рассчитываем среднее расстояние от каждого клиента до его ближайшего дилерского центра
SELECT
AVG(distance) AS avg_dist,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY distance) AS
median_dist
FROM closest_dealerships;