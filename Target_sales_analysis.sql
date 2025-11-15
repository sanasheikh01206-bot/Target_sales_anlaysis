-- Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:
-- Get the time range between which the orders were placed.
select
min(extract(date from order_purchase_timestamp)) as oldest,
max(extract(date from order_purchase_timestamp)) as latest
from Target.orders;


-- Count the Cities & States of customers who ordered during the given period.
select
count(distinct customer_state),
count(distinct customer_city)
from Target.customers c  join Target.orders o
on c.customer_id = o.customer_id;


-- In-depth Exploration:
-- Is there a growing trend in the no. of orders placed over the past years?
select
extract(month from order_purchase_timestamp) as month,
extract(year from order_purchase_timestamp) as year,
count(1) as order_count
from Target.orders
group by 2,1
order by 2,1;


-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
select
extract(month from order_purchase_timestamp) as month,
count(*) as order_count
from Target.orders
group by 1
order by 1;


-- Evolution of E-commerce orders in the Brazil region:
-- A.Get the month on month no. of orders placed in each state.
select
c.customer_state,
extract(month from order_purchase_timestamp) as month,
c.customer_city,
count(2) count_of_orders
from Target.customers c join Target.orders o on
c.customer_id = o.customer_id
group by 1,2,3
order by 1,2;


-- How are the customers distributed across all the states?
select
count(distinct customer_id) as customers_count,
customer_state
from Target.customers
group by 2
order by 2;


-- Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
-- Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).
select
distinct order_id,
Extract( month from order_purchase_timestamp),
Extract( year from order_purchase_timestamp),
from Target.orders;


-- Calculate the Total & Average value of order price for each state.
select
round(sum(price),2) as total_price_per_state,
round(avg(price),2) as avg_price_per_state,
s.seller_state
from Target.order_items oi join Target.seller s on
oi.seller_id = s.seller_id
group by 3;


-- Calculate the Total & Average value of order freight for each state.
select
round(sum(freight_value),2) as total_price_per_state,
round(avg(freight_value),2) as avg_price_per_state,
s.seller_state
from Target.order_items oi join Target.seller s on
oi.seller_id = s.seller_id
group by 3;


-- Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
-- Do this in a single query.
select
date_diff(order_delivered_customer_date,order_purchase_timestamp,day) as delivery_time,
date_diff(order_estimated_delivery_date,order_delivered_customer_date,day) as difference
from Target.orders;


-- Find out the top 5 states with the highest & lowest average freight value.
-- a)
select
round(avg(freight_value),2) as avg_freiht_value,
s.seller_state
from Target.order_items oi join Target.seller s on
oi.seller_id = s.seller_id
group by 2
order by 1 desc
limit 5;
-- b)
select
round(avg(freight_value),2) as avg_freiht_value,
s.seller_state
from Target.order_items oi join Target.seller s on
oi.seller_id = s.seller_id
group by 2
order by 1
limit 5;


-- Find out the top 5 states with the highest & lowest average delivery time.
-- a)
select
round(avg(date_diff(order_delivered_customer_date,order_purchase_timestamp,day)),2) as delivery_time,
customer_state
from Target.orders o join Target.customers c on
o.customer_id = c.customer_id
group by 2
order by 1 desc
limit 5;


-- b)
select
round(avg(date_diff(order_delivered_customer_date,order_purchase_timestamp,day)),2) as delivery_time,
customer_state
from Target.orders o join Target.customers c on
o.customer_id = c.customer_id
group by 2
order by 1
limit 5;


-- Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
select
date_diff(order_estimated_delivery_date,order_delivered_customer_date,day) as difference ,
customer_state
from Target.orders o join Target.customers c on
o.customer_id = c.customer_id
group by 2,1
order by 1 desc
limit 5;


-- Find the month on month no. of orders placed using different payment types.
select
count(p.order_id) as order_count,
extract(month from o.order_purchase_timestamp) as months,
payment_type
from Target.payments p join Target.orders o on
p.order_id = o.order_id
group by 2,3
order by 2;


-- Find the no. of orders placed on the basis of the payment installments that have been paid.
select
count(order_id) as orders
from Target.payments
where payment_installments = 1;


-- During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)  
-- 0-6 hrs : Dawn
-- 7-12 hrs : Mornings
-- 13-18 hrs : Afternoon
-- 19-23 hrs : Night


select
case
when extract(hour from order_purchase_timestamp) between 0 and 6 then "Dawn"
when extract(hour from order_purchase_timestamp) between 7 and 12 then "Morning"
when extract(hour from order_purchase_timestamp) between 13 and 18 then "Afternoon"
else "Night" end as time_of_day,
count(distinct order_id) as order_no
from Target.orders
group by 1
order by 2 desc;
