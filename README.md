# Sales Performance Analysis

A deep dive into 4 years of superstore sales data (2014-2017) looking at what's actually driving profit and where the business is leaking money.

## What's in here

This started as a dataset cleanup exercise and turned into a full analysis of regional performance, product categories, and the real impact of discounting on margins. The Python notebook handles data prep, and the SQL queries dig into the business questions.

## The Data

- **Raw**: `data/superstore_raw.csv` — 9,994 orders, 21 columns
- **Cleaned**: `data/superstore_clean.csv` — Same data with engineered features

The dataset covers 793 customers across four US regions, with transactions from 2014 through 2017. Three product categories: Furniture, Office Supplies, and Technology.

## Project Layout

```
.
├── data/                        # Raw and processed data
├── notebooks/
│   └── 01_data_preparation.ipynb   # Cleaning and feature engineering
├── sql/
│   ├── 01_overall_kpis.sql      # Business health metrics
│   ├── 02_regional_analysis.sql # Geographic breakdown
│   ├── 03_category_analysis.sql # Product performance
│   └── 04_time_series.sql       # Trends over time
└── pyproject.toml               # uv package config
```

## What We Found

### The Big Picture

The business did $2.29M in revenue over four years with $286K in profit — about a 12.5% margin. Average order value sits at $459, and they're discounting roughly 16% across the board.

Growth has been steady since 2015, with margins stabilizing around 12-13%.

### Regional Performance

**West and East** are carrying the business:
- West has the best margins and highest profitability
- East is the second biggest revenue source with healthy margins

**Central region is the problem:**
- Decent sales volume but terrible margins
- Texas is the worst offender — third in revenue but actually losing money
- The culprit is clear: 37% average discount rate
- Ohio, Pennsylvania, and Illinois are also in negative margin territory

### Product Categories

**Technology** is the clear winner:
- $836K revenue, $145K profit
- 17.4% margin
- Consistent across all regions

**Office Supplies**:
- Highest volume of units sold
- 17% margin — almost as good as Technology
- Strong in West and East (20-24% margins), weaker in Central

**Furniture is bleeding money:**
- Similar revenue to Office Supplies but only 2.5% margin
- Actually loses money in Central region
- Tables sub-category alone is down $18K
- The issue is discounting — high rates are destroying profitability

### The Discount Problem

There's a hard cutoff around 20%:

- No discount = 29.5% margin
- 1-10% discount = barely profitable
- 20%+ discount = losing money
- 30%+ discount = -48% margin

Orders with discounts above 20% are almost always loss-making. The business is essentially funding deep discounts directly out of profit.

### Seasonal Patterns

Same cycle every year:
- Revenue builds through Q4
- Peaks in November-December
- January-February drops
- March recovers, steady growth through summer
- September-November spike before year-end

Q4 is the strongest quarter every year. 2015 was a slight dip, but 2016-2017 showed solid recovery.

### Orders Losing Money

Found 58 orders with losses over $500. The pattern is clear:
- Concentrated in Furniture (Tables, Bookcases)
- High-value items like 3D printers and binding systems
- Discount rates of 50-80%

## How It Works

### Data Prep (Python)

The notebook `01_data_preparation.ipynb` handles:

1. Load the CSV with latin-1 encoding
2. Convert Order Date and Ship Date to datetime
3. Extract Year, Month, Quarter, Month_Name
4. Calculate derived metrics:
   - Profit_Margin_Pct = (Profit / Sales) * 100
   - Ship_Lag_Days = days between order and shipment
   - Is_Loss = True if Profit < 0
   - Discounted_Revenue = Sales * (1 - Discount)
5. Export clean dataset

### SQL Analysis

Running against MS SQL Server:

- **01_overall_kpis.sql** — Executive metrics, YoY growth, shipping mode breakdown
- **02_regional_analysis.sql** — State and city profitability, loss concentration
- **03_category_analysis.sql** — Product performance, discount bands
- **04_time_series.sql** — Monthly trends, MoM and YoY calculations

## Tech Stack

- Python 3.12+
- pandas, numpy, matplotlib, seaborn
- MS SQL Server (T-SQL)
- uv for package management

## Running It

```bash
# Install dependencies
uv sync

# Start Jupyter
uv run jupyter notebook

# SQL queries run against superstore_clean.csv loaded into SQL Server
```

## Recommendations

1. **Cap discounts at 20%** — anything higher and you're losing money
2. **Fix Central region** — especially Texas operations
3. **Review Furniture pricing** — the margin is too thin
4. **Plan for Q4** — seasonal spike is predictable
5. **Flag high-discount orders** — manual review for anything over 30%

## Author

Snehangshu Bhuin
