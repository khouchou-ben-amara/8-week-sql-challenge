-- Case Study 1: Danny's Diner
-- Author: Khouchou Ben Amara
-- This file contains my SQL solutions to the case study questions.

-- Question 1
-- What is the total amount each customer spent at the restaurant?

    SELECT
      s.customer_id,
      SUM(m.price) AS total_spent
    FROM sales AS s
    JOIN menu  AS m
      ON s.product_id = m.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

-- Table :

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

-- Question 2
-- How many days has each customer visited the restaurant?
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

-- Table :

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |

---

-- Question 3
-- What was the first item from the menu purchased by each customer?
  
WITH ranked_sales AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date, s.product_id
    ) AS rn
  FROM sales s
  JOIN menu m
    ON s.product_id = m.product_id
)
SELECT
  customer_id,
  product_name,
  order_date
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id;

-- Choice: Use ROW_NUMBER() to return ONE first item per customer.
-- Table:

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

---

-- Question 4
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  m.product_name,
  COUNT(*) AS times_purchased
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- Table:

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

---


-- Question 5
-- Which item was the most popular for each customer?
WITH customer_item_counts AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS times_purchased
  FROM sales s
  JOIN menu m
    ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
),
ranked_items AS (
  SELECT
    customer_id,
    product_name,
    times_purchased,
    DENSE_RANK() OVER (
      PARTITION BY customer_id
      ORDER BY times_purchased DESC
    ) AS rn
  FROM customer_item_counts
)
SELECT
  customer_id,
  product_name,
  times_purchased
FROM ranked_items
WHERE rn = 1
ORDER BY customer_id;

-- Talbe: 

| customer_id | product_name | times_purchased |
| ----------- | ------------ | --------------- |
| A           | ramen        | 3               |
| B           | ramen        | 2               |
| B           | curry        | 2               |
| B           | sushi        | 2               |
| C           | ramen        | 3               |

---

-- Question 6
-- Which item was purchased first by the customer after they became a member?
WITH member_purchases AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date, s.product_id
    ) AS rn
  FROM sales s
  JOIN members me
    ON s.customer_id = me.customer_id
  JOIN menu m
    ON s.product_id = m.product_id
  WHERE s.order_date >= me.join_date
)
SELECT
  customer_id,
  product_name,
  order_date
FROM member_purchases
WHERE rn = 1
ORDER BY customer_id;

-- Table:

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-07 |
| B           | sushi        | 2021-01-11 |

---

-- Question 7
-- Which item was purchased just before the customer became a member?

  WITH pre_member_purchases AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY s.order_date DESC
    ) AS rn
  FROM sales s
  JOIN members me
    ON s.customer_id = me.customer_id
  JOIN menu m
    ON s.product_id = m.product_id
  WHERE s.order_date < me.join_date
)
SELECT
  customer_id,
  product_name,
  order_date
FROM pre_member_purchases
WHERE rn = 1
ORDER BY customer_id, product_name;

-- Choice: Use DENSE_RANK() to keep all items purchased on the last day before joining (ties included).

-- Table :

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-01 |
| A           | sushi        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |

---

-- Question 8
-- What is the total items and amount spent for each member before they became a member?
SELECT
  s.customer_id,
  COUNT(*) AS total_items,
  SUM(m.price) AS total_spent
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
JOIN members me
  ON s.customer_id = me.customer_id
WHERE s.order_date < me.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- Table:

| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

---


