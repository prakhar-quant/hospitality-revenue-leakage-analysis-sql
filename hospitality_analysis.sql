CREATE DATABASE hotel_analysis;
USE hotel_analysis;
-- check uploaded data  to understand the coloumns 
select * from dim_date limit 5 ;
select * from fact_bookings limit 7; 
-- check no. of rows in actual data 
select count(*) from fact_bookings;
-- total revenue generated 
select sum(revenue_generated) as total_reveune from fact_bookings ;
-- total revenue realized 
select sum(revenue_realized) as actual_reveune from fact_bookings ;
-- revenue leakage 
select sum(revenue_generated) - sum(revenue_realized) as revenue_leakage from fact_bookings ;
-- lost revenue 
SELECT booking_status,COUNT(*) AS total_bookings FROM fact_bookings GROUP BY booking_status; 

-- revenue by hotels 
select * from dim_hotels;
select h.property_name ,  SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
join dim_hotels h
ON b.property_id = h.property_id
group by  h.property_name
ORDER BY revenue DESC;

-- revenue by room type 
select b.room_category , sum(revenue_realized) as revenue , h.room_class as class 
from fact_bookings b
join dim_rooms h
on b.room_category=h.room_id
group by b.room_category , h.room_class
order by revenue desc; 

-- KPI 1 occupancy - In the hotel and hospitality industry, occupancy (often measured as Occupancy Rate) is a metric 
-- that tells you the percentage of available rooms that are filled with guests during a specific period
SELECT property_id,ROUND(
sum(successful_bookings)*100/
sum(capacity),3
) AS occupancy_rate
from fact_aggregated_bookings
 group by  property_id 
 order by occupancy_rate desc;

-- KPI 2 ADR average daily rate 
select property_id, round(sum(revenue_realized)/count(booking_id),2)
as ADR from fact_bookings 
where booking_status='checked out' group by property_id order by ADR desc ;

-- KPI 3 revenue realisation 
SELECT property_id, round(sum(revenue_realized)*100/
sum(revenue_generated),2) AS realization_percentage
from fact_bookings
GROUP BY property_id
ORDER BY realization_percentage DESC; 
-- kpi 4 revenue leakage 
SELECT property_id,
sum(revenue_generated) AS generated_revenue ,
sum(revenue_realized) AS realized,
sum(revenue_generated)-sum(revenue_realized) AS leakage from fact_bookings
group by  property_id
ORDER BY leakage DESC; 

-- revPAR - revenue per availble room 
SELECT
property_id,
round(sum(successful_bookings),0) AS rooms_sold,
sum(capacity) As capacity
from fact_aggregated_bookings
group by property_id;
-- revenue by property 
SELECT
h.property_name,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.property_name
ORDER BY revenue DESC;
--   revenue leakage by prroperty 
SELECT
h.property_name,
SUM(b.revenue_generated)-sum(b.revenue_realized) AS revenue_leakage
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.property_name 
ORDER BY revenue_leakage DESC;
-- realization by property 
SELECT
h.property_name,
ROUND(
SUM(b.revenue_realized)*100/
SUM(b.revenue_generated),
2
) AS realization_percentage
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.property_name
ORDER BY realization_percentage DESC;
--  ADR by property 
SELECT
h.property_name,
ROUND(
SUM(b.revenue_realized)/
COUNT(CASE WHEN b.booking_status='Checked Out'
THEN 1 END),
2
) AS ADR
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.property_name
ORDER BY ADR DESC;

-- where revenue is leaking ? , what is the problem 
select booking_status, 
COUNT(*) AS total_booking 
FROM fact_bookings
group by booking_status
order by total_booking DESC ;
-- REVENUE LEAKAGE BY BOOKING STATUS 
SELECT booking_status , 
sum(revenue_generated)-SUM(revenue_realized) AS LEAKAGE 
FROM fact_bookings
GROUP BY booking_status ORDER BY LEAKAGE DESC ; 
-- REVENUE BY BOOKING PLATFORMS 
SELECT
booking_platform,
SUM(revenue_realized) AS revenue
FROM fact_bookings
GROUP BY booking_platform
ORDER BY revenue DESC;
-- LEAKAGE BY BOOKING PLATFORM 
SELECT
booking_platform,
SUM(revenue_generated)-SUM(revenue_realized) AS leakage
FROM fact_bookings
GROUP BY booking_platform
ORDER BY leakage DESC;
-- OCCUPACY VS REVENUE BY ROOM CLASS 
-- SELECT
-- r.room_class,
-- ROUND(
-- SUM(f.successful_bookings)*100/
-- SUM(f.capacity),
-- 2
-- ) AS occupancy_rate,
-- SUM(b.revenue_realized) AS revenue
-- FROM fact_aggregated_bookings f
-- JOIN dim_rooms r
-- ON f.room_category = r.room_id
-- JOIN fact_bookings b
-- ON f.property_id = b.property_id
-- AND f.room_category = b.room_category
-- GROUP BY r.room_class
-- ORDER BY revenue DESC; ( GIVING CONNECTION ERROR BECAUSE OF TOO MANY ROWS MAY BE )
SELECT
r.room_class,
ROUND(
SUM(f.successful_bookings)*100.0/
SUM(f.capacity),
2
) AS occupancy_rate
FROM fact_aggregated_bookings f
JOIN dim_rooms r
ON f.room_category=r.room_id
GROUP BY r.room_class;
SELECT
r.room_class,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_rooms r
ON b.room_category=r.room_id
GROUP BY r.room_class
ORDER BY revenue DESC;

