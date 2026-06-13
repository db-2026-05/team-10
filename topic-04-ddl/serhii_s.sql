-- ============================================================
-- SECTION 1: DATABASE SETUP & CLEANUP
-- ============================================================

-- Drop existing schema objects if they exist (for development/testing)
-- WARNING: This will delete all data! Comment out for production.
DROP TABLE IF EXISTS goals CASCADE;
DROP TABLE IF EXISTS progress_log CASCADE;
DROP TABLE IF EXISTS progress_metrics CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS personal_training CASCADE;
DROP TABLE IF EXISTS trainer_availability CASCADE;
DROP TABLE IF EXISTS trainer_specializations CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS trainers CASCADE;
DROP TABLE IF EXISTS memberships CASCADE;
DROP TABLE IF EXISTS members CASCADE;

-- Drop ENUM types if they exist
DROP TYPE IF EXISTS equipment_status_enum CASCADE;
DROP TYPE IF EXISTS session_status_enum CASCADE;
DROP TYPE IF EXISTS day_of_week_enum CASCADE;
DROP TYPE IF EXISTS attendance_status_enum CASCADE;
DROP TYPE IF EXISTS membership_type_enum CASCADE;


-- ============================================================
-- SECTION 2: ENUM TYPE DEFINITIONS
-- ============================================================
-- Design Decision: ENUMs enforce data integrity at the database level,
-- preventing invalid values and eliminating the need for lookup tables
-- or application-side validation for simple categorical data.

-- Membership type: monthly, yearly, or premium plan
CREATE TYPE membership_type_enum AS ENUM (
    'monthly',   -- Billed and valid for one calendar month
    'yearly',    -- Billed annually, usually discounted
    'premium'    -- All-inclusive plan with PT sessions included
);

-- Attendance status for class participation
CREATE TYPE attendance_status_enum AS ENUM (
    'present',   -- Member attended the class
    'absent',    -- Member did not show up
    'cancelled'  -- Member cancelled in advance
);

-- Days of the week for recurring schedules
CREATE TYPE day_of_week_enum AS ENUM (
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
);

-- Personal training session status
CREATE TYPE session_status_enum AS ENUM (
    'scheduled',  -- Session is booked and upcoming
    'completed',  -- Session took place successfully
    'cancelled'   -- Session was cancelled by member or trainer
);

-- Equipment availability status
CREATE TYPE equipment_status_enum AS ENUM (
    'available',   -- Ready for use
    'in_use',      -- Currently being used
    'maintenance', -- Under repair or scheduled maintenance
    'retired'      -- Permanently removed from service
);


-- ============================================================
-- SECTION 3: TABLE DEFINITIONS
-- ============================================================

-- ------------------------------------------------------------
-- 🟢 MVP TABLE 1: members
-- ------------------------------------------------------------
-- Core member profiles and contact information.
-- This is the central entity for all member-related operations.
CREATE TABLE members (
    member_id     SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    date_of_birth DATE,
    join_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_members_first_name CHECK (LENGTH(TRIM(first_name)) > 0),
    CONSTRAINT chk_members_last_name CHECK (LENGTH(TRIM(last_name)) > 0),
    CONSTRAINT chk_members_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_members_phone CHECK (phone IS NULL OR phone ~ '^[+]?[0-9]{10,20}$')
);

-- Indexes for members
CREATE UNIQUE INDEX uq_members_email ON members(email);

COMMENT ON TABLE members IS 'Core member profiles for fitness center users';
COMMENT ON COLUMN members.member_id IS 'Surrogate primary key — auto-generated';
COMMENT ON COLUMN members.email IS 'Business identifier — used for login and notifications';
COMMENT ON COLUMN members.phone IS 'Optional contact number supporting international formats';
COMMENT ON COLUMN members.join_date IS 'Date when the member account was created';


