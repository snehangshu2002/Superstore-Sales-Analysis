-- ============================================================
-- FILE   : 04_time_series.sql
-- PROJECT: Sales Performance Analysis
-- DB     : MS SQL Server
-- TOPIC  : Sales Trends Over Time
-- AUTHOR : Snehangshu Bhuin
-- ============================================================


-- ================================================================
-- QUERY 1: Monthly Sales Trend
-- ================================================================
--
-- BUSINESS QUESTION:
--   How does revenue change month by month across the years?
--   Are there seasonal patterns — months that are always high or low?

SELECT
    YEAR(Order_Date)              AS Year,
    MONTH(Order_Date)             AS Month_Num,
    FORMAT(Order_Date, 'MMM')     AS Month_Name,

    ROUND(SUM(Sales),  2)         AS Revenue,
    ROUND(SUM(Profit), 2)         AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                            AS Margin_Pct,

    COUNT(DISTINCT Order_ID)      AS Orders

FROM superstore_clean
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    FORMAT(Order_Date, 'MMM')
ORDER BY Year, Month_Num;

/*
The seasonal pattern holds every year: revenue builds through Q4, peaks in
November–December, then drops in January–February. Profit mostly follows
but swings harder — July 2014 and January 2015 both go negative despite
decent sales numbers. The business is heavily back-loaded, and the margin
volatility mid-year is worth keeping an eye on.
*/


-- ================================================================
-- QUERY 2: Month-over-Month (MoM) Revenue Growth
-- ================================================================
--
-- BUSINESS QUESTION:
--   Compared to the previous month, did revenue go up or down?
--   By how much as a percentage?

WITH MonthlyRevenue AS (
    SELECT
        YEAR(Order_Date)          AS Year,
        MONTH(Order_Date)         AS Month_Num,
        FORMAT(Order_Date, 'MMM') AS Month_Name,
        ROUND(SUM(Sales), 2)      AS Revenue
    FROM superstore_clean
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        FORMAT(Order_Date, 'MMM')
)

SELECT
    Year,
    Month_Num,
    Month_Name,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Month_Num)    AS Prev_Month_Revenue,

    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year, Month_Num))
        / NULLIF(LAG(Revenue) OVER (ORDER BY Year, Month_Num), 0) * 100
    , 2)                                            AS MoM_Growth_Pct

FROM MonthlyRevenue
ORDER BY Year, Month_Num;

/*
January–February drop, March recovers, things build through summer, then
September–November spike. Same cycle, every year. The highest MoM growth
rates land right before the peak periods, which inflates them a bit — a 40%
jump into November looks impressive but is partly just the calendar. December
sets a high bar, so January always looks bad in comparison, even in a solid year.
*/


-- ================================================================
-- QUERY 3: Quarterly Revenue with Year-over-Year Growth
-- ================================================================
--
-- BUSINESS QUESTION:
--   Each quarter, is the business doing better or worse than
--   the same quarter last year?

WITH QuarterlyRevenue AS (
    SELECT
        YEAR(Order_Date)              AS Year,
        DATEPART(QUARTER, Order_Date) AS Quarter,
        ROUND(SUM(Sales),  2)         AS Revenue,
        ROUND(SUM(Profit), 2)         AS Profit
    FROM superstore_clean
    GROUP BY
        YEAR(Order_Date),
        DATEPART(QUARTER, Order_Date)
)

SELECT
    Year,
    Quarter,
    Revenue,
    Profit,

    ROUND(Profit / NULLIF(Revenue, 0) * 100, 2) AS Margin_Pct,

    LAG(Revenue) OVER (PARTITION BY Quarter ORDER BY Year) AS Same_Q_Last_Year,
    ROUND(
        (Revenue - LAG(Revenue) OVER (PARTITION BY Quarter ORDER BY Year))
        / NULLIF(LAG(Revenue) OVER (PARTITION BY Quarter ORDER BY Year), 0) * 100
    , 2)                                        AS YoY_Growth_Pct

FROM QuarterlyRevenue
ORDER BY Year, Quarter;

/*
Q4 is the strongest quarter every year without exception. 2016–2017 show the
best YoY numbers, particularly in Q1 and Q4. Margins are fairly stable —
Q1 2017 is a mild outlier on the upside. The growth trend looks intact, but
the business is seasonal enough that quarter-level snapshots need the full-year
context to mean anything.
*/


-- ================================================================
-- QUERY 4: Category Revenue Trend Over Time
-- ================================================================
--
-- BUSINESS QUESTION:
--   How is each product category (Furniture, Technology, Office Supplies)
--   trending over the years? Which categories are growing and which are flat?

SELECT
    YEAR(Order_Date)              AS Year,
    DATEPART(QUARTER, Order_Date) AS Quarter,
    Category,

    ROUND(SUM(Sales),  2)         AS Revenue,
    ROUND(SUM(Profit), 2)         AS Profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
    , 2)                            AS Margin_Pct,

    COUNT(DISTINCT Order_ID)      AS Orders

FROM superstore_clean
GROUP BY
    YEAR(Order_Date),
    DATEPART(QUARTER, Order_Date),
    Category
ORDER BY Year, Quarter, Category;

/*
Technology grows and holds its margin. Office Supplies does the same. Furniture
grows in revenue but the margin doesn't improve — it dips negative in some
quarters and never really stabilizes. That's the tension in the Furniture
numbers: volume goes up year over year, but the profitability per dollar sold
stays weak. It's not shrinking; it's just not making money efficiently.
*/