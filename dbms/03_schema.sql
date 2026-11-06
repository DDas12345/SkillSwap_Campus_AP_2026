-- ============================================
-- SkillSwap Campus
-- CP2: PostgreSQL Database Schema
-- ============================================

-- 1. STUDENT TABLE
CREATE TABLE student (
    student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL,
    year_of_study SMALLINT NOT NULL
        CHECK (year_of_study BETWEEN 1 AND 4),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 2. SKILL TABLE
CREATE TABLE skill (
    skill_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(60) NOT NULL,
    description TEXT
);


-- 3. STUDENT_SKILL TABLE
CREATE TABLE student_skill (
    student_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    skill_type VARCHAR(10) NOT NULL
        CHECK (skill_type IN ('TEACH', 'LEARN')),

    PRIMARY KEY (student_id, skill_id, skill_type),

    FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE,

    FOREIGN KEY (skill_id)
        REFERENCES skill(skill_id)
);


-- 4. EXCHANGE_REQUEST TABLE
CREATE TABLE exchange_request (
    request_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    requester_id INTEGER NOT NULL,
    recipient_id INTEGER NOT NULL,

    request_type VARCHAR(10) NOT NULL
        CHECK (request_type IN ('LEARN', 'MUTUAL')),

    requested_skill_id INTEGER NOT NULL,
    offered_skill_id INTEGER,

    status VARCHAR(12) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'ACCEPTED',
                'REJECTED',
                'COMPLETED',
                'CANCELLED'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (requester_id)
        REFERENCES student(student_id),

    FOREIGN KEY (recipient_id)
        REFERENCES student(student_id),

    FOREIGN KEY (requested_skill_id)
        REFERENCES skill(skill_id),

    FOREIGN KEY (offered_skill_id)
        REFERENCES skill(skill_id),

    CHECK (requester_id <> recipient_id),

    CHECK (
        (request_type = 'LEARN' AND offered_skill_id IS NULL)
        OR
        (request_type = 'MUTUAL' AND offered_skill_id IS NOT NULL)
    )
);


-- 5. FEEDBACK TABLE
CREATE TABLE feedback (
    feedback_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    request_id INTEGER NOT NULL,
    learner_id INTEGER NOT NULL,

    rating SMALLINT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),

    comment TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (request_id)
        REFERENCES exchange_request(request_id)
        ON DELETE CASCADE,

    FOREIGN KEY (learner_id)
        REFERENCES student(student_id),

    UNIQUE (request_id, learner_id)
);