-- ------------------------------------------------------------
-- 🟢 MVP TABLE 2: memberships
-- ------------------------------------------------------------
-- Tracks member subscription plans and periods.
-- Supports membership history — members can have multiple memberships over time.
CREATE TABLE memberships (
    membership_id   SERIAL PRIMARY KEY,
    member_id       INTEGER NOT NULL,
    membership_type membership_type_enum NOT NULL,
    price           DECIMAL(10,2) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_memberships_price CHECK (price > 0),
    CONSTRAINT chk_memberships_dates CHECK (end_date > start_date),
    
    -- Foreign Keys
    CONSTRAINT fk_memberships_member FOREIGN KEY (member_id)
        REFERENCES members(member_id) ON DELETE CASCADE
);

-- Indexes for memberships
CREATE INDEX idx_memberships_member_id ON memberships(member_id);
CREATE INDEX idx_memberships_active_lookup ON memberships(member_id, is_active);
CREATE INDEX idx_memberships_history ON memberships(member_id, end_date);

-- Partial unique index: only one active membership per member
CREATE UNIQUE INDEX uq_memberships_one_active 
    ON memberships(member_id) 
    WHERE is_active = TRUE;

COMMENT ON TABLE memberships IS 'Member subscription plans and periods';
COMMENT ON COLUMN memberships.is_active IS 'Only one membership per member should have is_active = TRUE';
COMMENT ON COLUMN memberships.price IS 'Cost in local currency — must be greater than 0';


-- ------------------------------------------------------------
-- 🟢 MVP TABLE 3: trainers
-- ------------------------------------------------------------
-- Trainer profiles for class assignment and personal training.
-- Uses soft delete pattern (is_active flag) to preserve historical data.
CREATE TABLE trainers (
    trainer_id  SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(20),
    hire_date   DATE NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    bio         TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_trainers_first_name CHECK (LENGTH(TRIM(first_name)) > 0),
    CONSTRAINT chk_trainers_last_name CHECK (LENGTH(TRIM(last_name)) > 0),
    CONSTRAINT chk_trainers_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_trainers_phone CHECK (phone IS NULL OR phone ~ '^[+]?[0-9]{10,20}$')
);

-- Indexes for trainers
CREATE UNIQUE INDEX uq_trainers_email ON trainers(email);
CREATE INDEX idx_trainers_active ON trainers(is_active);

COMMENT ON TABLE trainers IS 'Trainer profiles used for class assignment and PT booking';
COMMENT ON COLUMN trainers.is_active IS 'Set to FALSE instead of deleting to preserve historical data';
COMMENT ON COLUMN trainers.bio IS 'Professional background displayed on trainer profile page';


-- ------------------------------------------------------------
-- 🟢 MVP TABLE 4: classes
-- ------------------------------------------------------------
-- Weekly recurring class schedule definitions.
-- Each row represents a weekly slot, not a single event.
CREATE TABLE classes (
    class_id     SERIAL PRIMARY KEY,
    class_name   VARCHAR(100) NOT NULL,
    description  TEXT,
    trainer_id   INTEGER,
    schedule_day day_of_week_enum NOT NULL,
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    capacity     INTEGER NOT NULL DEFAULT 20,
    room         VARCHAR(50),
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_classes_name CHECK (LENGTH(TRIM(class_name)) > 0),
    CONSTRAINT chk_classes_time CHECK (end_time > start_time),
    CONSTRAINT chk_classes_capacity CHECK (capacity > 0),
    
    -- Foreign Keys
    CONSTRAINT fk_classes_trainer FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id) ON DELETE SET NULL
);

-- Indexes for classes
CREATE INDEX idx_classes_trainer_id ON classes(trainer_id);
CREATE INDEX idx_classes_schedule ON classes(schedule_day, start_time);

COMMENT ON TABLE classes IS 'Weekly recurring class definitions — not individual events';
COMMENT ON COLUMN classes.trainer_id IS 'NULL if unassigned — SET NULL on trainer delete';
COMMENT ON COLUMN classes.capacity IS 'Maximum participants allowed';


