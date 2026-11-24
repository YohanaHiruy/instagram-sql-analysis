/* =====================================================
   Instagram Global Influencers 2026 
   Table: ig_raw (100 rows)
   Author-Yohana Hiruy
   ===================================================== */


/* ---------- STEP 0: LOOK AT THE DATA ---------- */

SELECT * FROM ig_raw LIMIT 5;               

SELECT COUNT(*) AS total_rows FROM ig_raw;    -- should be 100

-- duplicate check 
SELECT channel_info, COUNT(*)
FROM ig_raw
GROUP BY channel_info
HAVING COUNT(*) > 1;
-------- returns nothing

/* ---------- STEP 1: RENAMING THE AWKWARD COLUMN ---------*/

ALTER TABLE ig_raw RENAME COLUMN "60_day_eng_rate" TO eng_rate_60d;


/* ---------- STEP 2 CLEAN VIEW ---------- */

DROP VIEW IF EXISTS ig_clean;

CREATE VIEW ig_clean AS
SELECT
    "rank"                      AS rank_no,
    channel_info                AS handle,
    influence_score,
    posts,
    followers,
    avg_likes,
    eng_rate_60d,
    new_post_avg_likes,
    total_likes,
    country,
    CASE WHEN INSTR(country, '/') > 0
         THEN SUBSTR(country, 1, INSTR(country, '/') - 1)
         ELSE country END       AS primary_country,
    category,
    CASE WHEN INSTR(category, '/') > 0
         THEN SUBSTR(category, 1, INSTR(category, '/') - 1)
         ELSE category END      AS main_category,
    ROUND(100.0 * avg_likes / followers, 2)                        AS calc_eng_rate,
    ROUND(100.0 * (new_post_avg_likes - avg_likes) / avg_likes, 1) AS recent_like_change_pct
FROM ig_raw;

-- Q1. Top 10 accounts by followers
SELECT handle, followers, country
FROM ig_clean
ORDER BY followers DESC
LIMIT 10;

-- Q2. Accounts with engagement rate above 5%
SELECT handle, eng_rate_60d, followers
FROM ig_clean
WHERE eng_rate_60d > 5
ORDER BY eng_rate_60d DESC;

-- Q3. Indian accounts with more than 50 million followers
SELECT handle, followers, category
FROM ig_clean
WHERE country = 'India'
  AND followers > 50000000
ORDER BY followers DESC;

-- Q4. Number of accounts per country
SELECT primary_country, COUNT(*) AS accounts
FROM ig_clean
GROUP BY primary_country
ORDER BY accounts DESC;

-- Q5. Average engagement rate per main category
SELECT main_category,
       COUNT(*)                    AS accounts,
       ROUND(AVG(eng_rate_60d), 2) AS avg_eng_rate
FROM ig_clean
GROUP BY main_category
ORDER BY avg_eng_rate DESC;

-- Q6. Top 10 countries by total followers
SELECT primary_country,
       SUM(followers) AS total_followers
FROM ig_clean
GROUP BY primary_country
ORDER BY total_followers DESC
LIMIT 10;

-- Q7. Categories with at least 3 accounts, ranked by engagement
SELECT main_category,
       COUNT(*)                    AS accounts,
       ROUND(AVG(eng_rate_60d), 2) AS avg_eng_rate
FROM ig_clean
GROUP BY main_category
HAVING COUNT(*) >= 3
ORDER BY avg_eng_rate DESC;

-- Q8. Do bigger accounts have lower engagement? (follower tiers)
SELECT
    CASE WHEN followers >= 200000000 THEN '1. Mega (200M+)'
         WHEN followers >= 100000000 THEN '2. Large (100-200M)'
         WHEN followers >=  50000000 THEN '3. Mid (50-100M)'
         ELSE                             '4. Smaller (<50M)' END AS tier,
    COUNT(*)                    AS accounts,
    ROUND(AVG(eng_rate_60d), 2) AS avg_eng_rate
FROM ig_clean
GROUP BY 1
ORDER BY 1;

-- Q9. Top account in each main category
WITH ranked AS (
    SELECT handle, main_category, followers,
           ROW_NUMBER() OVER (PARTITION BY main_category
                              ORDER BY followers DESC) AS rn
    FROM ig_clean
)
SELECT main_category, handle, followers
FROM ranked
WHERE rn = 1
ORDER BY followers DESC;

-- Q10. Accounts that beat their own category's average engagement
WITH cat_avg AS (
    SELECT main_category, AVG(eng_rate_60d) AS cat_avg_eng
    FROM ig_clean
    GROUP BY main_category
)
SELECT c.handle, c.main_category, c.eng_rate_60d,
       ROUND(a.cat_avg_eng, 2) AS category_avg
FROM ig_clean c
JOIN cat_avg a ON a.main_category = c.main_category
WHERE c.eng_rate_60d > a.cat_avg_eng
ORDER BY c.eng_rate_60d - a.cat_avg_eng DESC;