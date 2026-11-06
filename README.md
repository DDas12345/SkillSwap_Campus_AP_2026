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

The database currently consists of five main tables:

| Table | Purpose |
|---|---|
| STUDENT | Stores student registration and profile information. |
| SKILL | Stores available skills and their categories. |
| STUDENT_SKILL | Connects students with the skills they teach or want to learn. |
| EXCHANGE_REQUEST | Stores one-way and mutual skill-exchange requests. |
| FEEDBACK | Stores learner feedback and ratings for completed exchanges. |

## 5. Checkpoint Progress

| Checkpoint | Deliverable | Status |
|---|---|---|
| CP1 | Database Normalization | ✅ Completed |
| CP2 | ER Diagram | ✅ Completed |
| CP2 | PostgreSQL Schema | ✅ Completed |
| CP3 | SQL Queries | ⏳ Upcoming |
| CP4 | Query Timings and Execution Plans | ⏳ Upcoming |

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

Further updates will be documented as development progresses.

## 8. Repository

**GitHub Repository:**  
[SkillSwap Campus — AP 2026](https://github.com/DDas12345/SkillSwap_Campus_AP_2026)

---

*This README documents the progress and database implementation of the SkillSwap Campus Application Project (AP).* 
