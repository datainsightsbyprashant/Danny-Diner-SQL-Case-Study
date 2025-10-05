# Danny's Diner - Detailed Analysis & Insights

**Prepared for**: Danny's Diner  
**Prepared by**: Prashant  
**Date**: October 1, 2025

---

## Executive Summary

Danny's Diner customers fall into three distinct patterns: **the Premium Loyalist (A)**, **the Frequent Explorer (B)**, and the **At-Risk Ramen Lover (C)**. Despite their differences, ramen consistently emerges as the anchor dish driving loyalty and repeat visits. The loyalty program accelerates point accumulation for engaged spenders, but its broader effectiveness requires further validation since the restaurant is still at its nascent stages. With strategic actions, Danny's diner can enhance retention, grow average spend, and strengthen ramen's role as its signature offering.

---

## Data Analysis - 10 Key Questions

### 1. Total Amount Each Customer Spent

**Query:**
```sql
SELECT s.customer_id, SUM(m.price) as Total_Spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

**Results:**
| customer_id | Total_Spent |
|-------------|-------------|
| A           | $76         |
| B           | $74         |
| C           | $36         |

---

### 2. Customer Visit Frequency

**Query:**
```sql
SELECT customer_id, COUNT(DISTINCT order_date) as No_of_Visits
FROM sales
GROUP BY customer_id;
```

**Results:**
| customer_id | No_of_Visits |
|-------------|--------------|
| A           | 4            |
| B           | 6            |
| C           | 2            |

**Insight:**
- **Customer A** - Highest Spender with Modest frequency → **Premium Loyalist**
- **Customer B** - Visits more often but spends less each time → **Small Ticket, Frequent Buyer**
- **Customer C** - Visited the least → **At risk of churn**

**Business Impact:**
- **For Customer A**: Upselling premium dishes or extending exclusive offers can be considered
- **For Customer B**: Bundle offers to maximize per visit spend
- **For Customer C**: Run Targeted Reactivation Campaigns ("Earn 2x points on ordering Ramen")

---

### 3. First Item Purchased by Each Customer

**Query:**
```sql
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
```

**Results:**
| customer_id | first_items   |
|-------------|---------------|
| A           | curry, sushi  |
| B           | curry         |
| C           | ramen         |

---

### 4. Most Popular Item for Each Customer

**Query:**
```sql
WITH orders AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.customer_id) as purchase_count
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
),
ranked AS (
  SELECT *, 
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY purchase_count DESC) AS RN
  FROM orders
)
SELECT customer_id, 
  GROUP_CONCAT(product_name ORDER BY product_name) as products, 
  purchase_count 
FROM ranked
WHERE RN = 1
GROUP BY customer_id, purchase_count;
```

**Results:**
| customer_id | products          | purchase_count |
|-------------|-------------------|----------------|
| A           | ramen             | 3              |
| B           | curry, ramen, sushi | 2            |
| C           | ramen             | 3              |

**Insight:**
- **Customer A** entered as a variety seeker, later settled into Ramen loyalty
- **Customer B** entered cautiously with curry, later turned into variety-seeker and relished all 3 menu items
- **Customer C** entered and remained a single product loyalist, Ramen

**Business Impact:**
- **For Customer A**: Highlight offers for ramen with loyalty perks, maybe we can upsell premium add-ons
- **For Customer B**: Perfect candidate for "chef specials" and "new dish" promotions
- **For Customer C**: Ensure ramen availability and upsell side dishes or combos

---

### 5. Most Purchased Item Overall

**Query:**
```sql
SELECT m.product_name, COUNT(s.customer_id) as purchase_count
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
```

**Results:**
| product_name | purchase_count |
|--------------|----------------|
| ramen        | 8              |

**Insight:**
- **Ramen is the "hero dish"** at Danny's Diner
- It attracts both first-timers (C entered with ramen) and repeat loyalists (A and C stuck with ramen long term)

**Business Action:**
- Keep ramen as the **signature anchor dish** in promotions
- Pair ramen with sides (fries, drinks) to increase ticket size
- Use sushi/curry to attract variety-seekers like B but rely on ramen for core loyalty

---

### 6. First Purchase After Becoming Member

**Query:**
```sql
SELECT customer_id, product_name
FROM (
  SELECT m.customer_id, me.product_name,
    RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) as rn
  FROM members m
  JOIN sales s ON m.customer_id = s.customer_id
  JOIN menu me ON s.product_id = me.product_id
  WHERE s.order_date > m.join_date
) a
WHERE rn = 1;
```

**Results:**
| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | sushi        |

---

### 7. Last Purchase Before Becoming Member

**Query:**
```sql
SELECT customer_id, product_name
FROM (
  SELECT m.customer_id, me.product_name,
    RANK() OVER (PARTITION BY customer_id ORDER BY s.order_date DESC) as RN
  FROM members m
  JOIN sales s ON m.customer_id = s.customer_id
  JOIN menu me ON s.product_id = me.product_id
  WHERE m.join_date > s.order_date
) A
WHERE RN = 1;
```

**Results:**
| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| B           | sushi        |

---

### 8. Total Items & Spend Before Membership

**Query:**
```sql
SELECT s.customer_id,
  COUNT(s.customer_id) as Total_items,
  SUM(me.price) as Amount_spent
FROM sales s
JOIN members m ON s.customer_id = m.customer_id
  AND s.order_date < m.join_date
JOIN menu me ON s.product_id = me.product_id
GROUP BY s.customer_id;
```

**Results:**
| customer_id | Total_items | Amount_spent |
|-------------|-------------|--------------|
| A           | 2           | $25          |
| B           | 3           | $40          |

---

### 9. Loyalty Points Calculation (Sushi 2x Multiplier)

**Query:**
```sql
SELECT s.customer_id,
  SUM(CASE 
    WHEN me.product_name = 'Sushi' THEN me.price * 20 
    ELSE me.price * 10 
  END) as total_points
