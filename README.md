# Project 1: Data Analyst Job Postings Analysis

## Introduction
This project explores the data analyst job market using SQL, aiming to uncover the top-paying jobs, the most in-demand skills, and the skills that offer the best balance of high demand and high salary — the "optimal" skills for anyone looking to become a Data Analyst. Check them out here: [Project_1_Data_Analyst_Job_Posting 
folder](/Project_1_Data_Analyst_Job_Posting/).

## Background
The dataset used in this project comes from Luke Barousse's SQL course, containing real-world job posting data across multiple roles, including Data Analyst positions.

## The questions i wanted to answer trough my SQL queries were:
1. What are the top paying Data Analyst jobs?
2. What skills are required for these top paying jobs?
3. What are the most in-demand skills for Data Analysts?
4. Which skills are associated with the highest salaries?
5. What are the most optimal skills to learn?

## Tools I Used
- **SQL** – for querying and analyzing the database
- **PostgreSQL** – database management system
- **VS Code** – for writing and running SQL scripts
- **Git & GitHub** – for version control and sharing the project

## The Analysis

### 1. Top Paying Data Analyst Jobs
Identifies [the highest-paying Data Analyst roles](/Project_1_Data_Analyst_Job_Posting/Top_Paying_Job_Data_Analyst) by average yearly salary.
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
![Highest Paying Roles](/assets_project_1/Picture7.png)
*Bar graph visualizing the salary for the top 5 salaries for data analysts; this graph was generated using Excel from my SQL query results*

**Insight:** The highest-paying Data Analyst posting reaches $650,000/year, though salaries drop sharply after the top result, settling around $375K–$400K for the rest of the top 5.

---

### 2. Skills Required for the Top Paying Job
Breaks down which [skills are tied to the single highest-paying](/Project_1_Data_Analyst_Job_Posting/Skill_Required_Top_PaidProject_1_Data_Analyst_Job_Posting/Top_Skilled_By_Salary) Data Analyst posting.

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

**Insight:**  The top-paying posting requires backend and infrastructure skills like Oracle, Kafka, Linux, Git, and SVN, not typical analyst tools like Excel or Tableau. This suggests companies pay a premium for Data Analyst roles that overlap with data engineering or system administration, since those skills are harder to find and tend to command higher salaries.

---

### 3. Most In-Demand Skills
Finds the [skills that appear most frequently](/Project_1_Data_Analyst_Job_Posting/Most_Demand_Skill) across Data Analyst job postings.

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
![Most In-Demand Skills](/assets_project_1/Picture8.png)
*Bar graph visualizing the job posting count for the top 5 most in-demand skills for data analysts; this graph was generated using Excel from my SQL query results*

**Insight:** SQL leads with 92,628 job posting mentions, well ahead of Excel and Python in second and third place. This makes sense since most companies store their data in relational databases, so querying with SQL is a baseline requirement before any other analysis tool comes into play.

---

### 4. Top Paid Skills
[Ranks individual skills](/Project_1_Data_Analyst_Job_Posting/Top_Skilled_By_Salary) by their associated average yearly salary.

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
![Most In-Demand Skills](/assets_project_1/Picture5.png)
*Bar graph visualizing the average yearly salary for the top 5 highest paid skills for data analysts; this graph was generated using Excel from my SQL query results*

**Insight:** SVN tops the list with an average yearly salary of $400K, more than double the next highest skill, Solidity ($179K). These top paid skills tend to be niche and less commonly requested, which likely drives up their value since fewer analysts have them compared to mainstream tools like SQL or Excel.

---

### 5. Most Optimal Skills (High Demand + High Salary)
Combines demand and salary to find [skills that are both frequently requested **and** well-paid](/Project_1_Data_Analyst_Job_Posting/Most_Optimal_Skill), filtering out rarely-requested skills (appearing more than 10 times).

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
![Most Optimal Skill](/assets_project_1/Picture6.png)
*Combo chart visualizing job posting count (bars) and average yearly salary (dots) for the top 5 most optimal data analyst skills; this graph was generated using Excel from my SQL query results*

**Insight:** Python offers the highest average salary among the top optimal skills at $101,512, even though SQL has the highest overall demand with 3,083 job postings. This makes SQL the safer choice for maximizing opportunities, while Python edges out as the better choice if the priority is salary.

## What I Learned
Through this project, I strengthened my SQL skills, including:
- Writing **CTEs (Common Table Expressions)** to break complex queries into readable steps
- Using **INNER JOIN** and **LEFT JOIN** to combine data across multiple related tables
- Applying **aggregate functions** (`COUNT`, `AVG`, `ROUND`) with `GROUP BY` to summarize data
- Using **HAVING** to filter aggregated results (e.g., excluding low-frequency skills)
- Sorting and limiting results with **ORDER BY** and **LIMIT** to extract top-N insights

## Conclusions
### Key Findings

1. **Top Paying Data Analyst Jobs** — The highest-paying Data Analyst posting reaches $650,000/year, though salaries drop sharply after the top result, settling around $375K–$400K for the rest of the top 5.

2. **Skills Required for Top Paying Jobs** — The top-paying posting requires backend and infrastructure skills like Oracle, Kafka, Linux, Git, and SVN, not typical analyst tools like Excel or Tableau. This suggests companies pay a premium for Data Analyst roles that overlap with data engineering or system administration, since those skills are harder to find and tend to command higher salaries.

3. **Most In-Demand Skills** — SQL leads with 92,628 job posting mentions, well ahead of Excel and Python in second and third place. This makes sense since most companies store their data in relational databases, so querying with SQL is a baseline requirement before any other analysis tool comes into play.

4. **Top Paid Skills** — SVN tops the list with an average yearly salary of $400K, more than double the next highest skill, Solidity ($179K). These top paid skills tend to be niche and less commonly requested, which likely drives up their value since fewer analysts have them compared to mainstream tools like SQL or Excel.

5. **Most Optimal Skills** — Python offers the highest average salary among the top optimal skills at $101,512, even though SQL has the highest overall demand with 3,083 job postings. This makes SQL the safer choice for maximizing opportunities, while Python edges out as the better choice if the priority is salary.

### Closing Thoughts

This project strengthened my SQL skills and gave me a clearer picture of the Data Analyst job market. The findings serve as a guide for prioritizing which skills to learn, showing that SQL remains the most in-demand foundation, while skills like Python and niche tools such as SVN offer stronger salary potential. Balancing high-demand and high-paying skills like this can help aspiring Data Analysts position themselves better in a competitive job market. This project also reinforced how valuable SQL is not just for querying data, but for turning raw numbers into insights that actually guide real decisions.