-- ================================================================
-- SQL DML SCRIPT - FITNESS CENTER DATABASE
-- Author: Serhii S.
-- Topic: 09 - Data Manipulation Language
-- ================================================================

-- ============================================================
-- SECTION 1: REFERENCE DATA
-- ============================================================
-- Reference data should be inserted first as other tables depend on it.
-- This includes lookup tables and system configuration data.

-- ------------------------------------------------------------
-- TABLE: progress_metrics
-- ------------------------------------------------------------
-- Define all measurable fitness metrics that members can track.
-- This is one-time setup data that rarely changes.

INSERT INTO progress_metrics (metric_name, unit, description) VALUES
    ('Body Weight', 'kg', 'Total body weight in kilograms'),
    ('Body Fat Percentage', '%', 'Percentage of body mass that is fat tissue'),
    ('Muscle Mass', 'kg', 'Estimated skeletal muscle mass in kilograms'),
    ('Waist Circumference', 'cm', 'Waist measurement at navel level'),
    ('Chest Circumference', 'cm', 'Chest measurement at widest point'),
    ('Bicep Circumference', 'cm', 'Bicep measurement at peak'),
    ('Thigh Circumference', 'cm', 'Thigh measurement at widest point'),
    ('Bench Press 1RM', 'kg', 'One-rep max for barbell bench press'),
    ('Squat 1RM', 'kg', 'One-rep max for barbell back squat'),
    ('Deadlift 1RM', 'kg', 'One-rep max for conventional deadlift');

-- Verify insertion
-- Expected: 10 metrics
SELECT COUNT(*) AS total_metrics FROM progress_metrics;


-- ------------------------------------------------------------
-- TABLE: equipment
-- ------------------------------------------------------------
-- Gym equipment inventory with various categories and statuses.

INSERT INTO equipment (equipment_name, category, status, purchase_date, last_maintained, quantity, location) VALUES
    ('Treadmill', 'Cardio', 'available', '2024-01-15', '2026-05-10', 8, 'Cardio Zone A'),
    ('Elliptical Trainer', 'Cardio', 'available', '2024-01-15', '2026-05-10', 5, 'Cardio Zone A'),
    ('Stationary Bike', 'Cardio', 'available', '2024-02-01', '2026-05-12', 6, 'Cardio Zone B'),
    ('Rowing Machine', 'Cardio', 'maintenance', '2024-03-10', '2026-06-01', 3, 'Cardio Zone B'),
    ('Barbell Set', 'Free Weights', 'available', '2023-12-01', '2026-04-20', 10, 'Weight Room'),
    ('Dumbbell Set (2-50kg)', 'Free Weights', 'available', '2023-12-01', '2026-04-20', 15, 'Weight Room'),
    ('Kettlebell Set', 'Free Weights', 'available', '2024-01-20', '2026-05-15', 12, 'Functional Zone'),
    ('Cable Machine', 'Machines', 'available', '2024-02-15', '2026-05-18', 4, 'Machine Area'),
    ('Leg Press Machine', 'Machines', 'available', '2024-02-15', '2026-05-18', 2, 'Machine Area'),
    ('Smith Machine', 'Machines', 'in_use', '2024-03-01', '2026-05-20', 2, 'Machine Area');

-- Verify insertion
-- Expected: 10 equipment items
SELECT COUNT(*) AS total_equipment FROM equipment;


-- ============================================================
-- SECTION 2: CORE ENTITIES
-- ============================================================
-- Core entities are independent tables that form the foundation
-- of the system: members and trainers.

-- ------------------------------------------------------------
-- TABLE: members
-- ------------------------------------------------------------
-- Fitness center members with realistic personal information.
-- Using privacy-safe sample data.

