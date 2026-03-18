-- ============================================================
-- FILE   : 03_category_analysis.sql
-- PROJECT: Sales Performance Analysis
-- DB     : MS SQL Server
-- TOPIC  : Product Category, Sub-Category & Discount Analysis
-- AUTHOR : Snehangshu Bhuin
-- ============================================================


-- ================================================================
-- QUERY 1: Revenue and Profit by Product Category
-- ================================================================
--
-- BUSINESS QUESTION:
--   Which product category makes the most money? Which is most profitable?

SELECT
    Category,
    ROUND(SUM(Sales), 2)          AS Revenue,
    ROUND(SUM(Profit), 2)         AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                            AS Margin_Pct,
    SUM(Quantity)                 AS Units_Sold,

    COUNT(DISTINCT Order_ID)      AS Orders,
    ROUND(
        SUM(Sales) / SUM(SUM(Sales)) OVER () * 100
    , 2)                            AS Revenue_Share_Pct

FROM superstore_clean
GROUP BY Category
ORDER BY Revenue DESC;

/*
Technology leads on both revenue ($836K) and profit ($145K) at a 17.4% margin.
Office Supplies moves the most units and holds a nearly identical margin (17%),
so it performs well by volume. Furniture is the weak spot — similar revenue to
Office Supplies but barely 2.5% margin. Either costs are high, discounts are
too generous, or both.
*/


-- ================================================================
-- QUERY 2: Top 10 Sub-Categories by Profit
-- ================================================================
--
-- BUSINESS QUESTION:
--   Within all product types, which 10 are the most profitable?

SELECT TOP 10
    Sub_Category,
    Category,

    ROUND(SUM(Sales), 2)          AS Revenue,
    ROUND(SUM(Profit), 2)         AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                            AS Margin_Pct,

    SUM(Quantity)                 AS Units_Sold,

    ROUND(AVG(Discount) * 100, 1) AS Avg_Discount_Pct

FROM superstore_clean
GROUP BY Sub_Category, Category
ORDER BY Profit DESC;

/*
Copiers sit at the top: 37.2% margin on relatively thin volume. Paper is
surprisingly strong too, at 43%+. Phones make the most total profit by sheer
volume despite a lower margin. Chairs and Storage pull in real revenue but lose
most of it to costs. Technology sub-categories are where the money actually stays.
*/


-- ================================================================
-- QUERY 3: Bottom 5 Loss-Making Sub-Categories
-- ================================================================
--
-- BUSINESS QUESTION:
--   Which sub-categories are actually losing money for the company?

SELECT TOP 5
    Sub_Category,
    Category,

    ROUND(SUM(Sales), 2)           AS Revenue,
    ROUND(SUM(Profit), 2)          AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                             AS Margin_Pct,

    ROUND(AVG(Discount) * 100, 1)  AS Avg_Discount_Pct,

    COUNT(CASE WHEN Profit < 0 THEN 1 END)  AS Loss_Orders

FROM superstore_clean
GROUP BY Sub_Category, Category
ORDER BY Profit ASC;

/*
Tables lose the most — nearly $18K, at -8.56% margin. Discounts are likely part
of the story. Bookcases and Supplies are also underwater. Machines are a separate
case: high revenue, but margins so thin you'd question the pricing strategy.
Fasteners are the one outlier here — small volume, but actually profitable.
*/


-- ================================================================
-- QUERY 4: Discount Band Analysis
-- ================================================================
--
-- BUSINESS QUESTION:
--   At what discount level does the company START losing money?
--   Is 20% discount too much? What about 30%?

SELECT
    CASE
        WHEN Discount = 0     THEN '0%  — No Discount'
        WHEN Discount <= 0.10 THEN '1 to 10%'
        WHEN Discount <= 0.20 THEN '11 to 20%'
        WHEN Discount <= 0.30 THEN '21 to 30%'
        ELSE                       'Above 30%'
    END                              AS Discount_Band,

    COUNT(*)                         AS Orders,
    ROUND(SUM(Sales),  2)            AS Revenue,
    ROUND(SUM(Profit), 2)            AS Total_Profit,
    ROUND(AVG(Profit), 2)            AS Avg_Profit_Per_Order,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                             AS Margin_Pct

FROM superstore_clean
GROUP BY
    CASE
        WHEN Discount = 0     THEN '0%  — No Discount'
        WHEN Discount <= 0.10 THEN '1 to 10%'
        WHEN Discount <= 0.20 THEN '11 to 20%'
        WHEN Discount <= 0.30 THEN '21 to 30%'
        ELSE                       'Above 30%'
    END
ORDER BY Avg_Profit_Per_Order DESC;

/*
No discount = 29.5% margin. That's the number to hold onto. Small discounts
(1–10%) stay profitable, just barely. Cross 20% and you're losing money. At 30%+,
margin hits -48%. The business funds heavy discounts entirely out of profit —
and then some. The threshold is clearly somewhere around 20%.
*/


-- ================================================================
-- QUERY 5: Category vs Region Profit Matrix
-- ================================================================
--
-- BUSINESS QUESTION:
--   Which combination of product category AND region is most profitable?

SELECT
    Category,
    Region,

    ROUND(SUM(Sales),  2)          AS Revenue,
    ROUND(SUM(Profit), 2)          AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                             AS Margin_Pct

FROM superstore_clean
GROUP BY Category, Region
ORDER BY Category, Profit DESC;

/*
Technology holds up across every region — margins range 13% to nearly 20%,
with Central actually the strongest at 19.77%. Office Supplies is a West/East
story: 20–24% margins there, noticeably weaker in Central. Furniture drags in
every region. Central is the only one where it goes negative (-1.75%), but it's
thin everywhere.
*/


-- ================================================================
-- QUERY 6: Top 10 and Bottom 10 Products by Profit
-- ================================================================
--
-- BUSINESS QUESTION:
--   Which specific individual products make the most money?
--   Which specific products are losing the most money?

SELECT * FROM (
    SELECT TOP 10
        'Top 10 — Best Profit'     AS Product_Group,
        Product_Name,
        Category,
        Sub_Category,
        ROUND(SUM(Sales),  2)    AS Revenue,
        ROUND(SUM(Profit), 2)    AS Profit,
        ROUND(
            SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
        , 2)                       AS Margin_Pct
    FROM superstore_clean
    GROUP BY Product_Name, Category, Sub_Category
    ORDER BY Profit DESC
) AS TopProducts

UNION ALL

SELECT * FROM (
    SELECT TOP 10
        'Bottom 10 — Biggest Loss' AS Product_Group,
        Product_Name,
        Category,
        Sub_Category,
        ROUND(SUM(Sales),  2)    AS Revenue,
        ROUND(SUM(Profit), 2)    AS Profit,
        ROUND(
            SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
        , 2)                       AS Margin_Pct
    FROM superstore_clean
    GROUP BY Product_Name, Category, Sub_Category
    ORDER BY Profit ASC
) AS BottomProducts;

/*
The Canon imageCLASS 2200 Copier leads profit by a clear margin. At the other
end, Cubify CubeX 3D printers and several conference tables post the worst
losses — margins deep in the negatives. Worth noting: both ends of the list
have machines and tech products. The difference is margin, not category.
*/