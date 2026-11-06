# SkillSwap Campus — Database Normalization

## 1. Introduction

SkillSwap Campus is a student skill-exchange platform where students can share skills they are able to teach and discover skills they want to learn.

The application allows students to:

- Register and maintain their accounts.
- Provide academic information such as department and year of study.
- Add skills they can teach.
- Add skills they want to learn.
- Explore skills offered by other students.
- Send one-way or mutual skill-exchange requests.
- Provide feedback after completing an exchange.

The purpose of normalization is to organize the database efficiently, reduce data redundancy, and prevent insertion, update, and deletion anomalies.

This document explains the normalization of the proposed SkillSwap Campus database through First Normal Form (1NF), Second Normal Form (2NF), Third Normal Form (3NF), and Boyce-Codd Normal Form (BCNF).

## 2. Initial Unnormalized Form (UNF)

Initially, student registration details, teaching skills, learning skills, exchange requests, and feedback may be represented in a single unnormalized structure.

### Initial relation

STUDENT_DATA(
student_id,
student_name,
college_email,
password_hash,
department,
year_of_study,
teaching_skills,
learning_skills,
exchange_requests,
feedback
)

Here, teaching_skills, learning_skills, exchange_requests, and feedback may contain multiple values for a single student.

### Problems in UNF

1. Multiple teaching skills may be stored in one field.
2. Multiple learning skills may be stored in one field.
3. Multiple exchange requests may be stored together.
4. Multiple feedback records may be stored together.
5. Searching and updating individual skills becomes difficult.
6. Repeated student information creates data redundancy.

Therefore, the initial structure does not satisfy First Normal Form.

## 3. First Normal Form (1NF)

A relation satisfies First Normal Form when:

- Every attribute contains a single atomic value.
- There are no repeating groups or multivalued attributes.
- Each record can be uniquely identified.

To achieve 1NF, teaching skills, learning skills, exchange requests, and feedback must be represented as separate individual records rather than multiple values in a single field.

### Functional dependencies

The following functional dependencies are identified from the proposed application requirements:

- student_id → full_name, email, password_hash, department, year_of_study
- skill_id → skill_name, category, description
- request_id → requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status, created_at
- feedback_id → request_id, learner_id, rating, comment, created_at

The initial decomposition into atomic records can be represented using:

STUDENT(
student_id,
full_name,
email,
password_hash,
department,
year_of_study
)

SKILL(
skill_id,
skill_name,
category,
description
)

STUDENT_SKILL(
student_id,
skill_id,
skill_type
)

EXCHANGE_REQUEST(
request_id,
requester_id,
recipient_id,
request_type,
requested_skill_id,
offered_skill_id,
status,
created_at
)

FEEDBACK(
feedback_id,
request_id,
learner_id,
rating,
comment,
created_at
)

In STUDENT_SKILL, skill_type indicates whether the student wants to teach or learn the skill.

In EXCHANGE_REQUEST, request_type indicates whether the request is a one-way learning request or a mutual skill exchange.

### Result of 1NF

All attributes contain atomic values, and multiple skills, exchange requests, and feedback records are represented through separate records.

However, the STUDENT_SKILL relation still contains a partial dependency that must be removed.

## 4. Second Normal Form (2NF)

A relation satisfies Second Normal Form when:

- It is already in 1NF.
- Every non-key attribute is fully dependent on the entire candidate key.
- There are no partial functional dependencies on part of a composite candidate key.

Consider the following relation:

STUDENT_SKILL(
student_id,
skill_id,
skill_name,
category,
description,
skill_type
)

Candidate key:

(student_id, skill_id, skill_type)

Functional dependencies:

- (student_id, skill_id, skill_type) → skill_name, category, description
- skill_id → skill_name, category, description

Here, skill_name, category, and description depend only on skill_id rather than the complete composite key.

This is a partial dependency.

### Decomposition into 2NF

To remove the partial dependency, the relation is divided into:

SKILL(
skill_id,
skill_name,
category,
description
)

STUDENT_SKILL(
student_id,
skill_id,
skill_type
)

The primary key of STUDENT_SKILL is the composite key (student_id, skill_id, skill_type).

The primary key of SKILL is skill_id.

### Result of 2NF

The skill details are stored separately from student-skill associations.

This removes the partial dependency and reduces repeated skill information.

## 5. Third Normal Form (3NF)