INSERT INTO members (first_name, last_name, email, phone, date_of_birth, join_date) VALUES
    ('Alex', 'Johnson', 'alex.johnson@email.com', '+380501234567', '1995-03-15', '2025-01-10'),
    ('Maria', 'Garcia', 'maria.garcia@email.com', '+380502345678', '1988-07-22', '2025-01-15'),
    ('James', 'Smith', 'james.smith@email.com', '+380503456789', '1992-11-08', '2025-02-01'),
    ('Emma', 'Brown', 'emma.brown@email.com', '+380504567890', '1990-05-30', '2025-02-10'),
    ('Michael', 'Davis', 'michael.davis@email.com', '+380505678901', '1985-09-12', '2025-02-15'),
    ('Sophia', 'Martinez', 'sophia.martinez@email.com', '+380506789012', '1993-01-25', '2025-03-01'),
    ('William', 'Wilson', 'william.wilson@email.com', '+380507890123', '1991-06-18', '2025-03-05'),
    ('Olivia', 'Anderson', 'olivia.anderson@email.com', '+380508901234', '1994-12-03', '2025-03-20'),
    ('Daniel', 'Taylor', 'daniel.taylor@email.com', '+380509012345', '1987-04-27', '2025-04-01'),
    ('Isabella', 'Thomas', 'isabella.thomas@email.com', '+380500123456', '1996-08-14', '2025-04-10');

-- Verify insertion
-- Expected: 10 members
SELECT COUNT(*) AS total_members FROM members;


-- ------------------------------------------------------------
-- TABLE: trainers
-- ------------------------------------------------------------
-- Certified fitness trainers with diverse backgrounds.

INSERT INTO trainers (first_name, last_name, email, phone, hire_date, is_active, bio) VALUES
    ('Sarah', 'Connor', 'sarah.connor@fitnesscenter.com', '+380511111111', '2023-01-15', TRUE, 
     'Certified personal trainer with 8 years of experience in strength training and body recomposition. Specialized in Olympic weightlifting.'),
    ('John', 'Reese', 'john.reese@fitnesscenter.com', '+380512222222', '2023-03-01', TRUE,
     'Former competitive bodybuilder. Expert in muscle hypertrophy and nutrition planning. ISSA certified.'),
    ('Kate', 'Beckett', 'kate.beckett@fitnesscenter.com', '+380513333333', '2023-06-10', TRUE,
     'Yoga and Pilates instructor with 10+ years experience. Specializes in flexibility and core strength.'),
    ('Richard', 'Castle', 'richard.castle@fitnesscenter.com', '+380514444444', '2023-09-01', TRUE,
     'CrossFit Level 3 trainer. Focuses on functional fitness and HIIT workouts.'),
    ('Leslie', 'Knope', 'leslie.knope@fitnesscenter.com', '+380515555555', '2024-01-05', TRUE,
     'Group fitness instructor specializing in Zumba, aerobics, and dance-based cardio classes.'),
    ('Ron', 'Swanson', 'ron.swanson@fitnesscenter.com', '+380516666666', '2024-02-15', TRUE,
     'Strength and conditioning coach. Former powerlifter with expertise in deadlifts and squats.'),
    ('April', 'Ludgate', 'april.ludgate@fitnesscenter.com', '+380517777777', '2024-03-20', TRUE,
     'Certified nutritionist and personal trainer. Helps clients achieve sustainable fitness goals.'),
    ('Andy', 'Dwyer', 'andy.dwyer@fitnesscenter.com', '+380518888888', '2024-05-01', TRUE,
     'Sports performance coach specializing in athletic training and speed development.'),
    ('Ben', 'Wyatt', 'ben.wyatt@fitnesscenter.com', '+380519999999', '2024-06-01', TRUE,
     'Senior trainer with expertise in corrective exercise and injury prevention.'),
    ('Tom', 'Haverford', 'tom.haverford@fitnesscenter.com', '+380510000000', '2022-08-15', TRUE,
     'Boutique fitness expert. Specializes in TRX, kettlebells, and modern training methods.');

-- Verify insertion
-- Expected: 10 trainers
SELECT COUNT(*) AS total_trainers, 
       SUM(CASE WHEN is_active THEN 1 ELSE 0 END) AS active_trainers
FROM trainers;


-- ============================================================
-- SECTION 3: DEPENDENT ENTITIES
-- ============================================================
-- Tables that depend on core entities (members, trainers).

-- ------------------------------------------------------------
-- TABLE: memberships
-- ------------------------------------------------------------
-- Member subscription plans with various types and durations.
-- Note: Only one active membership per member is allowed (enforced by unique index).

