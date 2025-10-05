use Dannys_diner;

Select * from sales;

-- Danny’s Diner is in need of your assistance to help the restaurant stay afloat 
-- the restaurant has captured some very basic data from their few months of operation 
-- but have no idea how to use their data to help them run the business.

-- What is the total amount each customer spent at the restaurant?
Select s.customer_id,sum(m.price) as Total_Spent
from sales s
join menu m on s.product_id=m.product_id
GROUP BY s.customer_id;

-- How many days has each customer visited the restaurant?
Select customer_id, count(distinct order_date) as No_of_Visits
FROM sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
Select customer_id,product_name
FROM
(
Select s.customer_id, m.product_name,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as first_order
FROM sales s
JOIN menu m on s.product_id=m.product_id
) a
WHERE first_order=1;

SELECT 
    customer_id,
    GROUP_CONCAT(product_name ORDER BY product_name) AS first_items
FROM (
    SELECT 
        s.customer_id, 
        m.product_name,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS first_order
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
) a
WHERE first_order = 1
GROUP BY customer_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
Select m.product_name,count(s.customer_id) as purchase_count
FROM menu m
JOIN sales s on m.product_id=s.product_id
GROUP BY m.product_id,m.product_name
ORDER BY purchase_count desc
LIMIT 1

-- Which item was the most popular for each customer?
with orders as
(
SELECT 
s.customer_id,
m.product_name,
count(s.customer_id) as purchase_count
FROM sales s
JOIN menu m on s.product_id=m.product_id
GROUP BY s.customer_id,m.product_name
)

,ranked as
(
Select *, DENSE_RANK() OVER (PARTITION BY CUSTOMER_ID ORDER BY purchase_count DESC) AS RN
FROM orders
)

SELECT customer_id,group_concat(product_name order by product_name) as products,purchase_count FROM RANKED
WHERE RN=1
GROUP By customer_id, purchase_count


-- Which item was purchased first by the customer after they became a member?
SELECT customer_id,product_name
from
(
Select m.customer_id, me.product_name,
RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) as rn
from members m
JOIN sales s on m.customer_id=s.customer_id
JOIN menu me on s.product_id=me.product_id
WHERE s.order_date > m.join_date
) a
WHERE RN=1;

-- Which item was purchased just before the customer became a member?
SELECT customer_id, group_concat(product_name order by product_name) as products
FROM
(
SELECT m.customer_id,me.product_name,
RANK() OVER (PARTITION BY customer_id ORDER BY s.order_date DESC) as RN
FROM members m
JOIN sales s on m.customer_id=s.customer_id
JOIN menu me on s.product_id=me.product_id
WHERE m.join_date>s.order_date
) A
WHERE RN=1
GROUP BY customer_id;

-- What is the total items and amount spent for each member before they became a member?
Select s.customer_id,
count(s.customer_id) as Total_items,
sum(me.price) as Amount_spent
FROM sales s
JOIN members m on s.customer_id=m.customer_id
and s.order_date<m.join_date
JOIN menu me on s.product_id=me.product_id
GROUP BY s.customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?

SELECT s.customer_id,
SUM(CASE WHEN me.product_name='Sushi' then me.price*20 else me.price*10 end) as total_points
FROM sales s
JOIN menu me on s.product_id=me.product_id
GROUP BY s.customer_id;

-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
SELECT m.customer_id,
SUM(CASE WHEN s.order_date BETWEEN m.join_date and date_add(m.join_date, interval 6 day) then me.price*20
WHEN me.product_name='sushi' then me.price*20 else me.price*10 end
) as Total_points
FROM members m
JOIN Sales s on m.customer_id=s.customer_id
JOIN menu me on s.product_id=me.product_id
WHERE s.order_date<='2021-01-31'
GROUP BY m.customer_id;

-- points earned before joining
SELECT m.customer_id,
SUM(CASE WHEN me.product_name='sushi' then me.price*20 else me.price*10 end) as Total_points
FROM members m
JOIN Sales s on m.customer_id=s.customer_id
JOIN menu me on s.product_id=me.product_id
WHERE s.order_date<m.join_date
GROUP BY m.customer_id;

-- Points earned after joining (in the month of Jan)
SELECT m.customer_id,
SUM(CASE WHEN s.order_date between m.join_date and date_add(m.join_date, interval 6 day) then me.price*20
when me.product_name='sushi' then me.price*20 else me.price*10 end) as Total_points
FROM members m
JOIN Sales s on m.customer_id=s.customer_id
JOIN menu me on s.product_id=me.product_id
WHERE s.order_date>=m.join_date
and s.order_date<='2021-01-31'
GROUP BY m.customer_id;

-- Bonus Question - Merge All tables
-- Join All The Things 
-- The following questions are related creating basic data tables that Danny and his team can use 
-- to quickly derive insights without needing to join the underlying tables using SQL.

Select s.customer_id, s.order_date, me.product_name,me.price,
case when m.customer_id is not null and s.order_date>=m.join_date then "Y" else "N" end as Member
from Sales s
join menu me on s.product_id=me.product_id
left join members m on s.customer_id=m.customer_id 
order by customer_id,order_date;

-- Rank All The Things
-- Danny also requires further information about the ranking of customer products, 
-- but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
-- for the records when customers are not yet part of the loyalty program.
with merged_table
as
(
Select s.customer_id, s.order_date, me.product_name,me.price,
case when m.customer_id is not null and s.order_date>=m.join_date then "Y" else "N" end as Member
from Sales s
join menu me on s.product_id=me.product_id
left join members m on s.customer_id=m.customer_id 
order by customer_id,order_date
)

Select *, 
CASE WHEN Member ='N' then null else DENSE_RANK() OVER (partition by customer_id,member order by order_date) end as Ranking
from merged_table