-- ------------------------------------------------------------
-- 🟢 MVP TABLE 5: attendance
-- ------------------------------------------------------------
-- Records every class attendance event.
-- Links members to specific class dates with attendance status.
CREATE TABLE attendance (
    attendance_id   SERIAL PRIMARY KEY,
    member_id       INTEGER,
    class_id        INTEGER NOT NULL,
    attendance_date DATE NOT NULL,
    status          attendance_status_enum NOT NULL DEFAULT 'present',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_attendance_member FOREIGN KEY (member_id)
        REFERENCES members(member_id) ON DELETE SET NULL,
    CONSTRAINT fk_attendance_class FOREIGN KEY (class_id)
        REFERENCES classes(class_id) ON DELETE CASCADE
);

-- Indexes for attendance
CREATE UNIQUE INDEX uq_attendance_no_duplicate 
    ON attendance(member_id, class_id, attendance_date);
CREATE INDEX idx_attendance_member_id ON attendance(member_id);
CREATE INDEX idx_attendance_class_id ON attendance(class_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);

COMMENT ON TABLE attendance IS 'Records every class attendance event with status tracking';
COMMENT ON COLUMN attendance.member_id IS 'SET NULL on member delete to preserve attendance history';
COMMENT ON COLUMN attendance.status IS 'present = attended | absent = no-show | cancelled = cancelled in advance';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 6: trainer_specializations
-- ------------------------------------------------------------
-- Trainer expertise and certification records.
-- One trainer can have multiple specializations.
CREATE TABLE trainer_specializations (
    specialization_id SERIAL PRIMARY KEY,
    trainer_id        INTEGER NOT NULL,
    specialization    VARCHAR(100) NOT NULL,
    certified         BOOLEAN NOT NULL DEFAULT FALSE,
    cert_date         DATE,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_spec_name CHECK (LENGTH(TRIM(specialization)) > 0),
    
    -- Foreign Keys
    CONSTRAINT fk_spec_trainer FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id) ON DELETE CASCADE
);

-- Indexes for trainer_specializations
CREATE INDEX idx_spec_trainer_id ON trainer_specializations(trainer_id);
CREATE UNIQUE INDEX uq_trainer_specialization 
    ON trainer_specializations(trainer_id, specialization);

COMMENT ON TABLE trainer_specializations IS 'Trainer areas of expertise and certifications';
COMMENT ON COLUMN trainer_specializations.certified IS 'TRUE if trainer holds formal certificate';
COMMENT ON COLUMN trainer_specializations.cert_date IS 'Date certificate was issued — NULL if not certified';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 7: trainer_availability
-- ------------------------------------------------------------
-- Weekly recurring availability windows for PT booking.
-- Defines when trainers are available for personal training sessions.
CREATE TABLE trainer_availability (
    availability_id SERIAL PRIMARY KEY,
    trainer_id      INTEGER NOT NULL,
    day_of_week     day_of_week_enum NOT NULL,
    available_from  TIME NOT NULL,
    available_until TIME NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_avail_time CHECK (available_until > available_from),
    
    -- Foreign Keys
    CONSTRAINT fk_avail_trainer FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id) ON DELETE CASCADE
);

-- Indexes for trainer_availability
CREATE INDEX idx_avail_trainer_id ON trainer_availability(trainer_id);
CREATE UNIQUE INDEX uq_trainer_avail_slot 
    ON trainer_availability(trainer_id, day_of_week, available_from);