INSERT INTO memberships (member_id, membership_type, price, start_date, end_date, is_active) VALUES
    -- Active memberships
    (1, 'monthly', 50.00, '2026-06-01', '2026-06-30', TRUE),
    (2, 'yearly', 500.00, '2025-01-15', '2026-01-14', TRUE),
    (3, 'premium', 120.00, '2026-06-01', '2026-06-30', TRUE),
    (4, 'yearly', 480.00, '2025-02-10', '2026-02-09', TRUE),
    (5, 'monthly', 50.00, '2026-06-01', '2026-06-30', TRUE),
    (6, 'premium', 1200.00, '2025-03-01', '2026-02-28', TRUE),
    (7, 'monthly', 50.00, '2026-06-01', '2026-06-30', TRUE),
    (8, 'yearly', 500.00, '2025-03-20', '2026-03-19', TRUE),
    (9, 'premium', 120.00, '2026-06-01', '2026-06-30', TRUE),
    (10, 'monthly', 50.00, '2026-06-01', '2026-06-30', TRUE);

-- Verify insertion
-- Expected: 10 memberships (10 active)
SELECT COUNT(*) AS total_memberships,
       SUM(CASE WHEN is_active THEN 1 ELSE 0 END) AS active_memberships
FROM memberships;


-- ------------------------------------------------------------
-- TABLE: classes
-- ------------------------------------------------------------
-- Weekly recurring class schedule with various fitness programs.

INSERT INTO classes (class_name, description, trainer_id, schedule_day, start_time, end_time, capacity, room) VALUES
    ('Morning Yoga', 'Gentle flow yoga perfect for starting your day with mindfulness and flexibility', 3, 'Mon', '07:00', '08:00', 20, 'Studio A'),
    ('HIIT Bootcamp', 'High-intensity interval training for maximum calorie burn', 4, 'Mon', '18:00', '19:00', 25, 'Studio B'),
    ('Spin Class', 'Indoor cycling workout with energizing music', 5, 'Tue', '06:30', '07:30', 15, 'Spin Room'),
    ('Strength Training 101', 'Beginner-friendly introduction to weight training', 1, 'Tue', '17:00', '18:00', 12, 'Weight Room'),
    ('Zumba Dance', 'Latin-inspired dance fitness party', 5, 'Wed', '19:00', '20:00', 30, 'Studio A'),
    ('CrossFit WOD', 'Workout of the day: functional movements at high intensity', 4, 'Thu', '17:30', '18:30', 20, 'CrossFit Box'),
    ('Pilates Core', 'Core strengthening and stability through Pilates method', 3, 'Thu', '10:00', '11:00', 18, 'Studio A'),
    ('Olympic Lifting', 'Advanced weightlifting: snatch and clean & jerk technique', 1, 'Fri', '16:00', '17:30', 10, 'Weight Room'),
    ('Saturday Bootcamp', 'Full-body conditioning with bodyweight and equipment exercises', 6, 'Sat', '09:00', '10:00', 25, 'Studio B'),
    ('Sunday Recovery Yoga', 'Restorative yoga for muscle recovery and relaxation', 3, 'Sun', '10:00', '11:00', 20, 'Studio A');

-- Verify insertion
-- Expected: 10 classes
SELECT COUNT(*) AS total_classes FROM classes;


-- ------------------------------------------------------------
-- TABLE: trainer_specializations
-- ------------------------------------------------------------
-- Trainer expertise areas and certifications.

INSERT INTO trainer_specializations (trainer_id, specialization, certified, cert_date) VALUES
    -- Sarah Connor (trainer 1)
    (1, 'Olympic Weightlifting', TRUE, '2020-06-15'),
    (1, 'Strength & Conditioning', TRUE, '2019-03-20'),
    (1, 'Sports Nutrition', TRUE, '2021-08-10'),
    
    -- John Reese (trainer 2)
    (2, 'Bodybuilding', TRUE, '2018-05-12'),
    (2, 'Nutrition Planning', TRUE, '2019-11-08'),
    (2, 'Hypertrophy Training', FALSE, NULL),
    
    -- Kate Beckett (trainer 3)
    (3, 'Yoga RYT-500', TRUE, '2016-09-01'),
    (3, 'Pilates Mat Certification', TRUE, '2017-04-15'),
    
    -- Richard Castle (trainer 4)
    (4, 'CrossFit Level 3', TRUE, '2021-07-22'),
    (4, 'HIIT Training', TRUE, '2020-02-14'),
    
    -- Leslie Knope (trainer 5)
    (5, 'Group Fitness Instructor', TRUE, '2019-01-10'),
    (5, 'Zumba Instructor', TRUE, '2019-06-05');

-- Verify insertion
-- Expected: 12 specializations
SELECT COUNT(*) AS total_specializations,
       SUM(CASE WHEN certified THEN 1 ELSE 0 END) AS certified_specializations
