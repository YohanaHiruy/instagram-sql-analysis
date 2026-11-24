# Instagram Global Influencers 2026: SQL Analysis

An analysis of the top 100 Instagram accounts worldwide. I used SQL to clean the data and answer 10  questions, and a Power BI dashboard.

## Dashboard

<!-- ![Dashboard preview](images/dashboard.png) -->

## Dataset

- **Source:** `instagram_global_influencers_2026.csv`
- **Size:** 100 accounts, 11 columns, no missing values or duplicates
- **Imported into SQL as:** `ig_raw`

## Data cleaning

I never edited the raw table. Instead I created a view called `ig_clean` on top of `ig_raw`:

- Renamed `60_day_eng_rate` to `eng_rate_60d`, because column names starting with a digit need quoting in every query.
- Renamed `rank` to `rank_no` and `channel_info` to `handle`.
- Split multi-value fields with `INSTR` and `SUBSTR`. For example, `Italy/Senegal` becomes `Italy`, and `Sports/Cricket` becomes `Sports`. This turned 37 messy category labels into groups that can be compared.
- Added two calculated columns:
  - `calc_eng_rate`: avg_likes / followers x 100
  - `recent_like_change_pct`: the percentage change between older and recent average likes
#Questions asked
| 1 | Who are the top 10 accounts by followers? 
| 2 | Which accounts have an engagement rate above 5%? 
| 3 | Which Indian accounts have over 50M followers? 
| 4 | How many accounts does each country have? 
| 5 | What is the average engagement per category? 
| 6 | Which countries have the most total followers? 
| 7 | Which categories with 3 or more accounts engage best? 
| 8 | Do bigger accounts have lower engagement? 
| 9 | Who is the top account in each category? 
| 10 | Which accounts beat their own category's average? 
## Key findings

- **The US dominates.** 47 of the 100 accounts are American, and the US holds about 57% of all followers in the list. India is second with 13 accounts, then the UK with 9 and South Korea with 6.
- **Bigger accounts engage less.** Average 60-day engagement falls steadily as follower count rises:
- **Content creators engage best.** Among categories with at least 3 accounts, Content Creators average 5.13%, followed by Music (3.59%) and Entertainment (3.40%). Sports clubs (1.02%) and Media (0.90%) are lowest.
- **The highest single engagement rates belong to mid-sized music and entertainment names.** Post Malone leads at 11.97%, followed by Tom Holland, Harry Styles and Bad Bunny.
- **Recent posts are doing better.** All 100 accounts get more likes on recent posts than their historical average, up about 9.9% on average.

## Limitations

- Only the top 100 accounts are included, so findings describe the very top of Instagram and not influencers in general.
- Multi-country and multi-category values are reduced to the first listed value. For example, a Cuba/United States account is counted under Cuba.
- Some categories stay separate even though they are related, such as "Sports" and "Sports Club".
- This is a single snapshot with no dates, so trends over time can't be measured.

## Tools

SQL for cleaning and analysis, Power BI for the dashboard.
