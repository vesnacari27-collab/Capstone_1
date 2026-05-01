-- ============================================================
-- Sales Analysis: Maine In-Store Territory
-- Analyst: Vesna Cari 
-- Database: sample_sales
-- ============================================================

USE sample_sales;

-- ============================================================
-- QUESTION 1: What is total revenue overall for sales in the assigned territory, plus the start date and end date that tell you what period the data covers?
-- ============================================================

SELECT
    SUM(ss.Sale_Amount)      AS Total_Revenue,
    MIN(ss.Transaction_Date) AS Start_Date,
    MAX(ss.Transaction_Date) AS End_Date
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maine';


-- ============================================================
-- QUESTION 2: What is the month by month revenue breakdown for the sales territory?
-- ============================================================

SELECT
    YEAR(ss.Transaction_Date)                  AS Year,
    MONTH(ss.Transaction_Date)                 AS Month_Num,
    DATE_FORMAT(ss.Transaction_Date, '%M %Y')  AS Month,
    SUM(ss.Sale_Amount)                        AS Monthly_Revenue
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maine'
GROUP BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date),
    DATE_FORMAT(ss.Transaction_Date, '%M %Y')
ORDER BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date);


-- ============================================================
-- QUESTION 3: Provide a comparison of total revenue for the specific sales territory and the region it belongs to. 
-- ============================================================

-- First, find Maine's region from the management table
SELECT DISTINCT Region
FROM management
WHERE State = 'Maine';

-- Revenue comparison: Maine vs its region
SELECT
    m.Region,
    SUM(CASE WHEN sl.State = 'Maine' THEN ss.Sale_Amount ELSE 0 END) AS Maine_Revenue,
    SUM(ss.Sale_Amount)                                                AS Region_Revenue,
    ROUND(
        SUM(CASE WHEN sl.State = 'Maine' THEN ss.Sale_Amount ELSE 0 END)
        / SUM(ss.Sale_Amount) * 100, 2
    )                                                                  AS Maine_Pct_Of_Region
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
JOIN management m ON sl.State = m.State
WHERE m.Region = (SELECT Region FROM management WHERE State = 'Maine' LIMIT 1)
GROUP BY m.Region;


-- ============================================================
-- QUESTION 4:  What is the number of transactions per month and average transaction size by product category for the sales territory? 
-- ============================================================

SELECT
    YEAR(ss.Transaction_Date)                  AS Year,
    MONTH(ss.Transaction_Date)                 AS Month_Num,
    DATE_FORMAT(ss.Transaction_Date, '%M %Y')  AS Month,
    ic.Category,
    COUNT(ss.id)                               AS Num_Transactions,
    ROUND(AVG(ss.Sale_Amount), 2)              AS Avg_Transaction_Size
FROM store_sales ss
JOIN store_locations sl       ON ss.Store_ID = sl.StoreId
JOIN products p               ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic  ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'Maine'
GROUP BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date),
    DATE_FORMAT(ss.Transaction_Date, '%M %Y'),
    ic.Category
ORDER BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date),
    ic.Category;


-- ============================================================
-- QUESTION 5: Can you provide a ranking of in-store sales performance by each store in the sales territory, or a ranking of online sales performance by state within an online sales territory?
-- ============================================================

SELECT
    sl.StoreId,
    sl.StoreLocation,
    sl.State,
    SUM(ss.Sale_Amount)           AS Total_Revenue,
    COUNT(ss.id)                  AS Total_Transactions,
    ROUND(AVG(ss.Sale_Amount), 2) AS Avg_Sale,
    RANK() OVER (ORDER BY SUM(ss.Sale_Amount) DESC) AS Revenue_Rank
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maine'
GROUP BY sl.StoreId, sl.StoreLocation, sl.State
ORDER BY Revenue_Rank;


-- ============================================================
-- QUESTION 6: ∗ What is your recommendation for where to focus sales attention in the next quarter?
-- ============================================================
/*
RECOMMENDATION:
Based on the analysis of Maine in-store sales (2022–2025), the following
actions are recommended for next quarter:

1. FOCUS ON BAR HARBOR (lowest ranked store):
   Bar Harbor ranks last in both total revenue ($287,452) and average
   transaction size ($128.90), despite having 2,230 transactions —
   the second highest transaction count. This means customers are
   coming in but spending less. A targeted upselling strategy,
   particularly around high-value categories like Technology &
   Accessories and Textbooks, could significantly boost revenue
   without needing to increase foot traffic.

2. LEVERAGE TECHNOLOGY & ACCESSORIES:
   With an average transaction size of $257+, Technology & Accessories
   is by far the highest-value category. Ensuring strong inventory
   and prominent placement of tech products across all Maine stores —
   especially in lower-performing locations like Bar Harbor and
   Bangor — should be a priority.

3. CAPITALIZE ON SEASONAL PEAKS:
   January is consistently the weakest month (e.g., $15,700 in Jan 2022).
   A post-holiday promotion in January targeting Textbooks (back to
   semester) and Stationery could help offset this seasonal dip.
   June shows strong performance and should be supported with
   adequate inventory heading into summer.

4. MAINTAIN SOUTH PORTLAND AND ORONO:
   The top two stores (South Portland and Orono) are performing well
   and are close in revenue. Continue supporting them with strong
   inventory levels. Orono's high transaction count (2,250) suggests
   strong foot traffic — focus on increasing average sale there.

5. REGIONAL CONTEXT:
   Maine represents 7.75% of Northeast region revenue. There is room
   to grow this share, particularly through the upselling and
   seasonal strategies outlined above.
*/