FROM trainer_specializations;


-- ------------------------------------------------------------
-- TABLE: trainer_availability
-- ------------------------------------------------------------
-- Weekly recurring availability for personal training bookings.

INSERT INTO trainer_availability (trainer_id, day_of_week, available_from, available_until) VALUES
    -- Sarah Connor - Early morning and evening slots
    (1, 'Mon', '08:00', '12:00'),
    (1, 'Wed', '08:00', '12:00'),
    (1, 'Fri', '08:00', '15:00'),
    
    -- John Reese - Afternoon and evening
    (2, 'Tue', '13:00', '20:00'),
    (2, 'Thu', '13:00', '20:00'),
    
    -- Kate Beckett - Morning specialist
    (3, 'Mon', '06:00', '09:00'),
    (3, 'Wed', '06:00', '09:00'),
    
    -- Richard Castle - Evening availability
    (4, 'Mon', '15:00', '19:00'),
    (4, 'Wed', '15:00', '20:00'),
    
    -- Ron Swanson - Full availability
    (6, 'Mon', '08:00', '18:00');

-- Verify insertion
-- Expected: 10 availability slots
SELECT COUNT(*) AS total_availability_slots FROM trainer_availability;


-- ============================================================
-- SECTION 4: TRANSACTIONAL DATA
-- ============================================================
-- Time-based records tracking member activities and progress.

-- ------------------------------------------------------------
-- TABLE: attendance
-- ------------------------------------------------------------
-- Class attendance records for the past few weeks.

INSERT INTO attendance (member_id, class_id, attendance_date, status) VALUES
    -- Week 1 (June 2-8, 2026)
    (1, 1, '2026-06-02', 'present'),
    (2, 1, '2026-06-02', 'present'),
    (3, 1, '2026-06-02', 'absent'),
    (1, 2, '2026-06-02', 'present'),
    (4, 3, '2026-06-03', 'present'),
    (5, 3, '2026-06-03', 'present'),
    (6, 4, '2026-06-03', 'present'),
    (2, 5, '2026-06-04', 'present'),
    (7, 5, '2026-06-04', 'present'),
    (8, 5, '2026-06-04', 'cancelled');

-- Verify insertion
-- Expected: 10 attendance records
SELECT COUNT(*) AS total_attendance,
       SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS attended,
       SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS absent,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM attendance;


-- ------------------------------------------------------------
-- TABLE: personal_training
-- ------------------------------------------------------------
-- Personal training session bookings with various statuses.
-- Using new structure: start_at TIMESTAMP + duration_minutes.

INSERT INTO personal_training (member_id, trainer_id, start_at, duration_minutes, status, notes, price) VALUES
    -- Completed sessions
    (3, 1, '2026-06-02 08:00:00', 60, 'completed', 'Focused on squat form and depth', 75.00),
    (6, 2, '2026-06-03 14:00:00', 90, 'completed', 'Nutrition consultation + training plan', 110.00),
    (9, 3, '2026-06-04 07:00:00', 60, 'completed', 'Morning yoga private session', 70.00),
    (4, 6, '2026-06-05 10:00:00', 60, 'completed', 'Deadlift technique training', 75.00),
    
    -- Upcoming scheduled sessions
    (3, 1, '2026-06-16 08:00:00', 60, 'scheduled', 'Continue squat progression', 75.00),
    (6, 2, '2026-06-17 15:00:00', 60, 'scheduled', 'Upper body hypertrophy', 75.00),
    (9, 3, '2026-06-18 07:00:00', 60, 'scheduled', 'Advanced stretching techniques', 70.00),
    (1, 4, '2026-06-18 17:00:00', 60, 'scheduled', 'HIIT conditioning', 80.00),
    (7, 6, '2026-06-19 11:00:00', 90, 'scheduled', 'Powerlifting assessment and programming', 110.00),
    
    -- Cancelled session
    (5, 4, '2026-06-10 18:00:00', 60, 'cancelled', 'Member cancelled due to work conflict', 80.00);

-- Verify insertion
-- Expected: 10 sessions (4 completed, 5 scheduled, 1 cancelled)
SELECT COUNT(*) AS total_sessions,
       SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) AS scheduled,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM personal_training;


