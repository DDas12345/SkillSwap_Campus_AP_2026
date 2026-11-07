-- ============================================================
-- SkillSwap Campus
-- CP3: Application SQL Queries
-- Database: skillswap_campus_ap
-- PostgreSQL 18.6
--
-- READ queries: R1, R2, ...
-- WRITE queries: W1, W2, ...
--
-- Parameters ($1, $2, ...) are supplied by the Node.js backend.
-- ============================================================


-- ============================================================
-- SECTION 1: STUDENT REGISTRATION AND PROFILE
-- ============================================================

-- @R1
-- READ: Find a student during login using their email.
-- The backend must compare the submitted password with password_hash.
SELECT
    student_id,
    full_name,
    email,
    password_hash,
    department,
    year_of_study
FROM student
WHERE email = $1;


-- @R2
-- READ: View a student's profile.
SELECT
    student_id,
    full_name,
    email,
    department,
    year_of_study,
    created_at
FROM student
WHERE student_id = $1;


-- @W1
-- WRITE: Register a new student.
-- The backend must hash the password before inserting it.
INSERT INTO student (
    full_name,
    email,
    password_hash,
    department,
    year_of_study
)
VALUES ($1, $2, $3, $4, $5)
RETURNING student_id, full_name, email, department, year_of_study;


-- @W2
-- WRITE: Update a student's profile.
UPDATE student
SET
    full_name = $2,
    department = $3,
    year_of_study = $4
WHERE student_id = $1
RETURNING student_id, full_name, department, year_of_study;


-- ============================================================
-- SECTION 2: SKILL DISCOVERY AND MANAGEMENT
-- ============================================================

-- @R3
-- READ: Browse all available skills.
SELECT
    skill_id,
    skill_name,
    category,
    description
FROM skill
ORDER BY category, skill_name;


-- @R4
-- READ: Search skills by name or category.
SELECT
    skill_id,
    skill_name,
    category,
    description
FROM skill
WHERE skill_name ILIKE '%' || $1 || '%'
   OR category ILIKE '%' || $1 || '%'
ORDER BY skill_name;


-- @R5
-- READ: View the skills a particular student teaches or wants to learn.
SELECT
    ss.student_id,
    s.skill_id,
    s.skill_name,
    s.category,
    ss.skill_type
FROM student_skill ss
JOIN skill s
    ON s.skill_id = ss.skill_id
WHERE ss.student_id = $1
ORDER BY ss.skill_type, s.skill_name;


-- @R6
-- READ: Find students who teach a particular skill.
SELECT
    st.student_id,
    st.full_name,
    st.department,
    st.year_of_study,
    s.skill_name,
    s.category
FROM student_skill ss
JOIN student st
    ON st.student_id = ss.student_id
JOIN skill s
    ON s.skill_id = ss.skill_id
WHERE ss.skill_id = $1
  AND ss.skill_type = 'TEACH'
  AND st.student_id <> $2
ORDER BY st.full_name;


-- @R7
-- READ: Find students who want to learn a particular skill.
SELECT
    st.student_id,
    st.full_name,
    st.department,
    st.year_of_study,
    s.skill_name
FROM student_skill ss
JOIN student st
    ON st.student_id = ss.student_id
JOIN skill s
    ON s.skill_id = ss.skill_id
WHERE ss.skill_id = $1
  AND ss.skill_type = 'LEARN'
ORDER BY st.full_name;


-- @R8
-- READ: Find potential teachers for the skills a student wants to learn.
SELECT
    learner.student_id AS learner_id,
    learner.full_name AS learner_name,
    teacher.student_id AS teacher_id,
    teacher.full_name AS teacher_name,
    s.skill_id,
    s.skill_name,
    s.category
FROM student_skill wanted
JOIN student_skill offered
    ON offered.skill_id = wanted.skill_id
   AND offered.skill_type = 'TEACH'
JOIN student learner
    ON learner.student_id = wanted.student_id