COMMENT ON TABLE trainer_availability IS 'Weekly recurring availability windows for personal training';
COMMENT ON COLUMN trainer_availability.available_from IS 'Start time of availability window';
COMMENT ON COLUMN trainer_availability.available_until IS 'End time of availability window';
COMMENT ON INDEX uq_trainer_avail_slot IS 'Prevents duplicate slots; overlaps validated at application level';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 8: personal_training
-- ------------------------------------------------------------
-- One-on-one personal training session bookings.
-- Acts as many-to-many bridge between members and trainers with session metadata.
-- Design Decision: Using TIMESTAMP + duration enables efficient queries like
-- "find all active sessions" with simple WHERE start_at <= NOW() AND start_at + (duration_minutes * INTERVAL '1 minute') >= NOW()
CREATE TABLE personal_training (
    session_id       SERIAL PRIMARY KEY,
    member_id        INTEGER,
    trainer_id       INTEGER,
    start_at         TIMESTAMP NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    status           session_status_enum NOT NULL DEFAULT 'scheduled',
    notes            TEXT,
    price            DECIMAL(10,2),
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_pt_duration CHECK (duration_minutes > 0 AND duration_minutes <= 480),
    CONSTRAINT chk_pt_price CHECK (price IS NULL OR price >= 0),
    
    -- Foreign Keys
    CONSTRAINT fk_pt_member FOREIGN KEY (member_id)
        REFERENCES members(member_id) ON DELETE SET NULL,
    CONSTRAINT fk_pt_trainer FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id) ON DELETE SET NULL
);

-- Indexes for personal_training
CREATE INDEX idx_pt_member_id ON personal_training(member_id);
CREATE INDEX idx_pt_trainer_id ON personal_training(trainer_id);
CREATE INDEX idx_pt_start_at ON personal_training(start_at);
CREATE INDEX idx_pt_active_sessions ON personal_training(start_at, duration_minutes) 
    WHERE status = 'scheduled';

COMMENT ON TABLE personal_training IS 'Personal training session bookings with scheduling and pricing';
COMMENT ON COLUMN personal_training.member_id IS 'SET NULL on member delete to preserve session history';
COMMENT ON COLUMN personal_training.trainer_id IS 'SET NULL on trainer delete to preserve session history';
COMMENT ON COLUMN personal_training.start_at IS 'Session start timestamp — enables efficient "what is running now" queries';
COMMENT ON COLUMN personal_training.duration_minutes IS 'Session length in minutes (typically 30, 60, or 90)';
COMMENT ON INDEX idx_pt_active_sessions IS 'Optimizes queries for currently running or upcoming sessions';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 9: equipment
-- ------------------------------------------------------------
-- Gym equipment inventory management.
-- Tracks equipment status, location, and maintenance history.
CREATE TABLE equipment (
    equipment_id    SERIAL PRIMARY KEY,
    equipment_name  VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    status          equipment_status_enum NOT NULL DEFAULT 'available',
    purchase_date   DATE,
    last_maintained DATE,
    quantity        INTEGER NOT NULL DEFAULT 1,
    location        VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_equipment_name CHECK (LENGTH(TRIM(equipment_name)) > 0),
    CONSTRAINT chk_equipment_quantity CHECK (quantity >= 0)
);

-- Indexes for equipment
CREATE INDEX idx_equipment_status ON equipment(status);
CREATE INDEX idx_equipment_category ON equipment(category);

COMMENT ON TABLE equipment IS 'Gym equipment inventory and maintenance tracking';
COMMENT ON COLUMN equipment.quantity IS 'Number of identical units — can be 0 for retired items';
COMMENT ON COLUMN equipment.last_maintained IS 'Used to trigger maintenance alerts (e.g., > 90 days)';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 10: progress_metrics
-- ------------------------------------------------------------
-- Defines measurable fitness metrics (weight, body fat %, muscle mass, etc.).
-- This reference table allows flexible tracking without schema changes.
-- Design Decision: Normalized metric definitions enable adding new measurements
-- without ALTER TABLE, and support unit standardization for comparisons.
CREATE TABLE progress_metrics (
    metric_id   SERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL UNIQUE,
    unit        VARCHAR(20) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_metric_name CHECK (LENGTH(TRIM(metric_name)) > 0),
    CONSTRAINT chk_metric_unit CHECK (LENGTH(TRIM(unit)) > 0)
);

-- Indexes for progress_metrics
CREATE UNIQUE INDEX uq_progress_metrics_name ON progress_metrics(metric_name);