-- ------------------------------------------------------------
-- TABLE: progress_log
-- ------------------------------------------------------------
-- Member fitness measurements over time.
-- Using new normalized structure: metric_id references progress_metrics.

INSERT INTO progress_log (member_id, metric_id, value, measured_at, notes) VALUES
    -- Member 1 - Weight loss journey
    (1, 1, 85.5, '2026-01-15', 'Starting weight'),
    (1, 2, 22.0, '2026-01-15', 'Initial body fat measurement'),
    (1, 1, 82.8, '2026-03-15', 'Consistent training paying off'),
    (1, 2, 20.5, '2026-03-15', NULL),
    
    -- Member 3 - Strength training progress
    (3, 8, 60.0, '2026-02-05', 'Baseline bench press'),
    (3, 9, 100.0, '2026-02-05', 'Baseline squat'),
    (3, 10, 120.0, '2026-02-05', 'Baseline deadlift'),
    
    -- Member 6 - Body recomposition
    (6, 1, 72.0, '2026-03-01', 'Starting premium membership'),
    (6, 2, 28.0, '2026-03-01', 'High body fat - goal to reduce'),
    (6, 3, 50.0, '2026-03-01', 'Muscle mass baseline');

-- Verify insertion
-- Expected: 10 progress measurements
SELECT COUNT(*) AS total_measurements,
       COUNT(DISTINCT member_id) AS members_tracking,
       COUNT(DISTINCT metric_id) AS metrics_used
FROM progress_log;


-- ------------------------------------------------------------
-- TABLE: goals
-- ------------------------------------------------------------
-- Member fitness goals with achievement tracking.

INSERT INTO goals (member_id, goal_description, target_date, achieved, achieved_date) VALUES
    -- Active goals
    (1, 'Reach 75kg body weight and maintain', '2026-08-01', FALSE, NULL),
    (1, 'Run 5K without stopping', '2026-07-15', FALSE, NULL),
    (2, 'Attend 3 classes per week consistently', '2026-12-31', FALSE, NULL),
    (3, 'Bench press 80kg for 1 rep', '2026-07-01', FALSE, NULL),
    (4, 'Lose 5kg and improve endurance', '2026-09-01', FALSE, NULL),
    (5, 'Master proper deadlift form', '2026-07-01', FALSE, NULL),
    (6, 'Gain 5kg lean muscle mass', '2026-09-01', FALSE, NULL),
    (7, 'Complete 10 consecutive pull-ups', '2026-08-15', FALSE, NULL),
    
    -- Achieved goals
    (1, 'Join fitness center and start training', '2025-02-01', TRUE, '2025-01-10'),
    (3, 'Bench press 60kg for 1 rep', '2026-03-01', TRUE, '2026-02-15');

-- Verify insertion
-- Expected: 10 goals (8 active, 2 achieved)
SELECT COUNT(*) AS total_goals,
       SUM(CASE WHEN achieved THEN 1 ELSE 0 END) AS achieved_goals,
       SUM(CASE WHEN NOT achieved THEN 1 ELSE 0 END) AS active_goals
FROM goals;


-- ============================================================
-- SECTION 5: UPDATE SCENARIOS
-- ============================================================
-- Demonstrate realistic data modification operations.

-- ------------------------------------------------------------
-- UPDATE 1: Mark personal training sessions as completed
-- ------------------------------------------------------------
-- Business scenario: After a PT session finishes, update status.
-- This would normally happen through application logic.

UPDATE personal_training
SET status = 'completed',
    updated_at = CURRENT_TIMESTAMP  -- Manual audit timestamp
WHERE start_at < CURRENT_TIMESTAMP
  AND status = 'scheduled';

-- Verify update
SELECT status, COUNT(*) AS count
FROM personal_training
GROUP BY status
ORDER BY status;


-- ------------------------------------------------------------
-- UPDATE 2: Deactivate expired memberships
-- ------------------------------------------------------------
-- Business scenario: Automatic nightly job to mark expired memberships.

UPDATE memberships
SET is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE end_date < CURRENT_DATE
  AND is_active = TRUE;

-- Verify update
SELECT is_active, COUNT(*) AS count
FROM memberships
GROUP BY is_active;


-- ------------------------------------------------------------
-- UPDATE 3: Equipment maintenance status
-- ------------------------------------------------------------
-- Business scenario: Equipment returns from maintenance.

UPDATE equipment
SET status = 'available',
    last_maintained = CURRENT_DATE,
    updated_at = CURRENT_TIMESTAMP