JOIN student teacher
    ON teacher.student_id = offered.student_id
JOIN skill s
    ON s.skill_id = wanted.skill_id
WHERE wanted.student_id = $1
  AND wanted.skill_type = 'LEARN'
  AND teacher.student_id <> learner.student_id
ORDER BY s.skill_name, teacher.full_name;


-- @W3
-- WRITE: Add a teaching or learning skill to a student's profile.
-- $1 = student_id, $2 = skill_id, $3 = TEACH or LEARN.
INSERT INTO student_skill (
    student_id,
    skill_id,
    skill_type
)
VALUES ($1, $2, $3)
ON CONFLICT (student_id, skill_id, skill_type) DO NOTHING
RETURNING student_id, skill_id, skill_type;


-- @W4
-- WRITE: Remove a skill from a student's profile.
DELETE FROM student_skill
WHERE student_id = $1
  AND skill_id = $2
  AND skill_type = $3
RETURNING student_id, skill_id, skill_type;


-- ============================================================
-- SECTION 3: EXCHANGE REQUEST MANAGEMENT
-- ============================================================

-- @R9
-- READ: View all incoming exchange requests for a student.
SELECT
    er.request_id,
    er.request_type,
    er.status,
    er.created_at,
    requester.student_id AS requester_id,
    requester.full_name AS requester_name,
    recipient.student_id AS recipient_id,
    recipient.full_name AS recipient_name,
    requested.skill_name AS requested_skill,
    offered.skill_name AS offered_skill
FROM exchange_request er
JOIN student requester
    ON requester.student_id = er.requester_id
JOIN student recipient
    ON recipient.student_id = er.recipient_id
JOIN skill requested
    ON requested.skill_id = er.requested_skill_id
LEFT JOIN skill offered
    ON offered.skill_id = er.offered_skill_id
WHERE er.recipient_id = $1
ORDER BY er.created_at DESC;


-- @R10
-- READ: View all exchange requests created by a student.
SELECT
    er.request_id,
    er.request_type,
    er.status,
    er.created_at,
    recipient.full_name AS recipient_name,
    requested.skill_name AS requested_skill,
    offered.skill_name AS offered_skill
FROM exchange_request er
JOIN student recipient
    ON recipient.student_id = er.recipient_id
JOIN skill requested
    ON requested.skill_id = er.requested_skill_id
LEFT JOIN skill offered
    ON offered.skill_id = er.offered_skill_id
WHERE er.requester_id = $1
ORDER BY er.created_at DESC;


-- @R11
-- READ: View the details of one exchange request.
SELECT
    er.request_id,
    er.request_type,
    er.status,
    er.created_at,
    requester.full_name AS requester_name,
    recipient.full_name AS recipient_name,
    requested.skill_name AS requested_skill,
    offered.skill_name AS offered_skill
FROM exchange_request er
JOIN student requester
    ON requester.student_id = er.requester_id
JOIN student recipient
    ON recipient.student_id = er.recipient_id
JOIN skill requested
    ON requested.skill_id = er.requested_skill_id
LEFT JOIN skill offered
    ON offered.skill_id = er.offered_skill_id
WHERE er.request_id = $1;


-- @W5
-- WRITE: Create a one-way LEARN request.
-- The requester must want to learn the skill.
-- The recipient must offer to teach that skill.
-- $1 = requester_id, $2 = recipient_id, $3 = requested_skill_id.
INSERT INTO exchange_request (
    requester_id,
    recipient_id,
    request_type,
    requested_skill_id,
    offered_skill_id
)
SELECT
    $1,
    $2,
    'LEARN',
    $3,
    NULL
WHERE $1 <> $2
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $1
        AND skill_id = $3
        AND skill_type = 'LEARN'
  )
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $2
        AND skill_id = $3
        AND skill_type = 'TEACH'
  )
RETURNING request_id, requester_id, recipient_id, status;


