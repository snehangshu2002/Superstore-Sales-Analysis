# Sales Performance Analysis

Four years of superstore sales data (2014–2017), pulled apart to figure out what's actually making money and what isn't.

## What's in here

Started as a cleanup exercise, ended up as a full analysis of regional performance, product categories, and discounting. The Python notebook handles data prep. The SQL queries handle the business questions.

## The Data

- **Raw**: `data/superstore_raw.csv` — 9,994 rows, 21 columns
- **Cleaned**: `data/superstore_clean.csv` — same data plus 8 engineered features (29 columns total)

793 customers across four US regions, 2014–2017. Three product categories: Furniture, Office Supplies, Technology.

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

### Overall numbers

$2.29M revenue over four years, $286K profit, 12.47% margin. 5,009 orders, 37,873 units, average order value $458.61. Average discount rate is 15.6% — high enough to matter.

Order count went up every year but average order value went down. More transactions, smaller baskets.

### Regional performance

West and East generate most of the revenue and hold decent margins. West–Consumer is the top profit generator. East–Home Office has the highest margin of any region–segment pair at 20.95%.

Central is the problem. Texas is third in revenue and running a $25,729 loss — 37% average discount rate, 49% of orders unprofitable. Ohio, Pennsylvania, and Illinois are in the same situation: loss rates between 44–51%, average discounts of 32–39%.

At city level: New York City does $256K at 24.2% margin. Philadelphia, Houston, Chicago, and San Antonio have the opposite problem — strong sales, negative profit. Lafayette, Atlanta, and Minneapolis are small by volume but their margins are above 40%.

### Product categories

Technology: $836K revenue, $145K profit, 17.4% margin. Holds up across every region. Copiers run at 37.2% margin, Paper at 43%+. Central actually posts the strongest Tech margin at 19.77%.

Office Supplies: highest unit volume, 17% margin. West and East are at 20–24%. Central is weaker.

Furniture: similar revenue to Office Supplies, 2.5% margin. Tables alone lost ~$18K (-8.56% margin). Bookcases and Supplies are also negative. In Central, the category runs at -1.75%.

### Discounting

No discount = 29.5% margin. That number deteriorates fast:

| Discount Band | Margin |
|---|---|
| 0% | 29.5% |
| 1–10% | barely profitable |
| 11–20% | near break-even |
| 21–30% | loss |
| 30%+ | -48% |

20% is roughly where the line is. Above it, you're losing money on most orders. There are 418 orders at 70% discount and 300 at 80% — not edge cases, just a pricing problem that's been left running.

### Seasonality

Same pattern every year: revenue builds through Q4, peaks in November–December, drops in January–February (sometimes profit goes negative in that window despite decent sales volume), recovers in March, spikes again September–November. Q4 wins every year. 2015 dipped slightly; 2016–2017 recovered well.

### Biggest individual losses

50 line items with losses over $500. Most are Furniture (Tables, Bookcases, Conference Tables) or high-ticket tech at steep discounts: Cubify CubeX 3D Printers, Lexmark Laser Printers, Cisco TelePresence. GBC and Fellowes binding systems also show up repeatedly. Discount rates on these are 40–80%. The single worst: Cubify CubeX 3D Printer Double Head Print, -$6,599.98 at 70% discount.

## How It Works

### Data prep (Python)

`01_data_preparation.ipynb`:

1. Load CSV with `latin-1` encoding
2. Convert `Order Date` and `Ship Date` to `datetime64`
3. Extract `Year`, `Month`, `Quarter`, `Month_Name`
4. Add derived columns:
   - `Profit_Margin_Pct` = (Profit / Sales) × 100
   - `Ship_Lag_Days` = days between order and shipment
   - `Is_Loss` = True if Profit < 0
   - `Discounted_Revenue` = Sales × (1 − Discount)
5. No missing values across all 21 original columns
6. Export: 9,994 rows, 29 columns

Raw data ranges: Sales $0.44–$22,638 / Profit -$6,599.98–$8,399.98 / Discount 0–0.80 / Quantity 1–14 units.

### SQL analysis (MS SQL Server)

- `01_overall_kpis.sql` — revenue, profit, margin, AOV, discount %, YoY growth via `LAG()`, shipping mode breakdown with average ship days
- `02_regional_analysis.sql` — region and state profitability, top 15 states by revenue, bottom 10 by profit, region × segment cross-tab, top 20 cities, loss order concentration by geography
- `03_category_analysis.sql` — category and sub-category performance, bottom 5 loss-making sub-categories, discount band analysis, category × region matrix, top/bottom 10 products by profit
- `04_time_series.sql` — monthly revenue trend, MoM growth via `LAG()`, quarterly YoY growth partitioned by quarter, category revenue over time

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

1. Cap discounts at 20%. The data is clear — above that and most orders lose money.
2. Central region needs a discount policy. Texas specifically: 37% average discount, -$25,729 total profit. Ohio, Pennsylvania, and Illinois are close behind.
3. Furniture pricing needs a look. 2.5% category margin means any discount kills it. Tables are already $18K in the hole.
4. Pull the high-loss product list and review those SKUs. Cubify 3D printers, GBC binding systems, and Chromcraft conference tables keep appearing.
5. Treat Q4 as predictable. The seasonal spike happens every year — it should be planned for, not reacted to.
6. Flag orders above 30% discount for manual review. 718 orders at 70–80% off isn't a sales strategy.

## Author

Snehangshu Bhuin