--  trend analysis FOR BOOKING PLATFORM  
-- because revenue leakage cause by only cancelation 

-- we can check from which platform cancellation rate is high 
SELECT BOOKING_PLATFORM , COUNT(*) AS cancelled_booking 
FROM fact_bookings where booking_status='CANCELLED'
GROUP BY booking_platform
ORDER BY CANCELLED_BOOKING DESC ;
-- WHICH ROOM TYPE IS MOST CANCELLED 
SELECT room_category, COUNT(*) AS cancelled_booking 
FROM fact_bookings where booking_status='CANCELLED'
GROUP BY room_category
ORDER BY CANCELLED_BOOKING DESC ;
-- WHICH HOTEL SUFFER MOST CANCELLATION 
SELECT h.PROPERTY_NAME , COUNT(*) AS cancelled_booking 
FROM fact_bookings b 
JOIN DIM_HOTELS H 
ON b.property_id=h.property_id
WHERE BOOKING_STATUS='CANCELLED'
GROUP BY h.property_name 
ORDER BY cancelled_booking DESC;
-- TOTAL CANECLLATION RATE 
SELECT
ROUND(
COUNT(CASE WHEN booking_status='Cancelled' THEN 1 END)*100.0
/
COUNT(*),
2
) AS cancellation_rate
FROM fact_bookings; 

-- REVENUE ANALSYIS FROM CITY 
SELECT
h.city,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.city
ORDER BY revenue DESC;
-- REVENUE LEAKAGE 
SELECT
h.city,
SUM(b.revenue_GENERATED)-SUM(B.REVENUE_REALIZED) AS revenue_LEAKAGE
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.city
ORDER BY revenue_LEAKAGE DESC;
-- OCCUPACY BY CITY 
SELECT
h.city,
ROUND(
SUM(f.successful_bookings)*100.0/
SUM(f.capacity),
2
) AS occupancy_rate
FROM fact_aggregated_bookings f
JOIN dim_hotels h
ON f.property_id=h.property_id
GROUP BY h.city
ORDER BY occupancy_rate DESC;

-- TIME SERIES ANALAYSIS FOR REVENUE 
-- REVENUE BY MONTHS 
-- SELECT
-- d.`MMM YY`,
-- SUM(b.revenue_realized) AS revenue
-- FROM fact_bookings b
-- JOIN dim_date d
-- ON b.check_in_date=d.`DATE`
-- GROUP BY d.`mmm yy`
-- ORDER BY MIN(d.date);( GOT A PROBLEM , BOTH DATASET DATE IS IN DIFFRENT FORMAT LETS FIND SOLUTION )
-- ALTER TABLE dim_date
-- ADD COLUMN formatted_date DATE;
-- SELECT * FROM dim_date;
-- UPDATE dim_date
-- SET formatted_date =
-- STR_TO_DATE(`date`,'%d-%b-%y'); 
-- SET SQL_SAFE_UPDATES = 1;
-- DATE NEW COLOUM ACHIEVED MOVE FURTHER 
SELECT
d.`mmm yy`,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_date d
ON B.check_in_date
= d.formatted_date
GROUP BY d.`mmm yy`
ORDER BY MIN(d.formatted_date);

-- OCCUPACY BY MONTHS 
SELECT
d.`mmm yy`,
ROUND(
SUM(f.successful_bookings)*100.0/
SUM(f.capacity),
2
) AS occupancy_rate
FROM fact_aggregated_bookings f
JOIN dim_date d
ON f.check_in_date
= d.`DATE`
GROUP BY d.`mmm yy`
ORDER BY MIN(d.formatted_date);

-- WEEKEND VS WEEK DAYS analyze
SELECT
d.day_type,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_date d
ON B.check_in_date
= d.formatted_date
GROUP BY d.day_type
ORDER BY revenue DESC;

-- top hotel and top room revenue 
SELECT
property_name,
revenue,
RANK() OVER(ORDER BY revenue DESC) AS hotel_rank
FROM
(
SELECT
h.property_name,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_hotels h
ON b.property_id=h.property_id
GROUP BY h.property_name
) x;
SELECT
room_class,
revenue,
RANK() OVER(ORDER BY revenue DESC) AS room_rank
FROM
(
SELECT
r.room_class,
SUM(b.revenue_realized) AS revenue
FROM fact_bookings b
JOIN dim_rooms r
ON b.room_category=r.room_id
GROUP BY r.room_class
) x;
