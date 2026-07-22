SELECT 
    COUNT(job_title_short) AS title,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM 
    job_postings_fact
WHERE
    job_title_short like '%Analyst%'
GROUP BY
    month
ORDER BY
    title DESC;

SELECT
    AVG(salary_year_avg) AS year_salary,
    AVG(salary_hour_avg) AS hour_salary,
    job_schedule_type
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type;

SELECT 
COUNT(job_postings_fact.job_title_short :: VARCHAR(100)) AS title,
EXTRACT(MONTH FROM (job_postings_fact.job_posted_date AT TIME ZONE 'EST' AT TIME ZONE  'UTC') :: DATE) AS job_month
FROM job_postings_fact
WHERE
job_postings_fact.job_title_short LIKE '%Analyst%'
GROUP BY
job_month
ORDER BY
title DESC
LIMIT 10000;

SELECT
    job_postings_fact.job_schedule_type AS schedule_type,
    AVG(job_postings_fact.salary_year_avg) AS salary_year,
    AVG(job_postings_fact.salary_hour_avg) AS salary_hour
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-06-1'
    AND job_schedule_type IS NOT NULL
GROUP BY
    job_schedule_type
HAVING
    AVG(job_postings_fact.salary_hour_avg) IS NOT NULL
    AND AVG(job_postings_fact.salary_year_avg) IS NOT NULL;

SELECT
EXTRACT(MONTH FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) AS job_month,
COUNT(job_posted_date) as job_posted_count
FROM
job_postings_fact
WHERE
EXTRACT(YEAR FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) = 2023
GROUP BY
EXTRACT(MONTH FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York'))
ORDER BY
job_posted_count DESC;

SELECT
company_dim.name AS company_name,
company_dim.company_id AS company_id,
EXTRACT(MONTH FROM (job_postings_fact.job_posted_date) :: DATE) AS job_posted 
FROM
company_dim
JOIN 
job_postings_fact
ON
company_dim.company_id = job_postings_fact.company_id

WHERE
job_postings_fact.job_health_insurance IS TRUE
AND EXTRACT(YEAR FROM job_posted_date) = 2023
AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2

ORDER BY
job_posted

LIMIT
1000;

CREATE TABLE january_poat AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

 SELECT *
    FROM job_postings_fact;

CREATE TABLE january_post AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_post AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_post AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

DROP TABLE january_poat;

SELECT job_posted_date
FROM january_post;

SELECT
COUNT(job_id) AS mau_ga,
CASE 
WHEN salary_year_avg >= '100000' THEN 'gede euy'
WHEN salary_year_avg <= '80000' THEN 'cil beut'
ELSE 'bolelah yw'
END AS mw_g_y
FROM
job_postings_fact
WHERE
job_title_short = 'Data Analyst'
GROUP BY
mw_g_y;

--subqueries 1
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

SELECT *
FROM (
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1
);

SELECT 
job_title_short, 
COUNT(*) AS total_postings
FROM 
job_postings_fact
GROUP BY 
job_title_short
HAVING COUNT(*) > 1000;

SELECT *
FROM job_postings_fact
WHERE salary_year_avg > (
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
);

SELECT *
FROM job_postings_fact
WHERE 
job_title_short = 'Data Analyst' AND
salary_hour_avg > (
    SELECT AVG(salary_hour_avg)
    FROM job_postings_fact
)

SELECT *
FROM job_postings_fact
WHERE
company_id = (
    SELECT company_id
    FROM company_dim
    WHERE name = 'Oracle'
);

SELECT name
from company_dim
WHERE 
company_id IN (
    SELECT company_id
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1

);

-- Case + CTE
WITH table_nonok_cte AS (
SELECT 
    company_id,
    COUNT (company_id) AS total_jobs
FROM
    job_postings_fact
GROUP BY 
    company_id
)

SELECT company_dim.name,
    table_nonok_cte.total_jobs AS total_job,
CASE 
WHEN table_nonok_cte.total_jobs < '10' THEN 'Small'
WHEN table_nonok_cte.total_jobs BETWEEN '10' AND '50' THEN 'Medium'
WHEN table_nonok_cte.total_jobs > '50' Then 'Large'
ELSE 'No Data'
END AS Rate
FROM company_dim
LEFT JOIN table_nonok_cte ON table_nonok_cte.company_id = company_dim.company_id
ORDER BY total_job ASC;

SELECT company_dim.name company_name,
COUNT(job_postings_fact.job_id) AS job_count
FROM company_dim
LEFT JOIN job_postings_fact ON job_postings_fact.company_id = company_dim.company_id
GROUP BY company_dim.name
ORDER BY 
job_count DESC;

WITH kode_skill AS(
SELECT skill_id,
COUNT(*) AS job_count
FROM skills_job_dim
GROUP BY skill_id
)

SELECT skills_dim.skills,
        kode_skill.job_count
FROM skills_dim 
LEFT JOIN kode_skill ON kode_skill.skill_id = skills_dim.skill_id
ORDER BY kode_skill.job_count DESC;

--subqueries
SELECT name
FROM company_dim
WHERE company_id IN (
    SELECT company_id
    FROM job_postings_fact
    WHERE salary_year_avg > '100000'
);

--join
SELECT 
    skills_dim.skills,
    job_postings_fact.job_title_short
FROM skills_job_dim
LEFT JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
LEFT JOIN  job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id;

--CTE
WITH data_job AS(
SELECT 
    company_id,
    job_title_short,
    salary_year_avg
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
)
SELECT 
    company_dim.name,
    data_job.job_title_short,
    data_job.salary_year_avg
FROM company_dim
LEFT JOIN data_job ON data_job.company_id = company_dim.company_id
WHERE data_job.job_title_short IS NOT NULL
ORDER BY data_job.salary_year_avg DESC
LIMIT 5;

WITH id_skill AS(
SELECT   
skills_job_dim.skill_id AS skill_id,
COUNT(*) AS skill_count
FROM skills_job_dim
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE job_postings_fact.job_work_from_home = TRUE
AND job_title_short = 'Data Analyst'
GROUP BY
skills_job_dim.skill_id
ORDER BY skills_job_dim.skill_id ASC
)

SELECT
id_skill.skill_id,
skills_dim.skills,
id_skill.skill_count
FROM skills_dim
INNER JOIN id_skill ON id_skill.skill_id = skills_dim.skill_id
ORDER BY id_skill.skill_count DESC
LIMIT 5;

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_post

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_post

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_post

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_post;

SELECT 
    union_tables.company_id,
    company_dim.name,
    union_tables.job_title_short,
    union_tables.job_location,
    union_tables.job_via,
    union_tables.job_posted_date :: DATE,
    union_tables.salary_year_avg
FROM (
    SELECT *
    FROM january_post
    UNION ALL
    SELECT *
    FROM february_post
    UNION ALL
    SELECT *
    FROM march_post
) AS union_tables
INNER JOIN company_dim ON company_dim.company_id = union_tables.company_id
WHERE
union_tables.salary_year_avg > '70000'
AND union_tables.job_title_short LIKE '%Data_Analyst%'
ORDER BY
union_tables.salary_year_avg DESC;