WHERE equipment_name = 'Rowing Machine'
  AND status = 'maintenance';

-- Verify update
SELECT equipment_name, status, last_maintained
FROM equipment
WHERE equipment_name = 'Rowing Machine';


-- ------------------------------------------------------------
-- UPDATE 4: Trainer information update
-- ------------------------------------------------------------
-- Business scenario: Trainer updates their bio.

UPDATE trainers
SET bio = 'Certified personal trainer with 9 years of experience in strength training and body recomposition. Specialized in Olympic weightlifting and powerlifting. Recently certified as a nutrition coach.',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'sarah.connor@fitnesscenter.com';

-- Verify update
SELECT first_name, last_name, bio
FROM trainers
WHERE email = 'sarah.connor@fitnesscenter.com';


-- ------------------------------------------------------------
-- UPDATE 5: Member contact information
-- ------------------------------------------------------------
-- Business scenario: Member changes phone number.

UPDATE members
SET phone = '+380501234999',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'alex.johnson@email.com';

-- Verify update
SELECT first_name, last_name, email, phone
FROM members
WHERE email = 'alex.johnson@email.com';


-- ------------------------------------------------------------
-- UPDATE 6: Class capacity increase
-- ------------------------------------------------------------
-- Business scenario: Popular class gets moved to bigger room.

UPDATE classes
SET capacity = 35,
    room = 'Main Studio',
    updated_at = CURRENT_TIMESTAMP
WHERE class_name = 'Zumba Dance';

-- Verify update
SELECT class_name, capacity, room
FROM classes
WHERE class_name = 'Zumba Dance';


-- ------------------------------------------------------------
-- UPDATE 7: Goal achievement
-- ------------------------------------------------------------
-- Business scenario: Member achieves their fitness goal.

UPDATE goals
SET achieved = TRUE,
    achieved_date = CURRENT_DATE,
    updated_at = CURRENT_TIMESTAMP
WHERE member_id = 3
  AND goal_description = 'Bench press 80kg for 1 rep'
  AND achieved = FALSE;

-- Verify update
SELECT member_id, goal_description, achieved, achieved_date
FROM goals
WHERE member_id = 3
  AND goal_description = 'Bench press 80kg for 1 rep';


-- ============================================================
-- SECTION 6: DELETE SCENARIOS
-- ============================================================
-- Demonstrate data cleanup and management operations.

-- ------------------------------------------------------------
-- DELETE 1: Remove old cancelled personal training sessions
-- ------------------------------------------------------------
-- Business scenario: Cleanup cancelled sessions older than 90 days.
-- This preserves completed sessions for billing history.

DELETE FROM personal_training
WHERE status = 'cancelled'
  AND start_at < CURRENT_DATE - INTERVAL '90 days';

-- Verify deletion
SELECT status, COUNT(*) AS count
FROM personal_training
GROUP BY status;


-- ------------------------------------------------------------
-- DELETE 2: Remove duplicate attendance records (if any)
-- ------------------------------------------------------------
-- Business scenario: Data quality maintenance.
-- NOTE: This shouldn't find anything due to unique constraint,
-- but demonstrates the pattern for data cleanup.

-- First, identify duplicates (for verification)
SELECT member_id, class_id, attendance_date, COUNT(*) AS occurrences
FROM attendance
GROUP BY member_id, class_id, attendance_date
HAVING COUNT(*) > 1;

-- Delete would happen here if duplicates existed
-- (Commented out as constraint prevents duplicates)
-- DELETE FROM attendance a1
-- WHERE EXISTS (
--     SELECT 1 FROM attendance a2
--     WHERE a1.member_id = a2.member_id
--       AND a1.class_id = a2.class_id
--       AND a1.attendance_date = a2.attendance_date
--       AND a1.attendance_id < a2.attendance_id
-- );


-- ------------------------------------------------------------
-- DELETE 3: Remove equipment marked as retired
-- ------------------------------------------------------------
-- Business scenario: Cleanup retired equipment from inventory.
-- NOTE: No retired equipment in our current dataset, but shows pattern.

DELETE FROM equipment
WHERE status = 'retired'
  AND last_maintained < CURRENT_DATE - INTERVAL '1 year';

-- Verify deletion
SELECT status, COUNT(*) AS count
FROM equipment
GROUP BY status;


