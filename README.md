# Ontario Labour Market Analysis, 2015-2025

### A SQL analysis of Ontario employment trends, the COVID-19 shock, and industry-level shifts, using Statistics Canada data in MySQL.

## 📌 Overview


Ontario's labour market moved sharply between 2015 and 2025. In this dataset, unemployment peaked at 14.2% in May 2020. Aggregate recovery statistics can hide differences between industries, and unemployment and participation did not tell the same story in every year.

This analysis asks four questions:

1. How did Ontario's employment, unemployment and participation rates move from 2015 to 2025, including through COVID-19?
2. Which industries were hit hardest in 2020, and which had recovered their 2019 employment by 2022 and 2025?
3. Which industries gained or lost share of total employment between 2015 and 2025?
4. Did Ontario's unemployment recovery hide lingering labour force withdrawal, as measured by participation relative to 2019?


## 🛢️ Data Sources

| Table | Source | Description | Period |
|---|---|---|---|
| [14-10-0287-01](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028701&pickMembers%5B0%5D=1.7&pickMembers%5B1%5D=3.1&pickMembers%5B2%5D=4.1&pickMembers%5B3%5D=5.1&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=2015&cubeTimeFrame.endMonth=12&cubeTimeFrame.endYear=2025&referencePeriods=20150101%2C20251201) | Statistics Canada | Labour force characteristics, monthly, seasonally adjusted. Ontario, both genders, 15 years and over | Jan 2015 - Dec 2025 |
| [14-10-0023-01](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410002301&pickMembers%5B0%5D=1.7&pickMembers%5B1%5D=2.2&pickMembers%5B2%5D=4.1&pickMembers%5B3%5D=5.1&cubeTimeFrame.startYear=2015&cubeTimeFrame.endYear=2025&referencePeriods=20150101%2C20250101) | Statistics Canada | Labour force characteristics by industry, annual (x 1,000). Ontario, both genders, 15 years and over | 2015 - 2025 |

- Monthly file: 9 characteristics (6 counts in thousands, 3 rates in percent) x 132 months = 1,188 rows.
- Industry file: 28 industries x 11 years = 308 rows. The 28 split into 20 detail industries, 7 aggregate rows (totals and parent sectors), and 1 suppressed industry (Fishing, hunting and trapping).

## 🧩 Methodology

### Data Preparation
Raw StatsCan files were downloaded in wide format and reshaped to long format prior to SQL loading. All analytical transformations including cleaning, suppression flagging, and aggregate row identification were performed in SQL to ensure full reproducibility.

### Database
MySQL 8.0. All queries written in standard SQL compatible with MySQL.

### Analytical Approach
Four sequential analyses were built using CTEs and window functions. Each analysis answers one discrete policy question. Findings are cross-referenced across 
analyses to build a coherent labour market narrative.

### COVID Period Definition
Based on data, March 2020 identified as structural break point where unemployment rose 2.9 points and employment fell 3.9 points in a single month, the 
largest single-month movement in the 11-year dataset.

### Pre-COVID Baseline
2019 annual averages used as benchmark throughout. 2019 represents the peak of the pre-pandemic expansion and the last full year of normal labour market conditions.

## 🧩 Methodology

**Data Preparation (Excel)**

Footnotes and metadata rows were removed, the mostly suppressed trend-cycle rows were dropped, both files were reshaped from wide to long format, and a unit column was added. These steps were done by hand, so they are documented here but cannot be rerun from the raw files. The processed files are in `data/processed/`.

**Loading and cleaning (SQL)**

- Both files were loaded into staging tables with value columns as VARCHAR, so suppression flags and dirty values would surface instead of failing silently.
- 11 distinct characteristics appeared where 9 were expected. Trailing spaces split "Population" (13 rows) and "Employment rate" (4 rows). `TRIM()` fixed this, giving 132 rows per characteristic.
- Counts and rates are separated and never aggregated together.
- Suppression is flagged, not deleted. "Fishing, hunting and trapping" is suppressed (x) in all 11 years. The source footnote states that Ontario estimates below 1,500 are suppressed.
- The 7 aggregate rows are flagged with an `is_aggregate` column so parent and child rows are never summed together.

