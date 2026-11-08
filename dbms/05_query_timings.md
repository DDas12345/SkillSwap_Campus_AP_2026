# CP4 – AP Query Timings

**Project:** SkillSwap Campus  **Database:** `skillswap_campus_ap`  **PostgreSQL:** 18.6 (Postgres.app)

## Methodology

Each of the 24 application queries from `dbms/04_queries.sql` was executed three times with `EXPLAIN (ANALYZE, BUFFERS)`. The average is the arithmetic mean of the three reported Execution Time values. Raw plans are saved as one file per query in `dbms/plans/`. All WRITE tests were run inside `BEGIN; ... ROLLBACK;`. For W7–W9, a valid pending request was inserted inside the same transaction before timing the corresponding status update. For W11, a temporary completed request was inserted before timing feedback submission. The setup rows and the measured write were rolled back together.

**Test data parameters:** Alice (student 1), Bob (2), Cara (3), David (4); skill IDs 1–4 (JavaScript, Python, React, Node.js). R1 used Alice's email. W5 used the valid Alice-to-Bob JavaScript LEARN path; W6 used Bob/Cara's mutual React/JavaScript path.

**Important:** W1 uses a synthetic email and placeholder hash solely for database execution timing; application password hashing remains the backend's responsibility.

## Timing results

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
|---|---|---|---:|---:|---:|---:|---|
| R1 | READ | Login lookup by email | 0.039 | 0.022 | 0.026 | 0.029 | Index Scan using student_email_key on student |
| R2 | READ | View student profile | 0.019 | 0.019 | 0.019 | 0.019 | Index Scan using student_pkey on student |
| R3 | READ | Browse all skills | 0.039 | 0.031 | 0.032 | 0.034 | Seq Scan on skill |
| R4 | READ | Search skills by name or category | 0.044 | 0.041 | 0.043 | 0.043 | Seq Scan on skill |
| R5 | READ | View student's teaching and learning skills | 0.065 | 0.067 | 0.057 | 0.063 | Seq Scan on skill s; Bitmap Heap Scan on student_skill ss; Bitmap Index Scan on student_skill_pkey |
| R6 | READ | Find students who teach a skill | 0.449 | 0.060 | 0.063 | 0.191 | Index Only Scan using student_skill_pkey on student_skill ss; Index Scan using student_pkey on student st; Index Scan using skill_pkey on skill s |
| R7 | READ | Find students who want to learn a skill | 0.076 | 0.109 | 0.076 | 0.087 | Index Only Scan using student_skill_pkey on student_skill ss; Index Scan using student_pkey on student st; Index Scan using skill_pkey on skill s |
| R8 | READ | Find potential teachers for a student's learning skills | 0.080 | 0.076 | 0.085 | 0.080 | Index Only Scan using student_skill_pkey on student_skill wanted; Index Scan using skill_pkey on skill s; Index Only Scan using student_skill_pkey on student_skill offered; Index Scan using student_pkey on student learner; Index Scan using student_pkey on student teacher |
| R9 | READ | View incoming exchange requests | 0.066 | 0.062 | 0.065 | 0.064 | Seq Scan on exchange_request er; Index Scan using student_pkey on student requester; Index Scan using student_pkey on student recipient; Index Scan using skill_pkey on skill requested; Index Scan using skill_pkey on skill offered |
| R10 | READ | View requests created by a student | 0.065 | 0.064 | 0.055 | 0.061 | Seq Scan on exchange_request er; Index Scan using student_pkey on student recipient; Index Scan using skill_pkey on skill requested; Index Scan using skill_pkey on skill offered |
| R11 | READ | View one exchange request | 0.046 | 0.044 | 0.045 | 0.045 | Seq Scan on exchange_request er; Index Scan using student_pkey on student requester; Index Scan using student_pkey on student recipient; Index Scan using skill_pkey on skill requested; Index Scan using skill_pkey on skill offered |
| R12 | READ | View feedback for a request | 0.096 | 0.056 | 0.055 | 0.069 | Seq Scan on student st; Bitmap Heap Scan on feedback f; Bitmap Index Scan on feedback_request_id_learner_id_key |
| R13 | READ | Average feedback submitted by a student | 0.048 | 0.043 | 0.043 | 0.045 | Index Scan using student_pkey on student st; Seq Scan on feedback f |
| W1 | WRITE | Register a student | 0.477 | 0.107 | 0.102 | 0.229 | Insert on student |
| W2 | WRITE | Update student profile | 0.345 | 0.105 | 0.096 | 0.182 | Update on student; Index Scan using student_pkey on student |
| W3 | WRITE | Add a teaching or learning skill | 0.609 | 0.426 | 0.415 | 0.483 | Insert on student_skill |
| W4 | WRITE | Remove a student skill | 0.065 | 0.072 | 0.063 | 0.067 | Delete on student_skill; Index Scan using student_skill_pkey on student_skill |
| W5 | WRITE | Create a one-way LEARN request | 0.523 | 0.402 | 0.431 | 0.452 | Insert on exchange_request; Index Only Scan using student_skill_pkey on student_skill; Index Only Scan using student_skill_pkey on student_skill student_skill_1 |
| W6 | WRITE | Create a MUTUAL skill-exchange request | 0.428 | 0.448 | 0.415 | 0.430 | Insert on exchange_request; Index Only Scan using student_skill_pkey on student_skill; Index Only Scan using student_skill_pkey on student_skill student_skill_1; Index Only Scan using student_skill_pkey on student_skill student_skill_2; Index Only Scan using student_skill_pkey on student_skill student_skill_3 |
| W7 | WRITE | Recipient accepts a pending request | 0.093 | 0.102 | 0.089 | 0.095 | Update on exchange_request; Seq Scan on exchange_request |
| W8 | WRITE | Recipient rejects a pending request | 0.094 | 0.086 | 0.087 | 0.089 | Update on exchange_request; Seq Scan on exchange_request |
| W9 | WRITE | Requester cancels a pending request | 0.084 | 0.088 | 0.082 | 0.085 | Update on exchange_request; Seq Scan on exchange_request |
| W10 | WRITE | Participant completes an accepted exchange | 0.122 | 0.127 | 0.112 | 0.120 | Update on exchange_request; Seq Scan on exchange_request |
| W11 | WRITE | Submit feedback for a completed exchange | 0.146 | 0.108 | 0.101 | 0.118 | Insert on feedback; Seq Scan on exchange_request er |

## Raw execution plans

See `dbms/plans/R1.txt` through `R13.txt` and `dbms/plans/W1.txt` through `W11.txt`. Each file contains all three plan runs.