-- ------------------------------------------------------------
-- DELETE 4: Remove uncertified specializations older than 2 years
-- ------------------------------------------------------------
-- Business scenario: Clean up specializations that were never certified.

DELETE FROM trainer_specializations
WHERE certified = FALSE
  AND created_at < CURRENT_DATE - INTERVAL '2 years';

-- Verify deletion
SELECT certified, COUNT(*) AS count
FROM trainer_specializations
GROUP BY certified;


-- ============================================================
-- SECTION 8: DATA VALIDATION QUERIES
-- ============================================================
-- Verify data integrity and business rules.

-- Check: Only one active membership per member
SELECT member_id, COUNT(*) AS active_memberships
FROM memberships
WHERE is_active = TRUE
GROUP BY member_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows (constraint enforced by unique partial index)

-- Check: All personal training sessions within trainer availability
-- Validates that PT sessions occur during trainer's available time windows
-- Checks: day of week, start time, and session end time
SELECT 
    pt.session_id,
    pt.trainer_id,
    pt.start_at,
    TO_CHAR(pt.start_at, 'Dy') AS session_day,
    pt.start_at::TIME AS session_start_time,
    (pt.start_at + (pt.duration_minutes || ' minutes')::INTERVAL)::TIME AS session_end_time,
    'No matching availability' AS issue
FROM personal_training pt
WHERE pt.status = 'scheduled'
  AND NOT EXISTS (
    SELECT 1 
    FROM trainer_availability ta
    WHERE ta.trainer_id = pt.trainer_id
      -- Match day of week (Mon=1, Tue=2, ... Sun=0)
      AND ta.day_of_week = CASE EXTRACT(DOW FROM pt.start_at)::INTEGER
          WHEN 0 THEN 'Sun'
          WHEN 1 THEN 'Mon'
          WHEN 2 THEN 'Tue'
          WHEN 3 THEN 'Wed'
          WHEN 4 THEN 'Thu'
          WHEN 5 THEN 'Fri'
          WHEN 6 THEN 'Sat'
      END
      -- Session starts within or after availability window
      AND pt.start_at::TIME >= ta.available_from
      -- Session ends before availability window closes
      AND (pt.start_at + (pt.duration_minutes || ' minutes')::INTERVAL)::TIME <= ta.available_until
);
-- Expected: 0 rows if all sessions are properly scheduled
-- Note: This check validates business rule that PT sessions must occur
-- during trainer's declared availability windows

-- Check: Goal achievement dates are consistent
SELECT goal_id, achieved, achieved_date
FROM goals
WHERE (achieved = TRUE AND achieved_date IS NULL)
   OR (achieved = FALSE AND achieved_date IS NOT NULL);
-- Expected: 0 rows (constraint enforced)

-- Check: Progress measurements have valid values
SELECT log_id, metric_id, value
FROM progress_log
WHERE value < 0;
-- Expected: 0 rows (constraint enforced)

-- Check: All active memberships have valid date ranges
SELECT membership_id, start_date, end_date
FROM memberships
WHERE end_date <= start_date;
-- Expected: 0 rows (constraint enforced)


-- ============================================================
-- SECTION 9: SUMMARY STATISTICS
-- ============================================================

SELECT 
    'members' AS table_name, COUNT(*) AS record_count FROM members
UNION ALL
SELECT 'memberships', COUNT(*) FROM memberships
UNION ALL
SELECT 'trainers', COUNT(*) FROM trainers
UNION ALL
SELECT 'classes', COUNT(*) FROM classes
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'trainer_specializations', COUNT(*) FROM trainer_specializations
UNION ALL
SELECT 'trainer_availability', COUNT(*) FROM trainer_availability
UNION ALL
SELECT 'personal_training', COUNT(*) FROM personal_training
UNION ALL
SELECT 'equipment', COUNT(*) FROM equipment
UNION ALL
SELECT 'progress_metrics', COUNT(*) FROM progress_metrics
UNION ALL
SELECT 'progress_log', COUNT(*) FROM progress_log
UNION ALL
SELECT 'goals', COUNT(*) FROM goals
ORDER BY table_name;


-- ================================================================
-- END OF DML SCRIPT
-- ================================================================
-- All tables populated with realistic test data.
-- Constraints validated through DML operations.
-- UPDATE and DELETE scenarios demonstrate business logic.
-- Ready for application development and testing.
-- ================================================================
