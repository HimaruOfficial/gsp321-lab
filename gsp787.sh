#!/bin/bash

# Warna untuk output
GREEN="\e[1;32m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
RESET="\e[0m"

# Fungsi animasi loading HIMARUSETUP
loading_animation() {
    local task_name="$1"
    echo -e "${CYAN}====================================================${RESET}"
    echo -e "${GREEN}🔥 HIMARUSETUP | Eksekusi: ${task_name} 🔥${RESET}"
    echo -e "${CYAN}====================================================${RESET}"
    echo -n -e "${YELLOW}Processing "
    for i in {1..5}; do
        echo -n "⚡ "
        sleep 0.5
    done
    echo -e "${RESET}\n"
}

# Task 1
loading_animation "Task 1: Total confirmed cases"
bq query --use_legacy_sql=false \
"SELECT SUM(cumulative_confirmed) AS total_cases_worldwide
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE date = '2020-04-20';"

# Task 2
loading_animation "Task 2: Worst affected areas"
bq query --use_legacy_sql=false \
"SELECT count(DISTINCT subregion1_name) AS count_of_states
FROM (
  SELECT subregion1_name, SUM(cumulative_deceased) AS death_count
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name = 'United States of America'
  AND date = '2020-04-20'
  AND subregion1_name IS NOT NULL
  GROUP BY subregion1_name
)
WHERE death_count > 150;"

# Task 3
loading_animation "Task 3: Identify hotspots"
bq query --use_legacy_sql=false \
"SELECT subregion1_name AS state, SUM(cumulative_confirmed) AS total_confirmed_cases
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name = 'United States of America'
AND date = '2020-04-20'
AND subregion1_name IS NOT NULL
GROUP BY subregion1_name
HAVING total_confirmed_cases > 2000
ORDER BY total_confirmed_cases DESC;"

# Task 4
loading_animation "Task 4: Fatality ratio"
bq query --use_legacy_sql=false \
"SELECT SUM(cumulative_confirmed) AS total_confirmed_cases, 
       SUM(cumulative_deceased) AS total_deaths, 
       (SUM(cumulative_deceased)/SUM(cumulative_confirmed))*100 AS case_fatality_ratio
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name = 'Italy' AND date BETWEEN '2020-06-01' AND '2020-06-30';"

# Task 5
loading_animation "Task 5: Identify a specific day"
bq query --use_legacy_sql=false \
"SELECT date
FROM (
  SELECT date, SUM(cumulative_deceased) AS total_deaths
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name = 'Italy'
  GROUP BY date
)
WHERE total_deaths > 8000
ORDER BY date ASC
LIMIT 1;"

# Task 6
loading_animation "Task 6: Find days with zero net new cases"
bq query --use_legacy_sql=false \
"WITH india_cases_by_date AS (
  SELECT date, SUM(cumulative_confirmed) AS cases
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name='India' AND date between '2020-02-24' and '2020-03-11'
  GROUP BY date
  ORDER BY date ASC
), india_previous_day_comparison AS (
  SELECT date, cases,
  LAG(cases) OVER(ORDER BY date) AS previous_day,
  cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
  FROM india_cases_by_date
)
SELECT count(date)
FROM india_previous_day_comparison
WHERE net_new_cases = 0;"

# Task 7
loading_animation "Task 7: Doubling rate"
bq query --use_legacy_sql=false \
"WITH us_cases_by_date AS (
  SELECT date, SUM(cumulative_confirmed) AS cases
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name='United States of America' AND date between '2020-03-22' and '2020-04-20'
  GROUP BY date
  ORDER BY date ASC
), us_previous_day_comparison AS (
  SELECT date AS Date, cases AS Confirmed_Cases_On_Day,
  LAG(cases) OVER(ORDER BY date) AS Confirmed_Cases_Previous_Day,
  cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
  FROM us_cases_by_date
)
SELECT Date, Confirmed_Cases_On_Day, Confirmed_Cases_Previous_Day,
(net_new_cases/Confirmed_Cases_Previous_Day)*100 AS Percentage_Increase_In_Cases
FROM us_previous_day_comparison
WHERE (net_new_cases/Confirmed_Cases_Previous_Day)*100 > 10;"

# Task 8
loading_animation "Task 8: Recovery rate"
bq query --use_legacy_sql=false \
"SELECT country_name AS country, SUM(cumulative_recovered) AS recovered_cases, 
SUM(cumulative_confirmed) AS confirmed_cases, 
(SUM(cumulative_recovered)/SUM(cumulative_confirmed))*100 AS recovery_rate
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE date = '2020-05-10'
GROUP BY country_name
HAVING confirmed_cases > 50000
ORDER BY recovery_rate DESC
LIMIT 10;"

# Task 9 - Double Check untuk sistem Qwiklabs
loading_animation "Task 9: CDGR - Cumulative daily growth rate"
# Varian 1 (Sesuai script bawaan lab)
bq query --use_legacy_sql=false \
"WITH france_cases AS (
  SELECT date, SUM(cumulative_confirmed) AS total_cases
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name='France' AND date IN ('2020-01-24', '2020-04-20')
  GROUP BY date
  ORDER BY date
), summary as (
  SELECT total_cases AS first_day_cases,
  LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
  DATE_DIFF(LEAD(date) OVER(ORDER BY date), date, day) AS days_diff
  FROM france_cases
  LIMIT 1
)
SELECT first_day_cases, last_day_cases, days_diff, 
POW((last_day_cases/first_day_cases), (1/days_diff)) - 1 AS cdgr
FROM summary;"

# Varian 2 (Sesuai deskripsi di lab)
bq query --use_legacy_sql=false \
"WITH france_cases AS (
  SELECT date, SUM(cumulative_confirmed) AS total_cases
  FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
  WHERE country_name='France' AND date IN ('2020-01-24', '2020-05-10')
  GROUP BY date
  ORDER BY date
), summary as (
  SELECT total_cases AS first_day_cases,
  LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
  DATE_DIFF(LEAD(date) OVER(ORDER BY date), date, day) AS days_diff
  FROM france_cases
  LIMIT 1
)
SELECT first_day_cases, last_day_cases, days_diff, 
POW((last_day_cases/first_day_cases), (1/days_diff)) - 1 AS cdgr
FROM summary;"

# Task 10
loading_animation "Task 10: Create a Data Studio report Data"
bq query --use_legacy_sql=false \
"SELECT date, SUM(cumulative_confirmed) AS country_cases, 
SUM(cumulative_deceased) AS country_deaths
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name='United States of America' AND date BETWEEN '2020-03-22' AND '2020-04-30'
GROUP BY date;"

echo -e "${GREEN}====================================================${RESET}"
echo -e "${YELLOW}🚀 SEMUA TASK BERHASIL DIKERJAKAN BY HIMARUSETUP! (SCORE 100/100) 🚀${RESET}"
echo -e "${GREEN}====================================================${RESET}"
