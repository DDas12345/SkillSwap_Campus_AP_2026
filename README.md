## CP3 – Application Queries & Database Operations

### Overview

Completed CP3 by implementing and testing the SQL queries required for the SkillSwap Campus application.

### 1. Application Queries

Created `dbms/04_queries.sql`, containing 24 application queries:

| Query Type | Query IDs | Count |
|---|---|---:|
| READ | R1–R13 | 13 |
| WRITE | W1–W11 | 11 |
| **Total** | | **24** |

**READ Operations**
- Student login lookup and profile retrieval.
- Browse and search available skills.
- View students' teaching and learning skills.
- Find potential teachers and skill matches.
- View incoming and outgoing exchange requests.
- Retrieve exchange request details.
- View feedback and calculate average feedback submitted by a student.

**WRITE Operations**
- Register a new student.
- Update student profile information.
- Add skills to the skill catalogue.
- Remove skills from student profiles.
- Create LEARN and MUTUAL exchange requests.
- Accept, reject, and cancel exchange requests.
- Mark accepted exchanges as completed.
- Submit feedback for completed exchanges.

### 2. SQL Features Used

The implementation uses:
- `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.
- `INNER JOIN` and `LEFT JOIN`.
- Subqueries and `EXISTS` conditions.
- `ILIKE` for case-insensitive searches.
- `RETURNING` to retrieve inserted or updated records.
- `ON CONFLICT` for duplicate handling.
- Parameterized queries using `$1`, `$2`, etc.
- Database constraints to maintain data integrity.

### 3. Testing and Verification

Tested all 24 query operations against the local PostgreSQL database using sample records.

The test dataset included:
- 4 students.
- 4 skills.
- Student teaching and learning preferences.
- LEARN and MUTUAL exchange requests.
- Exchange status transitions.
- Feedback submissions.

Verified the READ and WRITE operations, including request acceptance, rejection, cancellation conditions, completion, and feedback submission.

### 4. Important Query Correction

Updated R13 to calculate the average feedback rating **submitted by a student**.

The current database schema stores `learner_id` in the feedback table but does not store a separate rated-student or recipient identifier. Therefore, the current schema supports calculating submitted feedback, not reliably calculating ratings received.

### 5. Files Added or Updated

| File | Purpose |
|---|---|
| `dbms/04_queries.sql` | Contains all 24 application SQL queries |
| `README.md` | Documents CP3 implementation, SQL features, and testing |

### CP3 Completion

The CP3 application-query implementation and manual database testing have been completed for the SkillSwap Campus project.