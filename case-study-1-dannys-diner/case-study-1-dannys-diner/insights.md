# Insights – Danny’s Diner

This file contains plain-English interpretations of the SQL results.

---

## Question 1 – Total customer spend
**What I did:** Joined `sales` with `menu` to attach prices, then summed price per `customer_id`.  
**Insight:** Shows which customer generated the most revenue overall.

## Question 2 – Days visited
**What I did:** Counted distinct `order_date` per customer.  
**Insight:** Measures visit frequency (a proxy for engagement), regardless of items bought per day.

## Question 3 – First item purchased (ROW_NUMBER choice)
**What I did:** Ranked purchases by date per customer using `ROW_NUMBER()` and selected `rn = 1`.  
**Why ROW_NUMBER (not DENSE_RANK):** I wanted **one clear first item per customer**. If multiple items were purchased on the first day, `product_id` is used as a tie-breaker.  
**Insight:** Helps identify each customer’s initial preference.

## Question 4 – Most purchased item overall
**What I did:** Counted purchases per product and selected the highest count.  
**Insight:** Identifies the best-selling menu item across all customers.

## Question 5 – Most popular item for each customer
**What I did:** Counted purchases per customer + product, then ranked items within each customer using `DENSE_RANK()`.  
**Why this logic:** It matches “most popular *for each customer*” and keeps ties (if two items are equally most purchased).  
**Insight:** Reveals individual customer preferences; useful for personalization.

## Question 6 – First purchase after becoming a member
**What I did:** Filtered purchases to on/after membership with `WHERE s.order_date >= me.join_date`, then used `ROW_NUMBER()` to pick the earliest post-membership purchase.  
**Why this condition matters:** The question is specifically about behavior **after** joining, so pre-membership purchases must be excluded.  
**Insight:** Highlights what members choose immediately after joining, which can reflect loyalty-program impact.

## Question 7 – Last purchase before becoming a member (DENSE_RANK choice)
**What I did:** Filtered purchases to before membership with `WHERE s.order_date < me.join_date`, then used `DENSE_RANK()` ordered by date descending to keep all items purchased on the last pre-membership day.  
**Why DENSE_RANK:** Preserves ties (multiple items bought on that last day) instead of forcing a single item.  
**Insight:** Shows what customers were buying immediately before joining—useful to understand what may motivate enrollment.

## Question 8 – Purchases before joining (items + spend)
**What I did:** For members only, filtered to purchases before join date and aggregated per customer: `COUNT(*)` = total items, `SUM(price)` = total spend.  
**Insight:** Quantifies customer value *before* membership, useful for comparing pre- vs post-membership behavior.