A relation satisfies Third Normal Form when:

- It is already in 2NF.
- It has no transitive dependency of non-key attributes on candidate keys.

The proposed STUDENT relation is:

STUDENT(
student_id,
full_name,
email,
password_hash,
department,
year_of_study
)

Functional dependency:

student_id → full_name, email, password_hash, department, year_of_study

Assumptions:

- student_id uniquely identifies each student.
- email is also unique.
- Department is stored as a department name rather than being expanded into a separate department catalogue.

Similarly, the SKILL relation is:

SKILL(
skill_id,
skill_name,
category,
description
)

Functional dependency:

skill_id → skill_name, category, description

The STUDENT_SKILL relation is:

STUDENT_SKILL(
student_id,
skill_id,
skill_type
)

Candidate key:

(student_id, skill_id, skill_type)

There are no non-key attributes in this relation.

The EXCHANGE_REQUEST relation is:

EXCHANGE_REQUEST(
request_id,
requester_id,
recipient_id,
request_type,
requested_skill_id,
offered_skill_id,
status,
created_at
)

Functional dependency:

request_id → requester_id, recipient_id, request_type, requested_skill_id, offered_skill_id, status, created_at

The FEEDBACK relation is:

FEEDBACK(
feedback_id,
request_id,
learner_id,
rating,
comment,
created_at
)

Functional dependencies:

- feedback_id → request_id, learner_id, rating, comment, created_at
- (request_id, learner_id) → feedback_id, rating, comment, created_at

The combination of request_id and learner_id is unique because a learner can submit at most one feedback record for a particular exchange request.

### Additional design rules

- An exchange request can be either LEARN or MUTUAL.
- For a LEARN request, offered_skill_id is NULL.
- For a MUTUAL request, offered_skill_id must contain a skill.
- A student cannot send an exchange request to themselves.
- Feedback is submitted by a learner after an exchange is completed.
- In a mutual exchange, both participants are learners and may each submit feedback.

### Final 3NF relations

1. STUDENT(
   student_id,
   full_name,
   email,
   password_hash,
   department,
   year_of_study
   )

2. SKILL(
   skill_id,
   skill_name,
   category,
   description
   )

3. STUDENT_SKILL(
   student_id,
   skill_id,
   skill_type
   )

4. EXCHANGE_REQUEST(
   request_id,
   requester_id,
   recipient_id,
   request_type,
   requested_skill_id,
   offered_skill_id,
   status,
   created_at
   )

5. FEEDBACK(
   feedback_id,
   request_id,
   learner_id,
   rating,
   comment,
   created_at
   )

These relations have been separated to reduce redundancy and maintain data consistency.

## 6. Boyce-Codd Normal Form (BCNF)

BCNF is a stronger form of normalization than 3NF.

A relation satisfies BCNF when every determinant is a candidate key or a superkey.

Under the functional dependencies and uniqueness assumptions defined in this document, the proposed relations satisfy BCNF.

No additional decomposition is required under these assumptions.

BCNF is considered here as an additional normalization check.

## 7. Primary Keys and Foreign Keys

| Relation | Primary Key | Foreign Keys |
|---|---|---|
| STUDENT | student_id | None |
| SKILL | skill_id | None |
| STUDENT_SKILL | (student_id, skill_id, skill_type) | student_id, skill_id |
| EXCHANGE_REQUEST | request_id | requester_id, recipient_id, requested_skill_id, offered_skill_id |
| FEEDBACK | feedback_id | request_id, learner_id |

## 8. Normalization Summary

| Normal Form | Changes Made |
|---|---|
| UNF | Multiple skills, requests, and feedback records may be stored together. |
| 1NF | Repeating groups are removed and values are made atomic. |
| 2NF | Partial dependencies are removed by separating SKILL and STUDENT_SKILL. |
| 3NF | Relations are checked for transitive dependencies. |
| BCNF | Determinants are checked to ensure they are superkeys. |

## 9. Conclusion

The SkillSwap Campus database has been designed using normalization principles to reduce data redundancy and maintain data integrity.

The final design contains five main relations: STUDENT, SKILL, STUDENT_SKILL, EXCHANGE_REQUEST, and FEEDBACK.

The design separates student information, skill information, student-skill associations, exchange requests, and learner feedback.

This structure provides a foundation for implementing the SkillSwap Campus database using PostgreSQL and Prisma.