**Definitions and thresholds (analyst judgment calls)**

- Baseline year: 2019, the last full pre-COVID year.
- Recovery checkpoint: 2022. Long-term checkpoint: 2025.
- Industry labels:
  - **Grew during COVID:** 2020 employment exceeded 2019.
  - **Full recovery:** 2022 and 2025 both at or above 2019.
  - **Delayed recovery:** 2022 below 2019, 2025 at or above 2019.
  - **Recovered then declined:** 2022 at or above 2019, 2025 below. No industry falls here.
  - **Below 2019 at both checkpoints:** 2022 and 2025 both below 2019.
- Employment share change is labelled "Growing" or "Declining" at a cutoff of +/-0.5 percentage points. This cutoff is arbitrary.
- Shares are calculated against the sum of the 20 detail industries, which excludes the suppressed industry.
- Economic periods in the monthly analysis (pre-COVID, COVID period, recovery period, post-recovery) use fixed date bands and are labels for reading the series, not tested breaks.

**Validation**

All checks below passed. They test the internal consistency of the downloaded tables. I did not compare the downloaded values against the live Statistics Canada site.

| Check | What it tests | Result |
|---|---|---|
| Row counts | 1,188 monthly rows, 308 industry rows | Match |
| Characteristics | 9 after TRIM (11 before) | Match |
| Non-numeric text | Values that would cast silently to 0 | 0 in both files |
| Counts identity | Labour force = employment + unemployment (tolerance 0.1) | 0 of 132 months over tolerance |
| Unemployment, participation and employment rates | Published rate vs rate recalculated from counts | 132 of 132 months match |
| Sanity | Labour force <= population; employment <= labour force; unemployment >= 0 | 0 violations, 0 missing values |
| Suppression | Only Fishing, hunting and trapping suppressed | Confirmed, 11 years |
| Aggregate flag | 7 aggregate industries x 11 years | 77 rows |
| Detail industries | 28 - 7 - 1 suppressed | 20 industries, 220 rows |
| Industry reconciliation | Reported total vs sum of 20 detail industries | Largest gap 1.1k (0.02%, 2015); no negative gaps |

The reconciliation gaps range from 0.0 to 1.1 thousand and are never negative. The largest is below the 1.5 thousand suppression threshold. This is consistent with rounding plus the suppressed industry, but the split was not isolated.

## 🔑 Key findings

### 1. Monthly labour market trends

- March 2020 is where the series breaks: unemployment rose 2.9 points and the employment rate fell 3.9 points in one month.
- April 2020 had the largest single-month shock in the 2020 data (unemployment +3.6, employment rate -5.8).
- Raw unemployment peaked in May 2020 at 14.2%. The trailing 3-month average peaked in June 2020 at 12.97%.
- Participation fell from 65.2% in February 2020 to 59.1% in April, then returned to 65.1% by September.
- Annual average unemployment was 5.54% in 2019 and 9.83% in 2020.

### 2. Industry impact and recovery (20 detail industries)

| Status | Count | Industries |
|---|---|---|
| Below 2019 at both checkpoints | 4 | Accommodation and food services, Other services, Agriculture, Business/building/support services |
| Delayed recovery | 1 | Transportation and warehousing |
| Grew during COVID | 4 | Forestry and logging, Finance and insurance, Professional/scientific/technical, Public administration |
| Full recovery | 11 | All others |

- Accommodation and food services had the largest 2020 shock (-24.4%) and was still 4.0% below its 2019 level in 2025.
- Agriculture was 12.4% below 2019 in 2025. Other services was 0.7% below, a small gap.
- Forestry and logging is a very small series (4.6k to 7.5k workers), so its +63% change is noisy and should not be over-read.
- Wages and in-person work are not measured in these tables, so no claim is made about them.

### 3. Share of total employment, 2015 to 2025