COMMENT ON TABLE progress_metrics IS 'Defines measurable fitness metrics — enables flexible tracking system';
COMMENT ON COLUMN progress_metrics.metric_name IS 'Display name (e.g., "Body Weight", "Body Fat Percentage", "Bench Press 1RM")';
COMMENT ON COLUMN progress_metrics.unit IS 'Measurement unit (e.g., "kg", "%", "cm", "reps")';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 11: progress_log
-- ------------------------------------------------------------
-- Stores individual fitness metric measurements over time.
-- Each row represents one measurement of one metric for one member on one date.
-- Design Decision: EAV-lite pattern enables:
-- - Historical trend analysis and graphing
-- - Dynamic metric addition without schema migration
-- - Efficient queries: "SELECT * FROM progress_log WHERE member_id = X AND metric_id = Y ORDER BY measured_at"
CREATE TABLE progress_log (
    log_id      SERIAL PRIMARY KEY,
    member_id   INTEGER NOT NULL,
    metric_id   INTEGER NOT NULL,
    value       DECIMAL(10,2) NOT NULL,
    measured_at DATE NOT NULL,
    notes       TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_progress_value CHECK (value >= 0),
    
    -- Foreign Keys
    CONSTRAINT fk_progress_log_member FOREIGN KEY (member_id)
        REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_log_metric FOREIGN KEY (metric_id)
        REFERENCES progress_metrics(metric_id) ON DELETE CASCADE
);

-- Indexes for progress_log
CREATE INDEX idx_progress_log_member_id ON progress_log(member_id);
CREATE INDEX idx_progress_log_metric_id ON progress_log(metric_id);
CREATE INDEX idx_progress_log_member_date ON progress_log(member_id, measured_at DESC);
CREATE INDEX idx_progress_log_member_metric ON progress_log(member_id, metric_id, measured_at DESC);
CREATE UNIQUE INDEX uq_progress_log_one_per_day 
    ON progress_log(member_id, metric_id, measured_at);

COMMENT ON TABLE progress_log IS 'Time-series fitness measurements — one row per member per metric per date';
COMMENT ON COLUMN progress_log.value IS 'Numeric measurement value — unit defined in progress_metrics table';
COMMENT ON COLUMN progress_log.measured_at IS 'Date of measurement — time component not needed for daily snapshots';
COMMENT ON INDEX idx_progress_log_member_metric IS 'Optimizes queries for member progress charts and trend analysis';
COMMENT ON INDEX uq_progress_log_one_per_day IS 'Prevents duplicate measurements — one value per metric per day';


-- ------------------------------------------------------------
-- 🔵 FINAL VERSION TABLE 12: goals
-- ------------------------------------------------------------
-- Member fitness goal tracking.
-- Represents member intentions separate from actual measurements.
CREATE TABLE goals (
    goal_id          SERIAL PRIMARY KEY,
    member_id        INTEGER NOT NULL,
    goal_description TEXT NOT NULL,
    target_date      DATE,
    achieved         BOOLEAN NOT NULL DEFAULT FALSE,
    achieved_date    DATE,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_goals_description CHECK (LENGTH(TRIM(goal_description)) > 0),
    CONSTRAINT chk_goals_achieved_date CHECK (
        (achieved = TRUE AND achieved_date IS NOT NULL) OR 
        (achieved = FALSE AND achieved_date IS NULL)
    ),
    
    -- Foreign Keys
    CONSTRAINT fk_goals_member FOREIGN KEY (member_id)
        REFERENCES members(member_id) ON DELETE CASCADE
);

-- Indexes for goals
CREATE INDEX idx_goals_member_id ON goals(member_id);
CREATE INDEX idx_goals_active ON goals(member_id, achieved);

COMMENT ON TABLE goals IS 'Member fitness goals — represents intention, not measurement';
COMMENT ON COLUMN goals.achieved IS 'TRUE when member has met the goal';
COMMENT ON COLUMN goals.achieved_date IS 'Date goal was achieved — enforced via CHECK constraint';
