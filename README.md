# SkillSwap Campus — AP DBMS Project

## 1. Project Overview

**SkillSwap Campus** is a student skill-exchange platform designed to connect college students who want to learn new skills with students who can teach them.

The platform allows students to share their knowledge, discover learning opportunities, and collaborate with other students through skill exchanges.

### Key Features

- Student registration and login.
- Student profiles.
- Teaching and learning skill listings.
- Search and discovery of skills.
- One-way and mutual skill-exchange requests.
- Learner feedback after completed exchanges.

## 2. Technology Stack

- **Database:** PostgreSQL
- **Database Design:** Entity Relationship Diagram (ERD)
- **Backend:** Node.js and Express
- **ORM:** Prisma
- **Frontend:** React, JavaScript and CSS

## 3. AP DBMS Project Structure

```text
SkillSwap_Campus_AP_2026/
│
├── README.md
│
└── dbms/
    ├── 01_normalization.md
    ├── 02_er_diagram.png
    ├── 03_schema.sql
    ├── 04_queries.sql       (CP3)
    ├── 05_query_timings.md  (CP4)
    └── plans/               (CP4 execution plans)
```

## 4. Database Design

The database consists of five main tables:

| Table | Purpose |
|---|---|
| `student` | Stores student registration and profile information. |
| `skill` | Stores available skills and their categories. |
| `student_skill` | Connects students with the skills they teach or want to learn. |
| `exchange_request` | Stores one-way and mutual skill-exchange requests. |
| `feedback` | Stores learner feedback and ratings for completed exchanges. |

The ER diagram is available at `dbms/02_er_diagram.png`.

## 5. Checkpoint Progress

| Checkpoint | Deliverable | Status |
|---|---|---|
| CP1 | Database Normalization | ✅ Completed |
| CP2 | ER Diagram | ✅ Completed |
| CP2 | PostgreSQL Schema | ✅ Completed |
| CP3 | Application SQL Queries (13 READ + 11 WRITE) | ✅ Completed |
| CP4 | Query Timings and Execution Plans | ✅ Completed |

## 6. Database Implementation

The PostgreSQL database used for local development is:

`skillswap_campus_ap`

The five database tables have been successfully created and verified using PostgreSQL 18.6.

The schema includes:

- Primary key constraints.
- Foreign key constraints.
- Unique constraints.
- CHECK constraints.
- Composite primary keys.
- Default timestamps.

The schema definition is maintained in `dbms/03_schema.sql`.

## 7. Development Updates

### November 2026

**CP1 — Database Normalization**
- Documented database normalization from UNF to BCNF.
- Identified the final five database relations.

**CP2 — Database Design and Implementation**
- Created the Entity Relationship Diagram.
- Defined entities, attributes, primary keys, foreign keys and relationships.
- Implemented the PostgreSQL schema.
- Created the database and successfully executed all five CREATE TABLE statements.
- Verified database tables, columns and constraints.

**CP3 — Application Queries and Database Operations**
- Added `dbms/04_queries.sql` with 24 labelled application queries: 13 READ queries (R1–R13) and 11 WRITE queries (W1–W11).
- Implemented READ operations for student login lookup, profile retrieval, skill browsing and search, teaching/learning preferences, teacher matching, exchange-request views, request details, and feedback.
- Implemented WRITE operations for student registration, profile updates, skill catalogue and student-skill changes, LEARN and MUTUAL requests, request status transitions, exchange completion, and feedback submission.
- Used joins, subqueries, EXISTS checks, ILIKE searches, RETURNING clauses, ON CONFLICT handling, and positional parameters (`$1`, `$2`, etc.).
- Manually tested the READ and WRITE operations against the local `skillswap_campus_ap` PostgreSQL database using sample records.
- Verified request acceptance, rejection, prevention of cancellation for a non-pending request, exchange completion, and feedback submission.

**R13 clarification:** The current `feedback` table stores `learner_id` but does not store a separate rated-student identifier. Therefore, R13 calculates the average feedback rating **submitted by** a student. It does not claim to calculate ratings received by a student, which the current schema cannot reliably identify.

### CP4 — Query Timings and Execution Plans
- Executed all 24 application queries (13 READ and 11 WRITE) three times each using `EXPLAIN (ANALYZE, BUFFERS)`.
- Recorded the three individual execution times, arithmetic average, and scan type in `dbms/05_query_timings.md`.
- Saved one raw plan file per query in `dbms/plans/` (24 plan files, each containing three runs).
- Executed all WRITE benchmarks within transactions and rolled them back. W7–W9 used temporary pending requests; W11 used a temporary completed request, all inside the same rollback transaction.
- Added `dbms/run_ap_benchmark.sh` to reproduce the benchmark.

**Measurement scope:** Timings were collected on the local `skillswap_campus_ap` database with the small test dataset (4 students, 4 skills, 7 student-skill associations, 4 exchange requests, and 2 feedback records). They are execution measurements for this test dataset, not large-scale performance claims.

Further updates will be documented as development progresses.

## 8. Database Setup

1. Create a PostgreSQL database named `skillswap_campus_ap`.
2. Connect to the database and execute the schema:

   ```bash
   psql -d skillswap_campus_ap -v ON_ERROR_STOP=1 -f dbms/03_schema.sql
   ```

3. Verify that the five tables were created:

   ```bash
   psql -d skillswap_campus_ap -c "\\dt"
   ```

**Note:** The queries in `dbms/04_queries.sql` use positional parameters such as `$1` and `$2`. They are intended to be executed by the application/backend with parameter values supplied at runtime, not as a standalone `psql -f` script without parameter binding.

## 9. Repository

**GitHub Repository:**  
[SkillSwap Campus — AP 2026](https://github.com/DDas12345/SkillSwap_Campus_AP_2026)

---

*This README documents the progress and database implementation of the SkillSwap Campus Application Project (AP).*