- Total employment across detail industries grew about 19.9% (6,861.6k to 8,226.6k).
- Largest share gains: Professional/scientific/technical (+2.75 ppt), Finance and insurance (+1.16), Health care and social assistance (+0.82), Public administration (+0.73).
- Largest share losses: Business/building/support services (-1.41 ppt), Accommodation and food services (-1.08), Durables manufacturing (-0.87), Wholesale trade (-0.75), Retail trade (-0.73).
- 11 industries fall inside the +/-0.5 ppt "stable" band.

### 4. Hidden slack: checked, not supported

**Hypothesis:** the unemployment recovery masked lingering labour force withdrawal.

**Measure:** hidden slack = (2019 participation - year participation) / 100 x average population. It estimates how many more people would be in the labour force had participation stayed at its 2019 rate. It uses annual averages, and 2019 is a single baseline year. Participation is not age-adjusted, so part of any gap may reflect population aging.

| Year | Average participation | Reading |
|---|---|---|
| 2019 | 65.18% | Baseline |
| 2020 | 63.76% | 1.42 points below baseline: about 173,900 fewer people than the 2019 rate implies |
| 2021 | 65.22% | At baseline (0.04 points above) |
| 2022 | 65.43% | Above baseline |
| 2023 | 65.67% | Above baseline |
| 2024 | 65.23% | At baseline (0.05 points above) |
| 2025 | 65.02% | 0.16 points below baseline: about 21,900 fewer people |

- The 2020 gap is largely a short trough. Monthly participation was 59.1% in April and back to 65.1% by September, with a smaller dip in early 2021.
- Margins in 2021 and 2024 are smaller than the source's one-decimal rounding.
- 2025 unemployment was 7.69% against 5.54% in 2019, while participation was close to baseline. The weakness shows up in unemployment, not withdrawal.
- From 2023 to 2025 the employment rate fell from 61.99% to 60.03% and unemployment rose from 5.63% to 7.69%, while participation moved only from 65.67% to 65.02%. People kept looking for work, but employment did not keep pace.
- Population (15+) grew by about 1.1 million between 2022 and 2025. This is a correlation to investigate, not a tested cause.

**Result:** the data do not support the hypothesis after 2020. In 2020 itself, the unemployment rate understated the shock, because people who left the labour force were not counted as unemployed.

## 📊 Data quality notes

| Issue | Finding | Decision |
|---|---|---|
| 2006 LFS level shift | Data starts in 2015, after the shift | No impact |
| Seasonal adjustment | Monthly data is seasonally adjusted by StatCan | Seasonal patterns are removed; StatCan revises these figures |
| NAICS version | Industry estimates follow NAICS 2022 across the series | Comparisons are consistent across years |
| Suppression | Fishing, hunting and trapping suppressed in all 11 years | Kept and flagged, excluded from analysis |
| Aggregate rows | 7 parent/total rows | Flagged with `is_aggregate`, excluded from sums |
| Trailing spaces | Split two characteristics into duplicates | Fixed with `TRIM()` |
| Total vs detail gap | Differs by at most 1.1k (0.02%) in any year | Consistent with rounding plus the suppressed industry; the split was not isolated |
| 2025 data | May be revised by StatCan | Treat as provisional |

## Limitations

- Ontario-level only, with no regional or demographic breakdown.
- Annual industry data hides within-year movement.
- Participation among the 15+ population is not age-adjusted.
- Thresholds (2019 baseline, 2022 checkpoint, +/-0.5 ppt) are judgment calls, and 2019 was a strong year.
- Hidden slack uses annual averages and one baseline year.
- Reshaping and cleanup of the downloaded files was done by hand in Excel before SQL.
- Validation tests internal consistency, not agreement with the live Statistics Canada tables.
- The analysis is descriptive. No causal testing was done.

## 🛠️ Tools

- MySQL 8.0 for loading, cleaning, validation and analysis
- Excel for preparing the downloaded files
- Source data: Statistics Canada tables 14-10-0287-01 and 14-10-0023-01

