-- ============================================================
-- FILE: 01_overall_kpis.sql
-- PROJECT: Sales Performance Analysis
-- DATABASE: MS SQL Server
-- DESCRIPTION: Executive-level KPI summary queries
-- AUTHOR: Snehangshu Bhuin
-- ============================================================


-- ================================================================
-- QUERY 1: Overall Business KPI Summary
-- Business Question: What is the overall health of the business?
-- ================================================================

SELECT
    ROUND(SUM(Sales), 2)                                              AS Total_Revenue,
    ROUND(SUM(Profit), 2)                                             AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Profit_Margin_Pct,
    COUNT(DISTINCT Order_ID)                                          AS Total_Orders,
    COUNT(DISTINCT Customer_ID)                                       AS Total_Customers,
    SUM(Quantity)                                                     AS Total_Units_Sold,
    ROUND(SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0), 2)     AS Avg_Order_Value,
    ROUND(AVG(Discount) * 100, 2)                                     AS Avg_Discount_Pct
FROM superstore_clean;

/*
Total revenue is $2.29M, profit $286K, margin 12.47%.
5,009 orders from 793 customers, 37,873 units sold.
Average order value sits at $458.61 with a 15.62% average discount --
discount levels are high enough to warrant a closer look at margin impact.
*/


-- ================================================================
-- QUERY 2: KPI Comparison by Year
-- Business Question: Is the business growing year over year?
-- ================================================================

SELECT
    YEAR,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(DISTINCT Order_ID)                                          AS Orders,
    COUNT(DISTINCT Customer_ID)                                       AS Customers,
    ROUND(SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0), 2)     AS Avg_Order_Value
FROM superstore_clean
GROUP BY YEAR
ORDER BY Year;

/*
Revenue, profit, orders, and customers all grew from 2014 to 2017.
Margins stabilized around 12-13% after a weaker 2014.
One thing worth noting: order count rose each year but average order
value declined -- more transactions, smaller baskets.
*/


-- ================================================================
-- QUERY 3: Year-over-Year Revenue Growth %
-- Business Question: What is the annual growth rate?
-- ================================================================

WITH YearlySales AS (
    SELECT
        YEAR,
        ROUND(SUM(Sales), 2)   AS Revenue
    FROM superstore_clean
    GROUP BY YEAR
)
SELECT
    Year,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year) AS Prev_Year_Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year))
        / NULLIF(LAG(Revenue) OVER (ORDER BY Year), 0) * 100
    , 2) AS YoY_Growth_Pct
FROM YearlySales
ORDER BY Year;

/*
2015 dipped slightly from 2014. 2016 and 2017 recovered strongly.
The growth trend after 2015 is clear and consistent.
*/


-- ================================================================
-- QUERY 4: Shipping Mode Volume and Revenue Share
-- Business Question: Which shipping mode drives the most business?
-- ================================================================

SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID)                                          AS Orders,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Sales) / SUM(SUM(Sales)) OVER () * 100, 2)           AS Revenue_Share_Pct,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    ROUND(AVG(CAST(DATEDIFF(DAY, Order_Date, Ship_Date) AS FLOAT)), 1) AS Avg_Ship_Days
FROM superstore_clean
GROUP BY Ship_Mode
ORDER BY Revenue DESC;

/*
Standard Class handles the bulk of orders and revenue -- customers
are price-sensitive on shipping. First Class and Same Day move fewer
orders but hold similar margins, so faster shipping isn't hurting
profitability where customers choose it.
*/