FROM sales s
JOIN menu me ON s.product_id = me.product_id
GROUP BY s.customer_id;
```

**Results:**
| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

### 10. Points at End of January (First Week 2x Bonus)

**Query:**
```sql
SELECT m.customer_id,
  SUM(CASE 
    WHEN s.order_date BETWEEN m.join_date AND DATE_ADD(m.join_date, INTERVAL 6 DAY) 
      THEN me.price * 20
    WHEN me.product_name = 'sushi' THEN me.price * 20 
    ELSE me.price * 10 
  END) as Total_points
FROM members m
JOIN Sales s ON m.customer_id = s.customer_id
JOIN menu me ON s.product_id = me.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY m.customer_id;
```

**Results:**
| customer_id | Total_points |
|-------------|--------------|
| A           | 1,370        |
| B           | 820          |

---

### 10a. Points Earned BEFORE Membership

**Query:**
```sql
SELECT m.customer_id,
  SUM(CASE 
    WHEN me.product_name = 'sushi' THEN me.price * 20 
    ELSE me.price * 10 
  END) as Total_points
FROM members m
JOIN Sales s ON m.customer_id = s.customer_id
JOIN menu me ON s.product_id = me.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id;
```

**Results:**
| customer_id | Total_points |
|-------------|--------------|
| A           | 240          |
| B           | 440          |

---

### 10b. Points Earned AFTER Membership

**Query:**
```sql
SELECT m.customer_id,
  SUM(CASE 
    WHEN s.order_date BETWEEN m.join_date AND DATE_ADD(m.join_date, INTERVAL 6 DAY) 
      THEN me.price * 20
    WHEN me.product_name = 'sushi' THEN me.price * 20 
    ELSE me.price * 10 
  END) as Total_points
FROM members m
JOIN Sales s ON m.customer_id = s.customer_id
JOIN menu me ON s.product_id = me.product_id
WHERE s.order_date >= m.join_date
  AND s.order_date <= '2021-01-31'
GROUP BY m.customer_id;
```

**Results:**
| customer_id | Total_points |
|-------------|--------------|
| A           | 1,020        |
| B           | 320          |

**Insights:**
- The first-week 2x bonus noticeably boosted points for **Customer A**, who began visiting more often after joining the program. However, A became more loyal to **ramen**, a dish they hadn't tried before membership which implies that while the visit frequency increased, the variety seeking considerably reduced
- **Customer B**, on the other hand, continued exploring different dishes even after joining, maintaining their variety-seeking behavior but visiting less frequently

---

## Bonus Analysis: Combined Dataset

### Merged Table with Membership Status

**Query:**
```sql
SELECT s.customer_id, s.order_date, me.product_name, me.price,
  CASE 
    WHEN m.customer_id IS NOT NULL AND s.order_date >= m.join_date 
      THEN "Y" 
    ELSE "N" 
  END as Member
FROM Sales s
JOIN menu me ON s.product_id = me.product_id
LEFT JOIN members m ON s.customer_id = m.customer_id
ORDER BY customer_id, order_date;
```

This creates a unified view showing each transaction with membership status for easy analysis.

---

### Ranking Customer Purchases (Members Only)

**Query:**
```sql
WITH merged_table AS (
  SELECT s.customer_id, s.order_date, me.product_name, me.price,
    CASE 
      WHEN m.customer_id IS NOT NULL AND s.order_date >= m.join_date 
        THEN "Y" 
      ELSE "N" 
    END as Member
  FROM Sales s
  JOIN menu me ON s.product_id = me.product_id
  LEFT JOIN members m ON s.customer_id = m.customer_id
)
SELECT *,
  CASE 
    WHEN Member = 'N' THEN NULL 
    ELSE DENSE_RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date) 
  END as Ranking
FROM merged_table;
```

This ranks purchases chronologically for members only, leaving non-member purchases unranked.

---

## Customer Journey Storytelling

### How Membership and Menu Choices Shape Loyalty

Danny's Diner's data reveals how membership reinforces what customers already value rather than changing their habits. Before joining, Customers A and B were already consistent spenders. After joining, their paths diverged, revealing how each customer type responds differently to the same program.

### Three Archetypes

**Customer A** - Once an explorer, became a ramen loyalist. The first-week bonus encouraged more frequent visits, turning ramen into a comfort favorite.

**Customer B** - Continued to explore but leaned toward premium sushi after joining, showing that membership can lift preferences without necessarily increasing visits.

**Customer C** - Never joined, remained loyal to ramen but visited rarely. This represents an opportunity for re-engagement through personalized offers.

### Ramen as a Signature Offering

Ramen sits at the center of Danny's identity. It attracts newcomers, keeps loyalists returning, and defines the diner's comfort appeal. Sushi and curry add variety for explorers but rarely replace ramen's pull.

### Membership Effect

The membership program amplifies loyalty—it strengthens commitment among devoted customers while giving explorers a reason to trade up to premium dishes. The key is timing and personalization:
- Invite customers once they cross a spending threshold
- Offer exclusive perks to loyalists
- Introduce rotating or experience-based rewards for variety seekers

---

## Conclusion

Keeping ramen consistent in quality helps Danny's Diner preserve it as their signature comfort dish. When paired with smarter membership targeting and rewards that match what customers actually value, the diner can turn regular visits into loyal relationships, and simple meals into experiences people return for.

The data shows clear customer archetypes, each requiring different engagement strategies. By personalizing the approach and maintaining ramen as the hero product, Danny's Diner can maximize customer lifetime value while creating memorable dining experiences.

---

*For questions or additional analysis, please contact Prashant*