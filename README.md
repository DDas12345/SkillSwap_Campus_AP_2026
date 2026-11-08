# SkillSwap Campus — Application Project (AP)

**Project:** SkillSwap Campus  
**Course:** Application Project (AP) — DBMS component  
**Database:** PostgreSQL (`skillswap_campus_ap`)  
**PostgreSQL version:** 18.6  
**Checkpoint status:** CP1–CP4 completed

## 1. Project Overview

SkillSwap Campus is a student skill-exchange platform. It helps students discover skills they want to learn, find other students who can teach those skills, create one-way or mutual skill-exchange requests, and provide feedback after an exchange.

The AP DBMS work covered the database design and implementation behind these features, the SQL operations used by the application, and query execution measurements.

### Main features represented
- Student registration and profile information.
- A catalogue of skills and student teaching/learning preferences.
- Skill discovery and potential-teacher matching.
- One-way (`LEARN`) and mutual (`MUTUAL`) exchange requests.
- Request status management: `PENDING`, `ACCEPTED`, `REJECTED`, `COMPLETED` and `CANCELLED`.
- Feedback and ratings after an exchange.

## 2. Technology

| Area | Technology |
|---|---|
| Database | PostgreSQL 18.6 |
| Database design | ER diagram and relational modelling |
| SQL | PostgreSQL SQL |
| Backend context | Node.js and Express |
| ORM context | Prisma |
| Frontend context | React, JavaScript and CSS |

## 3. Checkpoint Summary

| Checkpoint | Work completed | Main deliverables | Status |
|---|---|---|---|
| **CP1** | Normalization from UNF through 1NF, 2NF, 3NF and BCNF | `dbms/01_normalization.md` | ✅ Completed |
| **CP2** | ER diagram, relational design and PostgreSQL schema | `dbms/02_er_diagram.png`, `dbms/03_schema.sql` | ✅ Completed |
| **CP3** | 13 READ and 11 WRITE application queries | `dbms/04_queries.sql` | ✅ Completed |
| **CP4** | Query timings, execution plans and reproducible benchmark runner | `dbms/05_query_timings.md`, `dbms/plans/`, `dbms/run_ap_benchmark.sh` | ✅ Completed |

---

## 4. CP1 — Database Normalization

The first checkpoint converted the initial SkillSwap Campus data design into a normalized relational structure.

### Work completed
1. Started with an unnormalized structure containing student details, teaching skills, learning skills, exchange requests and feedback.
2. Identified repeating groups and multivalued attributes.
3. Applied **First Normal Form (1NF)** by representing values atomically and separating repeating skill, request and feedback records.
4. Applied **Second Normal Form (2NF)** by separating skill details from student-skill associations and removing the identified partial dependency.
5. Reviewed the relations for **Third Normal Form (3NF)** and transitive dependencies.
6. Checked the final relations against **Boyce-Codd Normal Form (BCNF)** using the functional dependencies and uniqueness assumptions documented in the normalization report.

### Final relations
- `student`
- `skill`
- `student_skill`
- `exchange_request`
- `feedback`

**Deliverable:** [Database normalization](dbms/01_normalization.md)

## 5. CP2 — ER Diagram and PostgreSQL Schema

The second checkpoint translated the normalized design into an entity-relationship model and a PostgreSQL implementation.

### Work completed
- Created an ER diagram showing the five main entities and their relationships.
- Identified attributes, primary keys and foreign-key relationships.
- Implemented the five tables in PostgreSQL.
- Added primary-key, foreign-key, unique and `CHECK` constraints, along with default timestamps.
- Used a composite primary key in `student_skill` for a student's teaching/learning association with a skill.
- Added validation rules for skill types, request types, request statuses, ratings and valid request combinations.
- Created the local database `skillswap_campus_ap` and verified the tables and constraints.

### Database tables
| Table | Purpose |
|---|---|
| `student` | Student identity, login-related fields and academic profile details. |
| `skill` | Available skill names, categories and descriptions. |
| `student_skill` | Links students to skills and records `TEACH` or `LEARN`. |
| `exchange_request` | Stores participants, requested/offered skills, request type and status. |
| `feedback` | Stores feedback for an exchange request, including learner, rating and comment. |

### Important integrity rules
- Student email addresses are unique.
- A student's year of study must be between 1 and 4.
- A student-skill association must use `TEACH` or `LEARN`.
- An exchange request must use `LEARN` or `MUTUAL`.
- A student cannot send an exchange request to themselves.
- A `LEARN` request has no `offered_skill_id`; a `MUTUAL` request must have one.
- Request status is restricted to the defined status values.
- Feedback ratings must be between 1 and 5.
- A learner can submit at most one feedback record for a particular request.

**Deliverables:** [ER diagram](dbms/02_er_diagram.png) · [PostgreSQL schema](dbms/03_schema.sql)

## 6. CP3 — Application SQL Queries

The third checkpoint implemented the SQL operations required by SkillSwap Campus. The query file contains **24 labelled queries: 13 READ and 11 WRITE**.

