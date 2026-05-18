# Analytical SQL Project

An end-to-end analytical SQL project built on an e-commerce sales dataset. The project covers the full data warehousing workflow: designing a star schema, computing core business KPIs, and answering real business questions using advanced SQL — window functions, CTEs, ranking, and time-series analysis.

---

## Dataset

**`EcommerceSalesDataset.csv`** — ~5,500 rows of raw transactional e-commerce data containing order details, customer information, product categories, shipping, payments, and revenue figures.

---

## Star Schema

The flat source data is transformed into a dimensional model optimized for analytical queries.

```
                        ┌─────────────────┐
                        │   dim_customer  │
                        │  customer_id PK │
                        │  name           │
                        │  region         │
                        │  segment        │
                        └────────┬────────┘
                                 │
┌─────────────┐         ┌────────▼────────┐         ┌──────────────┐
│  dim_product│         │   fact_orders   │         │   dim_date   │
│ product_id  ├─────────►  order_id PK    ◄─────────┤  date_id PK  │
│ category    │         │  customer_id FK │         │  year        │
│ sub_category│         │  product_id FK  │         │  quarter     │
│ product_name│         │  date_id FK     │         │  month       │
└─────────────┘         │  ship_mode_id FK│         │  day         │
                        │  revenue        │         └──────────────┘
                        │  quantity       │
                        │  discount       │         ┌──────────────┐
                        │  profit         ◄─────────┤ dim_ship_mode│
                        └─────────────────┘         │ ship_mode_id │
                                                    │ ship_mode    │
                                                    └──────────────┘
```

The full schema DDL and ETL logic are in [`final_star_schema_logic.sql`](./final_star_schema_logic.sql).  
A visual diagram is available in [`Star Schema.pdf`](./Star%20Schema.pdf).

---

## Project Structure

```
├── EcommerceSalesDataset.csv            # Raw source data
├── final_star_schema_logic.sql          # Star schema DDL + data loading
├── Star Schema.pdf                      # Visual schema diagram
├── measures_formulas_used.png           # KPI formula reference
├── Analytical_SQL_Project_Reasoning.docx # Design decisions and reasoning
│
├── Core Business KPIs/                  # SQL scripts for key metrics
│   ├── total_revenue.sql
│   ├── profit_margin.sql
│   ├── average_order_value.sql
│   └── ...
│
└── Analytical SQL Business Questions/   # SQL scripts for business Q&A
    ├── top_customers_by_revenue.sql
    ├── monthly_sales_trend.sql
    ├── category_performance.sql
    └── ...
```

---

## Core Business KPIs

| KPI | Description |
|---|---|
| **Total Revenue** | Sum of sales across all orders |
| **Total Profit** | Gross profit after discounts and costs |
| **Profit Margin** | Profit as a percentage of revenue |
| **Average Order Value (AOV)** | Mean revenue per order |
| **Order Count** | Total number of transactions |
| **Revenue by Category** | Sales broken down by product category |
| **Revenue by Region** | Geographic revenue distribution |
| **Discount Impact** | Correlation between discount rate and profit |

Formulas for all measures are documented in [`measures_formulas_used.png`](./measures_formulas_used.png).

---

## Business Questions Answered

The analytical queries address questions such as:

- Who are the top N customers by revenue, and how do they rank within their region?
- What is the month-over-month and year-over-year sales trend?
- Which product sub-categories are most and least profitable?
- How does shipping mode affect delivery time and profitability?
- What is the running total of revenue over time (cumulative sales)?
- Which orders or customers fall in the top percentile by spend (window-based ranking)?
- How does discounting behavior vary across segments and categories?

---

## SQL Techniques Used

- **Window functions** — `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, `LEAD()`, running totals with `SUM() OVER`
- **CTEs** — multi-step query decomposition for readability and reuse
- **Aggregations** — `GROUP BY`, `ROLLUP`, `CUBE` for multi-dimensional summaries
- **Date functions** — extracting year, quarter, month for time-series analysis
- **Joins** — star schema fact-to-dimension joins across all analytical queries
- **Subqueries & derived tables** — for filtering on aggregated results

---

## Getting Started

### Prerequisites

Any SQL-compatible database. The schema and queries are written for **Oracle SQL** (syntax such as `ROWNUM`, `TO_DATE`, and Oracle-style functions is used throughout).

### Load the Data

```sql
-- 1. Run the star schema setup
@final_star_schema_logic.sql

-- 2. Run KPI queries
@"Core Business KPIs/total_revenue.sql"

-- 3. Run business question queries
@"Analytical SQL Business Questions/top_customers_by_revenue.sql"
```

### Tools

The project was developed and tested using **Oracle SQL Developer**. Any Oracle-compatible client (SQL*Plus, LiveSQL, DBeaver with Oracle driver) will work.

---

## Design Reasoning

The full rationale behind schema choices, KPI definitions, and query design decisions is documented in [`Analytical_SQL_Project_Reasoning.docx`](./Analytical_SQL_Project_Reasoning.docx).

---

## Repository

[github.com/SalmaAlgayar/Analytical-SQL-Project](https://github.com/SalmaAlgayar/Analytical-SQL-Project)
