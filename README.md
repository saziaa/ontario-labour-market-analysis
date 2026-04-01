# Ontario Labour Market Analysis 2015–2025
### A SQL-based policy analysis of employment trends, COVID-19 impact, and structural labour force shifts using Statistics Canada data

## 📌 Policy Context

Ontario's labour market underwent significant structural change between 2015 and 2025. The COVID-19 pandemic caused the sharpest single employment shock on record, 
with unemployment peaking at 14.2% in May 2020. However, aggregate recovery statistics mask important structural realities, not all industries recovered equally, and hundreds of thousands of workers who left the labour force during COVID had not fully returned by 2025.

This analysis examines four policy-relevant questions:

1. How did Ontario's core labour market indicators trend across the full 2015–2025 period including through COVID?

2. Which industries were most severely impacted by COVID-19 and which have structurally recovered versus permanently declined?

3. Is Ontario's labour force structurally shifting toward services and knowledge industries and which sectors are losing share permanently?

4. Does Ontario's unemployment rate tell the full recovery story or does participation rate reveal hidden labour force withdrawal that unemployment 
   statistics obscure?

The findings have direct relevance for income support program planning, workforce development policy, and regional labour market interventions.

## 🛢️ Data Sources

| Table | Source | Description | Period |
|---|---|---|---|
| [14-10-0287-01](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028701&pickMembers%5B0%5D=1.7&pickMembers%5B1%5D=3.1&pickMembers%5B2%5D=4.1&pickMembers%5B3%5D=5.1&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=2015&cubeTimeFrame.endMonth=12&cubeTimeFrame.endYear=2025&referencePeriods=20150101%2C20251201) | Statistics Canada | Labour force characteristics, monthly, seasonally adjusted, Ontario, both sexes, 15 years and over | Jan 2015 – Dec 2025 |
| [14-10-0023-01](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410002301&pickMembers%5B0%5D=1.7&pickMembers%5B1%5D=2.2&pickMembers%5B2%5D=4.1&pickMembers%5B3%5D=5.1&cubeTimeFrame.startYear=2015&cubeTimeFrame.endYear=2025&referencePeriods=20150101%2C20250101) | Statistics Canada | Labour force characteristics by industry, annual, Ontario, both sexes, 15 years and over | 2015 – 2025 |

Both tables sourced directly from Statistics Canada CANSIM. Raw files are preserved unmodified in `/data/raw/`.

## 🧩 Methodology

**Data Preparation**
Raw StatsCan files were downloaded in wide format and reshaped to long format prior to SQL loading. All analytical transformations including cleaning, suppression flagging, and aggregate row identification were performed in SQL to ensure full reproducibility.

**Database**
MySQL 8.0. All queries written in standard SQL compatible with MySQL.

**Analytical Approach**
Four sequential analyses were built using CTEs and window functions. Each analysis answers one discrete policy question. Findings are cross-referenced across 
analyses to build a coherent labour market narrative.

**COVID Period Definition**
Based on data, March 2020 identified as structural break point where unemployment rose 2.9 points and employment fell 3.9 points in a single month, the 
largest single-month movement in the 11-year dataset.

**Pre-COVID Baseline**
2019 annual averages used as benchmark throughout. 2019 represents the peak of the pre-pandemic expansion and the last full year of normal labour market conditions.

## 🔑 Key Findings

### 1. COVID Shock and Recovery
- Peak unemployment: **14.2% in May 2020**, highest in the 11-year dataset
- Largest single-month shock: April 2020 with unemployment rising 3.6 points and employment falling 5.8 points
- Employment asymmetry: employment fell 9.8 points Mar–May 2020 while unemployment only rose 8.6 points, indicating immediate labour force withdrawal

### 2. Industry Impact : Uneven Recovery
- **4 industries in structural decline by 2025:** 
  Accommodation and food services (-4.02%), Agriculture (-12.35%), Business building support (-9.99%), Other services (-0.72%). All 4 structurally declining industries are low-wage, in-person service sectors
- **4 industries grew during COVID:** Finance, Professional/technical, Public administration, Forestry. All either high-skill or essential sectors
- COVID accelerated pre-existing labour market polarization between high-skill and low-wage sectors

### 3. Structural Shift Toward Knowledge Economy
- Largest share gainers 2015–2025: Professional and technical services (+2.75 ppt), Finance (+1.16 ppt)
- Largest share losers: Business support (-1.41 ppt), Accommodation (-1.08 ppt), Durables manufacturing (-0.87 ppt)
- Ontario is structurally transitioning from goods-producing and low-wage service employment toward knowledge and care economy jobs

### 4. Hidden Slack — Incomplete Recovery
- Peak hidden slack: **173,900 workers** missing from labour force in 2020 vs 2019 baseline
- 2022–2023: Near genuine recovery achieved as unemployment returned to baseline
- 2025: New labour market distress emerging, unemployment at 7.69% vs 5.54% baseline, driven by population growth outpacing job creation,interest rate impacts on key sectors, and accelerating polarization between high-skill and low-wage employment.
- Unemployment rate alone overstates recovery, participation rate reveals persistent structural weakness

### Overall Narrative
Ontario's post-COVID recovery was real but uneven and fragile. High-skill sectors expanded while low-wage sectors declined permanently. By 2025 renewed labour 
market stress is emerging from structural forces record immigration outpacing job creation and accelerating polarization not COVID directly. Workers displaced from structurally declining sectors face significant barriers to transitioning into growing knowledge economy roles, with direct implications for income support program demand.

## 📊 Data Quality Notes

| Issue | Finding | Decision |
|---|---|---|
| 2006 LFS level shift | Data starts 2015 — entirely post-shift | No impact on analysis |
| Seasonal adjustment | Monthly data pre-adjusted by StatsCan | Trend analysis reflects cyclical movement only |
| NAICS 2022 reclassification | Applied retroactively across full series | Industry comparisons consistent throughout |
| Suppression threshold | Ontario threshold 1,500 — Fishing hunting trapping suppressed all 11 years | Flagged in cleaning layer, excluded from analysis |
| Industry hierarchy | 7 aggregate rows identified and excluded from summation | Documented in dim_industry_hierarchy |
| Total vs detail gap | Maximum gap 1,100 workers (0.02% of total) | Explained by suppression and rounding, documented in validation queries |
| 2025 data | Subject to StatsCan revision | Trend direction consistent across multiple months |


## 🛠️ Tools Used

- **SQL:** MySQL 8.0 — data cleaning, validation and analysis
- **Data Source:** Statistics Canada CANSIM
- **Python:** Wide-to-long format reshaping (preprocessing only)






