# Danny's Diner - SQL Case Study

A comprehensive SQL analysis examining customer behavior, spending patterns, and loyalty program effectiveness at Danny's Diner.

## Project Overview

Danny's Diner wants to leverage customer data to understand visiting patterns, spending habits, and menu preferences. This analysis helps the restaurant deliver personalized experiences and optimize its customer loyalty program.

**Key Business Questions:**
- Which customers are the most valuable?
- What menu items drive loyalty?
- How effective is the membership program?
- What strategies can improve retention and revenue?

## Key Findings

### Customer Archetypes
- **Customer A (Premium Loyalist)**: Highest spender ($76), transformed into ramen devotee after membership
- **Customer B (Frequent Explorer)**: Most visits (6 days), variety-seeker spending $74 across all menu items
- **Customer C (At-Risk Ramen Lover)**: Lowest engagement (2 visits, $36), never joined loyalty program

### Business Insights
- **Ramen is the hero dish**: Most purchased item (8 times), consistently drives repeat visits
- **Membership accelerates loyalty**: First-week 2x bonus increased Customer A's visit frequency significantly
- **Points system rewards engagement**: Customer A earned 1,370 points by end of January vs Customer B's 820 points

## Tech Stack

- **Database**: MySQL
- **Analysis Tool**: SQL (Window Functions, CTEs, Aggregations, Joins)
- **Visualization**: Query result tables

## Repository Structure

```
├── README.md                          # Project overview (you are here)
├── ANALYSIS.md                        # Detailed findings and business recommendations
├── queries/
│   ├── customer_spending.sql         # Total spend per customer
│   ├── visit_frequency.sql           # Customer visit patterns
│   ├── menu_popularity.sql           # Product purchase analysis
│   ├── loyalty_analysis.sql          # Membership impact queries
│   └── points_calculation.sql        # Loyalty points scenarios
└── data/
    ├── schema.sql                     # Database schema
    └── sample_data.sql                # Sample dataset
```

## Sample Queries

### Total Customer Spending
```sql
SELECT s.customer_id, SUM(m.price) as Total_Spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

### Most Popular Item
```sql
SELECT m.product_name, COUNT(s.customer_id) as purchase_count
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
```

**See full query collection in the `queries/` folder or detailed analysis in [ANALYSIS.md](ANALYSIS.md)**

## Business Recommendations

1. **For High-Value Customers**: Upsell premium dishes and exclusive member perks
2. **For Frequent Visitors**: Bundle offers to maximize per-visit spend
3. **For At-Risk Customers**: Targeted reactivation campaigns (e.g., "2x points on ramen")
4. **Menu Strategy**: Keep ramen as signature anchor dish, pair with sides to increase ticket size

## Learning Outcomes

This case study demonstrates:
- Window functions (`RANK()`, `DENSE_RANK()`, `PARTITION BY`)
- Complex JOINs across multiple tables
- CTEs (Common Table Expressions) for readable queries
- Business metrics calculation (loyalty points, customer segmentation)
- Data-driven storytelling and actionable insights

## Data Schema

**Tables:**
- `sales`: Transaction records (customer_id, product_id, order_date)
- `menu`: Product details (product_id, product_name, price)
- `members`: Loyalty program enrollment (customer_id, join_date)

## Full Analysis

For detailed insights, customer journey narratives, and comprehensive business recommendations, see **[ANALYSIS.md](ANALYSIS.md)**.

## Author

**Prashant**  
*Date: October 1, 2025*

---

*This case study is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/) by Danny Ma*
