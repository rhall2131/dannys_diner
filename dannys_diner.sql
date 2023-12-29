CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER)

  INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3')

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
)

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12')

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
)

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09')

--Case Study Quesries

--What is the total number amount spent at the resraurant?

Select customer_id, price
from sales
INNER JOIN menu
ON sales.product_id = menu.product_id

Select customer_id,sum(price) as total_spent
from sales
INNER JOIN menu
ON sales.product_id = menu.product_id
Group by customer_id

A	76
B	74
C	36
 
--How many days has each customer visited the restaraunt? 

Select customer_id, count(distinct order_date) as Number_of_days_visited
from sales
Group by customer_id

A	4
B	6
C	2

--What was the first item from the menu purchased by each customer?

select customer_id, product_name, order_date
from sales
inner join menu
on sales.product_id = menu.product_id
where order_date = '2021-01-01'
order by order_date

A	sushi	2021-01-01
A	curry	2021-01-01
B	curry	2021-01-01
C	ramen	2021-01-01

--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT (product_name) AS Times_purchased
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY Times_purchased DESC

ramen	8
curry	4
sushi	3

--Which item was the most popular for each customer?

select sales.customer_id, menu.product_name,
count(*) as order_count,
dense_rank() over(partition by sales.customer_id
order by count(sales.customer_id)desc) as rank
FROM dbo.sales
INNER JOIN dbo.menu
ON dbo.sales.product_id = dbo.menu.product_id
group by sales.customer_id,menu.product_name

A	ramen
B	sushi
C	ramen