-- @W6
-- WRITE: Create a MUTUAL skill-exchange request.
-- Recipient teaches requested_skill_id and wants offered_skill_id.
-- Requester teaches offered_skill_id and wants requested_skill_id.
-- $1 = requester_id, $2 = recipient_id,
-- $3 = requested_skill_id, $4 = offered_skill_id.
INSERT INTO exchange_request (
    requester_id,
    recipient_id,
    request_type,
    requested_skill_id,
    offered_skill_id
)
SELECT
    $1,
    $2,
    'MUTUAL',
    $3,
    $4
WHERE $1 <> $2
  AND $3 <> $4
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $1
        AND skill_id = $3
        AND skill_type = 'LEARN'
  )
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $2
        AND skill_id = $3
        AND skill_type = 'TEACH'
  )
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $1
        AND skill_id = $4
        AND skill_type = 'TEACH'
  )
  AND EXISTS (
      SELECT 1
      FROM student_skill
      WHERE student_id = $2
        AND skill_id = $4
        AND skill_type = 'LEARN'
  )
RETURNING request_id, requester_id, recipient_id, status;


-- @W7
-- WRITE: Accept a pending request.
-- Only the recipient can accept it.
UPDATE exchange_request
SET status = 'ACCEPTED'
WHERE request_id = $1
  AND recipient_id = $2
  AND status = 'PENDING'
RETURNING request_id, status;


-- @W8
-- WRITE: Reject a pending request.
-- Only the recipient can reject it.
UPDATE exchange_request
SET status = 'REJECTED'
WHERE request_id = $1
  AND recipient_id = $2
  AND status = 'PENDING'
RETURNING request_id, status;


-- @W9
-- WRITE: Cancel a pending request.
-- Only the requester can cancel it.
UPDATE exchange_request
SET status = 'CANCELLED'
WHERE request_id = $1
  AND requester_id = $2
  AND status = 'PENDING'
RETURNING request_id, status;


-- @W10
-- WRITE: Mark an accepted exchange as completed.
-- Either participant can perform this action.
UPDATE exchange_request
SET status = 'COMPLETED'
WHERE request_id = $1
  AND status = 'ACCEPTED'
  AND (requester_id = $2 OR recipient_id = $2)
RETURNING request_id, status;


-- ============================================================
-- SECTION 4: FEEDBACK AND RATINGS
-- ============================================================

-- @R12
-- READ: View feedback and the name of the student who submitted it.
SELECT
    f.feedback_id,
    f.request_id,
    f.learner_id,
    st.full_name AS learner_name,
    f.rating,
    f.comment,
    f.created_at
FROM feedback f
JOIN student st
    ON st.student_id = f.learner_id
WHERE f.request_id = $1
ORDER BY f.created_at DESC;


-- @R13
-- READ: Calculate the average feedback rating submitted by a student.
SELECT
    st.student_id,
    st.full_name,
    ROUND(AVG(f.rating)::NUMERIC, 2) AS average_rating,
    COUNT(f.feedback_id) AS total_feedback
FROM student st
LEFT JOIN feedback f
    ON f.learner_id = st.student_id
WHERE st.student_id = $1
GROUP BY st.student_id, st.full_name;


-- @W11
-- WRITE: Submit feedback after a completed exchange.
-- Only a participant can submit feedback.
-- The UNIQUE constraint prevents duplicate feedback from one learner
-- for the same request.
INSERT INTO feedback (
    request_id,
    learner_id,
    rating,
    comment
)
SELECT
    er.request_id,
    $2,
    $3,
    $4
FROM exchange_request er
WHERE er.request_id = $1
  AND er.status = 'COMPLETED'
  AND (er.requester_id = $2 OR er.recipient_id = $2)
RETURNING feedback_id, request_id, learner_id, rating, comment;


-- ============================================================
-- END OF CP3 APPLICATION QUERIES
-- ============================================================
