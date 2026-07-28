# Project 1: Data Analyst Job Postings Analysis

## Introduction
This project explores the data analyst job market using SQL, aiming to uncover the top-paying jobs, the most in-demand skills, and the skills that offer the best balance of high demand and high salary — the "optimal" skills for anyone looking to become a Data Analyst.

## Background
The dataset used in this project comes from Luke Barousse's SQL course, containing real-world job posting data across multiple roles, including Data Analyst positions.

## Tools I Used
- **SQL** – for querying and analyzing the database
- **PostgreSQL** – database management system
- **VS Code** – for writing and running SQL scripts
- **Git & GitHub** – for version control and sharing the project

## The Analysis

### 1. Top Paying Data Analyst Jobs
Identifies the highest-paying Data Analyst roles by average yearly salary.

```sql
SELECT
    job_postings_fact.job_title AS role,
    company_dim.name AS company_name,
    job_postings_fact.job_posted_date :: DATE AS posted_date,
    job_postings_fact.salary_year_avg AS yearly_salary
FROM
    job_postings_fact
LEFT JOIN
    company_dim ON company_dim.company_id = job_postings_fact.company_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
ORDER BY
    job_postings_fact.salary_year_avg DESC
LIMIT 5;
```

| Role | Company | Posted Date | Yearly Salary |
|---|---|---|---|
| Data Analyst | Mantys | 2023-02-20 | $650,000 |
| Data base administrator | ЛАНИТ | 2023-10-03 | $400,000 |
| Director of Safety Data Analysis | Torc Robotics | 2023-04-21 | $375,000 |
| Sr Data Analyst | Illuminate Mission Solutions | 2023-04-05 | $375,000 |
| Head of Infrastructure Management & Data Analytics - Financial... | Citigroup, Inc | 2023-07-03 | $375,000 |

**Insight:** The highest-paying Data Analyst posting reaches $650,000/year, though salaries drop sharply after the top result, settling around $375K–$400K for the rest of the top 5.

---

### 2. Skills Required for the Top Paying Job
Breaks down which skills are tied to the single highest-paying Data Analyst posting.

```sql
WITH TOP_SKILL AS(
    SELECT
        skills_job_dim.job_id,
        job_postings_fact.job_title_short,
        skills_dim.skills AS skill_required
    FROM skills_job_dim
    INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
)
SELECT
    job_postings_fact.company_id AS ID,
    job_postings_fact.job_title_short AS job_title,
    job_postings_fact.job_title AS role,
    company_dim.name AS company_name,
    job_postings_fact.job_posted_date :: DATE AS posted_date,
    job_postings_fact.salary_year_avg AS yearly_salary,
    TOP_SKILL.skill_required AS skill_required
FROM
    job_postings_fact
LEFT JOIN
    company_dim ON company_dim.company_id = job_postings_fact.company_id
LEFT JOIN
    TOP_SKILL ON TOP_SKILL.job_id = job_postings_fact.job_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND TOP_SKILL.skill_required IS NOT NULL
ORDER BY
    job_postings_fact.salary_year_avg DESC
LIMIT 5;
```

| Company | Posted Date | Yearly Salary | Skill Required |
|---|---|---|---|
| ЛАНИТ | 2023-10-03 | $400,000 | Oracle |
| ЛАНИТ | 2023-10-03 | $400,000 | Kafka |
| ЛАНИТ | 2023-10-03 | $400,000 | Linux |
| ЛАНИТ | 2023-10-03 | $400,000 | Git |
| ЛАНИТ | 2023-10-03 | $400,000 | SVN |

**Insight:** This top-paying posting (which requires a listed skill) leans toward backend/infrastructure tools — Oracle, Kafka, Linux, Git, and SVN — rather than typical analyst tools like Excel or Tableau.

---

### 3. Most In-Demand Skills
Finds the skills that appear most frequently across Data Analyst job postings.

```sql
SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id) AS skill_counted
FROM skills_job_dim
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY skills_dim.skills
ORDER BY skill_counted DESC
LIMIT 5;
```

| Skill | Demand Count |
|---|---|
| SQL | 92,628 |
| Excel | 67,031 |
| Python | 57,326 |
| Tableau | 46,554 |
| Power BI | 39,468 |

**Insight:** SQL is by far the most requested skill for Data Analyst roles, followed by Excel and Python — confirming these as foundational, must-have skills.

---

### 4. Top Paid Skills
Ranks individual skills by their associated average yearly salary.

```sql
SELECT
    skills_dim.skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS Yearly_salary_AVG
FROM skills_job_dim
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE
    salary_year_avg IS NOT NULL
    AND job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY skills_dim.skill_id
ORDER BY Yearly_salary_AVG DESC
LIMIT 5;
```

| Skill | Yearly Salary AVG |
|---|---|
| SVN | $400,000 |
| Solidity | $179,000 |
| Couchbase | $160,515 |
| Datarobot | $155,486 |
| Golang | $155,000 |

**Insight:** The highest-paid skills are niche and specialized (SVN, Solidity, Couchbase) rather than mainstream analyst tools — but they also appear far less frequently in job postings, meaning fewer opportunities overall.

---

### 5. Most Optimal Skills (High Demand + High Salary)
Combines demand and salary to find skills that are both frequently requested **and** well-paid, filtering out rarely-requested skills (appearing more than 10 times).

```sql
SELECT
    skills_dim.skill_id AS skill_id,
    skills_dim.skills AS skills,
    COUNT(skills_dim.skill_id) AS skill_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS average_yearly_salary
FROM skills_dim
INNER JOIN skills_job_dim ON skills_job_dim.skill_id = skills_dim.skill_id
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE
    job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY skills_dim.skill_id
HAVING COUNT(skills_dim.skill_id) > 10
ORDER BY skill_count DESC, average_yearly_salary DESC
LIMIT 5;
```

| Skill | Skill Count | Avg Yearly Salary |
|---|---|---|
| SQL | 3,083 | $96,435 |
| Excel | 2,143 | $86,419 |
| Python | 1,840 | $101,512 |
| Tableau | 1,659 | $97,978 |
| R | 1,073 | $98,708 |

**Insight:** Among skills with solid demand (10+ postings), Python offers the best average salary, while SQL remains the most in-demand overall — making SQL + Python a strong combination to prioritize.

## What I Learned
Through this project, I strengthened my SQL skills, including:
- Writing **CTEs (Common Table Expressions)** to break complex queries into readable steps
- Using **INNER JOIN** and **LEFT JOIN** to combine data across multiple related tables
- Applying **aggregate functions** (`COUNT`, `AVG`, `ROUND`) with `GROUP BY` to summarize data
- Using **HAVING** to filter aggregated results (e.g., excluding low-frequency skills)
- Sorting and limiting results with **ORDER BY** and **LIMIT** to extract top-N insights

## Conclusions
The analysis shows that **SQL, Excel, and Python** are the most in-demand skills for Data Analyst roles, while niche skills like **SVN, Solidity, and Couchbase** command the highest average salaries but appear far less frequently. Balancing both demand and salary, **SQL and Python stand out as the most optimal skills to prioritize** — they're widely requested by employers and consistently tied to strong compensation. For anyone aiming to break into or grow in the Data Analyst field, focusing on these two skills first, then branching into complementary tools like Tableau or R, offers the most practical and rewarding learning path.
