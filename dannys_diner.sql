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

--Case Study Queries

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

--Which item was purchased first by the customer after they became a member?

WITH cte AS (SELECT ROW_NUMBER () OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS row_id, 
	sales.customer_id, sales.order_date, menu.product_name 
	FROM sales 
    INNER JOIN menu
    ON sales.product_id = menu.product_id
    INNER JOIN dbo.members
    ON members.customer_id = sales.customer_id
	WHERE sales.order_date >= .members.join_date)

	SELECT * 
	FROM cte 
	WHERE row_id = 1

A	          curry
B		      sushi

--Which item was purchased just before the customer became a member?

WITH cte AS (SELECT ROW_NUMBER () OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS row_id, 
	sales.customer_id, sales.order_date, menu.product_name 
	FROM sales 
    INNER JOIN menu
    ON sales.product_id = menu.product_id
    INNER JOIN members
    ON members.customer_id = sales.customer_id
	WHERE sales.order_date < .members.join_date)

	SELECT * 
	FROM cte 
	WHERE row_id = 1

A	          sushi
B		      curry


--What is the total items and amount spent for each member before they became a member?

Select sales.customer_id, count(menu.product_name) as total_items, sum(menu.price) as amount_spent
	FROM sales 
    INNER JOIN menu
    ON sales.product_id = menu.product_id
    INNER JOIN members
    ON members.customer_id = sales.customer_id
	WHERE sales.order_date < members.join_date
	GROUP BY sales.customer_id

A	2	25
B	3	40

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT sales.customer_id,
	SUM(
	CASE
	WHEN menu.product_name = 'sushi' THEN 20 * price
	ELSE 10 * PRICE
	END
	) AS Points
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
	GROUP BY
	sales.customer_id
	ORDER BY
	sales.customer_id

A	860
B	940
C	360

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
	sales.customer_id,
	SUM(
		CASE
  		WHEN menu.product_name = 'sushi' THEN 20 * price
		WHEN order_date BETWEEN '2021-01-07' AND '2021-01-14' THEN 20 * price
  		ELSE 10 * PRICE
		END
	) AS Points
	FROM sales
    	JOIN dbo.menu
    	ON sales.product_id = menu.product_id
    	JOIN members
    	ON members.customer_id = .sales.customer_id
	GROUP BY
	sales.customer_id
	ORDER BY
	sales.customer_id

	
A	1370
B	940

