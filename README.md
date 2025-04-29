# pr_09
## Аналитика с использованием сложных типов данных ##
Цель:
Выполнять описательный анализ данных временных рядов с
помощью DATETIME, используйте геопространственные данные для определения
взаимосвязей, использовать сложные типы данных (массивы, JSON и
JSONB), выполнять текстовую аналитику.

Для начала проверяем наличие необходимых пакетов для корректного использования долготы и широты

![image](https://github.com/user-attachments/assets/08fcb493-afdb-4404-96f8-47548206627d)

Далее переходим к самостоятельным задачам:
1. Создаем таблицу с точками долготы и широты для каждого клиента
```
CREATE TEMP TABLE customer_points AS (
SELECT
customer_id,
point(longitude, latitude) AS lng_lat_point
FROM customers
WHERE longitude IS NOT NULL
AND latitude IS NOT NULL
);
SELECT * FROM customer_points;
```
![image](https://github.com/user-attachments/assets/8ce95120-510e-48e8-a0d7-e6eab1842b37)

3. Создаем аналогичную таблицу для каждого дилерского центра
```
SELECT * FROM customer_points;
CREATE TEMP TABLE dealership_points AS (
SELECT
dealership_id,
point(longitude, latitude) AS lng_lat_point
FROM dealerships
);
SELECT * FROM dealership_points;
```
![image](https://github.com/user-attachments/assets/09b9050a-aa85-4f48-8fad-bca66153a1e7)

5. Объединяем эти таблицы, чтобы рассчитать расстояние от каждого клиента до каждого дилерского центра
```
CREATE TEMP TABLE customer_dealership_distance AS (
SELECT
customer_id,
dealership_id,
c.lng_lat_point <@> d.lng_lat_point AS distance
FROM customer_points c
CROSS JOIN dealership_points d
);
SELECT * FROM customer_dealership_distance;
```
![image](https://github.com/user-attachments/assets/52059aa9-df9a-4cbe-8246-c7f5d25273cf)

6. Выбираем ближайший дилерский центр для каждого клиента
```
CREATE TEMP TABLE closest_dealerships AS (
SELECT DISTINCT ON (customer_id)
customer_id,
dealership_id,
distance
FROM customer_dealership_distance
ORDER BY customer_id, distance
);
SELECT * FROM closest_dealerships;
```
![image](https://github.com/user-attachments/assets/4506788b-f2cc-4f0f-a79f-f370ab424a0c)

8. Рассчитываем среднее расстояние от каждого клиента до его ближайшего дилерского центра
```
SELECT
AVG(distance) AS avg_dist,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY distance) AS
median_dist
FROM closest_dealerships;
```
![image](https://github.com/user-attachments/assets/c0421268-5512-489d-b76a-f28cc5fbb0c6)

9. Удаляем временные таблицы
```
DROP TABLE customer_points
DROP TABLE dealership_points
DROP TABLE customer_dealership_distance
DROP TABLE closest_dealerships
```
![image](https://github.com/user-attachments/assets/daa94abb-6f15-4f43-8129-644c3e9c9696)

## Вывод ##
Выполнили описательный анализ данных временных рядов с
помощью DATETIME, использовали геопространственные данные для определения
взаимосвязей, использовали сложные типы данных (массивы, JSON и
JSONB), выполнили текстовую аналитику.
