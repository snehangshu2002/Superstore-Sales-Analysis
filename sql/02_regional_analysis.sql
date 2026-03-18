-- ============================================================
-- FILE: 02_regional_analysis.sql
-- PROJECT: Sales Performance Analysis
-- DATABASE: MS SQL Server
-- DESCRIPTION: Geographic performance analysis by Region and State
-- AUTHOR: Snehangshu Bhuin
-- ============================================================


-- ================================================================
-- QUERY 1: Revenue and Profit by Region
-- Business Question: Which region is the most valuable AND profitable?
-- ================================================================

SELECT
    Region,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(DISTINCT Order_ID)                                          AS Orders,
    COUNT(DISTINCT Customer_ID)                                       AS Customers,
    ROUND(SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0), 2)     AS Avg_Order_Value,
    ROUND(SUM(Sales) / SUM(SUM(Sales)) OVER () * 100, 2)           AS Revenue_Share_Pct
FROM superstore_clean
GROUP BY Region
ORDER BY Revenue DESC;

/*
West and East together cover 60%+ of revenue. West is the most profitable.
Central is the weak spot -- decent volume but thin margins, likely
a discounting problem. South is smaller but keeps its margin clean.
*/


-- ================================================================
-- QUERY 2: Top 15 States by Revenue with Ranking
-- Business Question: Which states are the top revenue contributors?
-- ================================================================

SELECT TOP 15
    State,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(DISTINCT Order_ID)                                          AS Orders,
    RANK() OVER (ORDER BY SUM(Sales) DESC)                            AS Revenue_Rank
FROM superstore_clean
GROUP BY State
ORDER BY Revenue DESC;

/*
California leads on revenue and orders. New York is close behind with
a stronger margin. Texas is the problem -- third in revenue but running
a loss. Pennsylvania, Illinois, Ohio, and North Carolina are also in
negative margin territory despite generating real sales volume.
Michigan, Indiana, and Georgia are the quiet overperformers: lower
revenue, but margins are solid.
*/


-- ================================================================
-- QUERY 3: Bottom 10 States by Profit (Loss-Making States)
-- Business Question: Which states are costing the business money?
-- ================================================================

SELECT TOP 10
    State,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(CASE WHEN Profit < 0 THEN 1 END)                           AS Loss_Orders,
    ROUND(AVG(Discount) * 100, 1)                                     AS Avg_Discount_Pct
FROM superstore_clean
GROUP BY State
ORDER BY Total_Profit ASC;

/*
Texas tops the loss table at -$25,729 despite high revenue.
Ohio and Pennsylvania follow. All three have average discounts in
the 30-39% range and a high share of loss-making orders.
The discount levels here aren't subtle -- they're the story.
*/


-- ================================================================
-- QUERY 4: Region vs Segment Cross-Analysis
-- Business Question: Which region-segment combination is most profitable?
-- ================================================================

SELECT
    Region,
    Segment,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(DISTINCT Customer_ID)                                       AS Customers
FROM superstore_clean
GROUP BY Region, Segment
ORDER BY Region, Revenue DESC;

/*
West-Consumer is the top profit generator at $57,450 and 15.83% margin.
East-Home Office has the highest margin of any combination at 20.95% --
lower revenue but very little waste.
Central-Consumer is the opposite: 3.4% margin on reasonable revenue.
West is consistently the strongest region across all three segments.
*/


-- ================================================================
-- QUERY 5: City-Level Performance (Top 20 Cities)
-- Business Question: Which cities should receive increased sales focus?
-- ================================================================

SELECT TOP 20
    City,
    State,
    Region,
    ROUND(SUM(Sales), 2)                                              AS Revenue,
    ROUND(SUM(Profit), 2)                                             AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 2)            AS Margin_Pct,
    COUNT(DISTINCT Order_ID)                                          AS Orders,
    RANK() OVER (ORDER BY SUM(Sales) DESC)                            AS City_Rank
FROM superstore_clean
GROUP BY City, State, Region
ORDER BY Revenue DESC;

/*
New York City leads at $256K revenue with a 24.2% margin -- both high.
Los Angeles and Seattle follow with healthy numbers.
Philadelphia, Houston, Chicago, and San Antonio are the concern:
strong sales, negative profit. Discounting is the likely culprit.
Lafayette, Atlanta, and Minneapolis are interesting outliers --
lower revenue but margins above 40%, which says something about
how those markets are managed.
*/


-- ================================================================
-- QUERY 6: Regional Loss Order Analysis
-- Business Question: Where are losses geographically concentrated?
-- ================================================================

SELECT
    Region,
    State,
    COUNT(CASE WHEN Profit < 0 THEN 1 END)                           AS Loss_Orders,
    COUNT(Order_ID)                                                   AS Total_Orders,
    ROUND(
        COUNT(CASE WHEN Profit < 0 THEN 1 END) * 100.0
        / NULLIF(COUNT(*), 0)
    , 2)                                                              AS Loss_Order_Rate_Pct,
    ROUND(SUM(CASE WHEN Profit < 0 THEN Profit ELSE 0 END), 2)      AS Total_Loss_Amount,
    ROUND(AVG(Discount) * 100, 1)                                     AS Avg_Discount_Pct
FROM superstore_clean
GROUP BY Region, State
HAVING COUNT(CASE WHEN Profit < 0 THEN 1 END) > 5
ORDER BY Total_Loss_Amount ASC;

/*
Texas: -$36,813 total loss, 49% of orders unprofitable, 37% avg discount.
Illinois, Pennsylvania, and Ohio are in the same pattern -- loss rates
between 44-51%, discounts around 32-39%.
California, New York, and Washington sit at 3-5% loss order rates.
The geographic split is stark: Central states are where the discount
problem is worst, and the losses follow directly.
*/