### READ queries (R1–R13)
| Query | Operation |
|---|---|
| R1 | Find a student by email for login lookup. |
| R2 | Retrieve a student's profile. |
| R3 | Browse all available skills. |
| R4 | Search skills by name or category. |
| R5 | View a student's teaching and learning skills. |
| R6 | Find students who teach a selected skill. |
| R7 | Find students who want to learn a selected skill. |
| R8 | Match a student's learning preferences with potential teachers. |
| R9 | View incoming exchange requests. |
| R10 | View exchange requests created by a student. |
| R11 | Retrieve the details of one exchange request. |
| R12 | View feedback submitted for a request. |
| R13 | Calculate the average feedback rating submitted by a student. |

### WRITE queries (W1–W11)
| Query | Operation |
|---|---|
| W1 | Register a student. |
| W2 | Update a student's profile. |
| W3 | Add a teaching or learning skill to a student's profile. |
| W4 | Remove a skill from a student's profile. |
| W5 | Create a one-way `LEARN` request. |
| W6 | Create a `MUTUAL` skill-exchange request. |
| W7 | Accept a pending request (recipient action). |
| W8 | Reject a pending request (recipient action). |
| W9 | Cancel a pending request (requester action). |
| W10 | Mark an accepted exchange as completed. |
| W11 | Submit feedback for a completed exchange. |

### SQL techniques and testing
The query set uses joins, left joins, subqueries, `EXISTS` checks, `ILIKE` searches, `RETURNING`, `ON CONFLICT` handling, aggregate functions and positional parameters such as `$1`, `$2` and `$3`.

The READ and WRITE operations were manually tested against the local PostgreSQL database using sample records. Testing covered request creation and status transitions, which participant can accept/reject/cancel a request, prevention of cancellation when a request is no longer pending, exchange completion and feedback submission.

**R13 schema clarification:** The current `feedback` table stores `learner_id`, identifying the student who submitted feedback. It does not store a separate identifier for the student being rated. Therefore, R13 calculates the average feedback **submitted by** a student; it does not calculate feedback received by a student.

**Deliverable:** [Application SQL queries](dbms/04_queries.sql)

## 7. CP4 — Query Timings and Execution Plans

The fourth checkpoint measured the execution time of all 24 application queries and recorded their PostgreSQL execution plans.

### Benchmark methodology
- Executed every query **three times**.
- Used `EXPLAIN (ANALYZE, BUFFERS)` to collect execution plans and execution-time measurements.
- Recorded Run 1, Run 2, Run 3, the arithmetic average and observed scan/plan nodes for each query.
- Saved raw output for every query in an individual file under `dbms/plans/`.
- Ran WRITE benchmarks inside `BEGIN`/`ROLLBACK` transactions so benchmark writes did not persist.
- Inserted temporary pending requests inside the same rollback transaction for W7–W9, giving the status-update queries valid test rows.
- Inserted a temporary completed request inside the same rollback transaction for W11, allowing feedback submission to be measured.
- Used a synthetic email and placeholder password hash for W1 timing only; password hashing remains the backend's responsibility.

### CP4 results
| Measurement | Result |
|---|---:|
| READ queries benchmarked | 13 |
| WRITE queries benchmarked | 11 |
| Total queries benchmarked | **24** |
| Runs per query | **3** |
| Raw execution-plan files | **24** |
| Total individual query runs | **72** |

The per-query arithmetic-average execution times in the recorded report ranged from approximately **0.019 ms to 0.483 ms** on the local test database.

### Test dataset and interpretation
The measurements used the local `skillswap_campus_ap` test database containing:
- 4 students
- 4 skills
- 7 student-skill associations
- 4 exchange requests
- 2 feedback records

These measurements document query behaviour on the available small test dataset. They should **not** be interpreted as production-scale or large-dataset performance claims.

### CP4 deliverables
- [Query timing report](dbms/05_query_timings.md) — per-query timings, averages and scan types.
- [Raw execution plans](dbms/plans/) — 24 plan files (`R1.txt`–`R13.txt` and `W1.txt`–`W11.txt`), each containing three runs.
- [Benchmark runner](dbms/run_ap_benchmark.sh) — script used to reproduce the benchmark and regenerate the report and plan files.

### Re-running the benchmark
From the repository root, with PostgreSQL running and the benchmark database available:
```bash
bash dbms/run_ap_benchmark.sh skillswap_campus_ap
```
The script uses the sample records and IDs described in `dbms/05_query_timings.md`. Use a matching test database before rerunning it. WRITE tests are rolled back by the script.

## 8. Repository Structure
```text
SkillSwap_Campus_AP_2026/
├── README.md
└── dbms/
    ├── 01_normalization.md
    ├── 02_er_diagram.png
    ├── 03_schema.sql
    ├── 04_queries.sql
    ├── 05_query_timings.md
    ├── run_ap_benchmark.sh
    └── plans/
        ├── R1.txt ... R13.txt
        └── W1.txt ... W11.txt
```

## 9. Overall Outcome

The AP DBMS work progressed from relational database normalization to ER modelling, PostgreSQL implementation, application query development and query-performance measurement. CP1, CP2, CP3 and CP4 are documented as completed, with the corresponding SQL, design, timing and execution-plan artefacts maintained in this repository.

**GitHub repository:** [SkillSwap Campus — AP 2026](https://github.com/DDas12345/SkillSwap_Campus_AP_2026)

---

*This README summarises the AP DBMS checkpoint work completed for SkillSwap Campus through CP4.*
