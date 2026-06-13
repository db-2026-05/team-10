-- ============================================================
-- TOPIC 10: SQL VIEWS - FITNESS CENTER DATABASE
-- ============================================================
-- Author: Serhii Smaha
-- Date: 2026-06-13
-- Purpose: Demonstrate various SQL view patterns and practical use cases
--          for the fitness center management system.
-- ============================================================


-- ============================================================
-- SECTION 1: HORIZONTAL VIEWS
-- ============================================================
-- Horizontal views select specific columns from a table,
-- hiding sensitive or unnecessary data from certain users.

-- ------------------------------------------------------------
-- VIEW 01: Member Contact Information
-- ------------------------------------------------------------
-- Purpose: Provide member contact details without exposing
--          sensitive personal information (DOB, join date, etc.)
-- Use Case: Front desk staff lookup, marketing campaigns
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_member_contacts AS
SELECT 
    member_id,
    first_name,
    last_name,
    email,
    phone
FROM members;

COMMENT ON VIEW v_member_contacts IS 
'Horizontal view: Member contact information only (hides DOB, join date)';


-- ------------------------------------------------------------
-- VIEW 02: Trainer Public Profiles
-- ------------------------------------------------------------
-- Purpose: Show trainer information suitable for public display
--          on website or mobile app
-- Use Case: Member browsing trainers for PT booking
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_trainer_profiles AS
SELECT 
    trainer_id,
    first_name,
    last_name,
    bio,
    hire_date
FROM trainers
WHERE is_active = TRUE;

COMMENT ON VIEW v_trainer_profiles IS 
'Horizontal view: Public trainer profiles (hides email, phone)';


-- ============================================================
-- SECTION 2: VERTICAL VIEWS
-- ============================================================
-- Vertical views filter rows based on specific conditions,
-- showing only a subset of data that meets certain criteria.

-- ------------------------------------------------------------
-- VIEW 03: Active Members Only
-- ------------------------------------------------------------
-- Purpose: Show only members with currently active memberships
-- Use Case: Gym access control, member statistics, active roster
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_members AS
SELECT 
    m.*
FROM members m
WHERE EXISTS (
    SELECT 1 
    FROM memberships ms
    WHERE ms.member_id = m.member_id 
      AND ms.is_active = TRUE
);

COMMENT ON VIEW v_active_members IS 
'Vertical view: Only members with active memberships';


-- ------------------------------------------------------------
-- VIEW 04: Available Equipment
-- ------------------------------------------------------------
-- Purpose: Show only equipment that is currently available for use
-- Use Case: Real-time equipment availability board
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_available_equipment AS
SELECT *
FROM equipment
WHERE status = 'available' 
  AND quantity > 0;

COMMENT ON VIEW v_available_equipment IS 
'Vertical view: Equipment ready for use (status = available, quantity > 0)';


-- ============================================================
-- SECTION 3: MIXED VIEWS
-- ============================================================
-- Mixed views combine both column selection AND row filtering,
-- providing targeted data subsets for specific use cases.

-- ------------------------------------------------------------
-- VIEW 05: Active Trainer Contact Info
-- ------------------------------------------------------------
-- Purpose: Contact details for currently employed trainers only
-- Use Case: Staff directory, emergency contact list
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_trainers_contact AS
SELECT 
    trainer_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date
FROM trainers
WHERE is_active = TRUE;

COMMENT ON VIEW v_active_trainers_contact IS 
'Mixed view: Contact info for active trainers only (columns + rows filtered)';


-- ------------------------------------------------------------
-- VIEW 06: Current Week Attendance Summary
-- ------------------------------------------------------------
-- Purpose: This week's attendance records with essential details
-- Use Case: Weekly attendance reports, member engagement tracking
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_current_week_attendance AS
SELECT 
    attendance_id,
    member_id,
    class_id,
    attendance_date,
    status
FROM attendance
WHERE attendance_date >= DATE_TRUNC('week', CURRENT_DATE)
  AND attendance_date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week';

COMMENT ON VIEW v_current_week_attendance IS 
'Mixed view: This week''s attendance with key columns only';


-- ============================================================
-- SECTION 4: JOIN-BASED VIEWS
-- ============================================================
-- Join-based views combine data from multiple tables,
-- denormalizing data for easier querying and reporting.

-- ------------------------------------------------------------
-- VIEW 07: Complete Class Schedule
-- ------------------------------------------------------------
-- Purpose: Full class schedule with trainer names and details
-- Use Case: Weekly schedule display, class finder, booking interface
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_class_schedule AS
SELECT 
    c.class_id,
    c.class_name,
    c.description,
    c.schedule_day,
    c.start_time,
    c.end_time,
    c.capacity,
    c.room,
    t.trainer_id,
    t.first_name || ' ' || t.last_name AS trainer_name,
    t.email AS trainer_email
FROM classes c
LEFT JOIN trainers t ON c.trainer_id = t.trainer_id;

COMMENT ON VIEW v_class_schedule IS 
'Join-based view: Class schedule with trainer information';


-- ------------------------------------------------------------
-- VIEW 08: Member Membership Details
-- ------------------------------------------------------------
-- Purpose: Member profiles with current membership information
-- Use Case: Member account page, check-in verification
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_member_membership_details AS
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    m.email,
    m.phone,
    m.join_date,
    ms.membership_id,
    ms.membership_type,
    ms.start_date,
    ms.end_date,
    ms.price,
    CASE 
        WHEN ms.end_date >= CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_valid
FROM members m
INNER JOIN memberships ms ON m.member_id = ms.member_id
WHERE ms.is_active = TRUE;

COMMENT ON VIEW v_member_membership_details IS 
'Join-based view: Members with active membership details and validity status';


-- ------------------------------------------------------------
-- VIEW 09: Trainer Schedule with Availability
-- ------------------------------------------------------------
-- Purpose: Trainer profiles with specializations and availability
-- Use Case: PT booking system, trainer assignment
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_trainer_schedule AS
SELECT 
    t.trainer_id,
    t.first_name || ' ' || t.last_name AS trainer_name,
    t.email,
    t.phone,
    ts.specialization,
    ts.certified,
    ts.cert_date,
    ta.day_of_week,
    ta.available_from,
    ta.available_until
FROM trainers t
LEFT JOIN trainer_specializations ts ON t.trainer_id = ts.trainer_id
LEFT JOIN trainer_availability ta ON t.trainer_id = ta.trainer_id
WHERE t.is_active = TRUE;

COMMENT ON VIEW v_trainer_schedule IS 
'Join-based view: Active trainers with specializations and availability windows';


-- ------------------------------------------------------------
-- VIEW 10: Personal Training Sessions Detail
-- ------------------------------------------------------------
-- Purpose: PT sessions with member and trainer information
-- Use Case: Session management, billing, calendar view
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_pt_sessions_detail AS
SELECT 
    pt.session_id,
    pt.start_at,
    pt.duration_minutes,
    pt.status,
    pt.price,
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email AS member_email,
    t.trainer_id,
    t.first_name || ' ' || t.last_name AS trainer_name,
    t.email AS trainer_email,
    pt.notes
FROM personal_training pt
LEFT JOIN members m ON pt.member_id = m.member_id
LEFT JOIN trainers t ON pt.trainer_id = t.trainer_id;

COMMENT ON VIEW v_pt_sessions_detail IS 
'Join-based view: Personal training sessions with member and trainer details';


-- ============================================================
-- SECTION 5: SUBQUERY-BASED VIEWS
-- ============================================================
-- Subquery-based views use nested queries to filter or aggregate
-- data based on complex conditions.

-- ------------------------------------------------------------
-- VIEW 11: Members with Active Goals
-- ------------------------------------------------------------
-- Purpose: List members who have at least one active (unachieved) goal
-- Use Case: Goal tracking reports, member engagement metrics
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_members_with_goals AS
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    m.email,
    (SELECT COUNT(*) 
     FROM goals g 
     WHERE g.member_id = m.member_id 
       AND g.achieved = FALSE) AS active_goals_count,
    (SELECT COUNT(*) 
     FROM goals g 
     WHERE g.member_id = m.member_id 
       AND g.achieved = TRUE) AS achieved_goals_count
FROM members m
WHERE EXISTS (
    SELECT 1 
    FROM goals g 
    WHERE g.member_id = m.member_id
);

COMMENT ON VIEW v_members_with_goals IS 
'Subquery-based view: Members with goal counts (uses correlated subqueries)';


-- ------------------------------------------------------------
-- VIEW 12: Popular Classes (High Attendance)
-- ------------------------------------------------------------
-- Purpose: Classes with above-average attendance rates
-- Use Case: Schedule optimization, resource allocation
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_popular_classes AS
SELECT 
    c.class_id,
    c.class_name,
    c.schedule_day,
    c.start_time,
    t.first_name || ' ' || t.last_name AS trainer_name,
    (SELECT COUNT(*) 
     FROM attendance a 
     WHERE a.class_id = c.class_id 
       AND a.status = 'present') AS total_attendance
FROM classes c
LEFT JOIN trainers t ON c.trainer_id = t.trainer_id
WHERE (
    SELECT COUNT(*) 
    FROM attendance a 
    WHERE a.class_id = c.class_id 
      AND a.status = 'present'
) > (
    SELECT AVG(attendance_count)::INTEGER
    FROM (
        SELECT COUNT(*) AS attendance_count
        FROM attendance
        WHERE status = 'present'
        GROUP BY class_id
    ) AS avg_calc
);

COMMENT ON VIEW v_popular_classes IS 
'Subquery-based view: Classes with above-average attendance (uses aggregate subquery)';


-- ============================================================
-- SECTION 6: UNION-BASED VIEWS
-- ============================================================
-- UNION-based views combine compatible result sets from
-- different tables or queries.

-- ------------------------------------------------------------
-- VIEW 13: All Staff (Trainers + Potential Admin)
-- ------------------------------------------------------------
-- Purpose: Combined staff directory showing all personnel
-- Use Case: Company directory, emergency contacts, payroll
-- Note: Currently only trainers; structure allows future admin table
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_all_staff AS
SELECT 
    'Trainer' AS role,
    trainer_id AS staff_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date AS employment_date,
    is_active
FROM trainers
-- Future extension point: add admin staff, managers, etc.
-- UNION ALL
-- SELECT 
--     'Manager' AS role,
--     manager_id AS staff_id,
--     first_name,
--     last_name,
--     email,
--     phone,
--     hire_date AS employment_date,
--     is_active
-- FROM managers
ORDER BY last_name, first_name;

COMMENT ON VIEW v_all_staff IS 
'UNION-based view: All staff members (extensible for future roles)';


-- ------------------------------------------------------------
-- VIEW 14: Upcoming Fitness Events
-- ------------------------------------------------------------
-- Purpose: Combined calendar of all upcoming fitness activities
-- Use Case: Member dashboard, weekly schedule, mobile app calendar
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_upcoming_events AS
-- Upcoming group classes (next 7 days)
SELECT 
    'Group Class' AS event_type,
    c.class_name AS event_name,
    NULL::INTEGER AS participant_id,
    CURRENT_DATE + ((EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 
        CASE c.schedule_day
            WHEN 'Mon' THEN 1
            WHEN 'Tue' THEN 2
            WHEN 'Wed' THEN 3
            WHEN 'Thu' THEN 4
            WHEN 'Fri' THEN 5
            WHEN 'Sat' THEN 6
            WHEN 'Sun' THEN 0
        END - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 7) % 7) * INTERVAL '1 day' 
        + c.start_time AS event_datetime,
    (c.end_time - c.start_time) AS duration_interval,
    t.first_name || ' ' || t.last_name AS trainer_name,
    c.room AS location
FROM classes c
LEFT JOIN trainers t ON c.trainer_id = t.trainer_id

UNION ALL

-- Scheduled personal training sessions (next 7 days)
SELECT 
    'Personal Training' AS event_type,
    'PT Session' AS event_name,
    pt.member_id AS participant_id,
    pt.start_at AS event_datetime,
    (pt.duration_minutes || ' minutes')::INTERVAL AS duration_interval,
    t.first_name || ' ' || t.last_name AS trainer_name,
    'PT Area' AS location
FROM personal_training pt
LEFT JOIN trainers t ON pt.trainer_id = t.trainer_id
WHERE pt.status = 'scheduled'
  AND pt.start_at BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '7 days'

ORDER BY event_datetime;

COMMENT ON VIEW v_upcoming_events IS 
'UNION-based view: Combined schedule of group classes and PT sessions for next 7 days';


-- ============================================================
-- SECTION 7: LAYERED VIEWS (View on View)
-- ============================================================
-- Layered views build upon existing views, creating
-- additional abstraction layers.

-- ------------------------------------------------------------
-- VIEW 15: Premium Active Members
-- ------------------------------------------------------------
-- Purpose: Active members with premium membership type
-- Use Case: Premium member list, exclusive benefits management
-- Note: Built on top of v_member_membership_details view
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_premium_members AS
SELECT 
    member_id,
    first_name,
    last_name,
    email,
    phone,
    membership_type,
    start_date,
    end_date,
    price
FROM v_member_membership_details
WHERE membership_type = 'premium'
  AND is_valid = TRUE;

COMMENT ON VIEW v_premium_members IS 
'Layered view: Built on v_member_membership_details, filters for premium members only';


-- ------------------------------------------------------------
-- VIEW 16: Certified Trainer Specialists
-- ------------------------------------------------------------
-- Purpose: Active trainers with certified specializations only
-- Use Case: Trainer credentials verification, marketing materials
-- Note: Built on top of v_trainer_schedule view
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_certified_specialists AS
SELECT DISTINCT
    trainer_id,
    trainer_name,
    email,
    specialization,
    cert_date
FROM v_trainer_schedule
WHERE certified = TRUE
ORDER BY trainer_name, specialization;

COMMENT ON VIEW v_certified_specialists IS 
'Layered view: Built on v_trainer_schedule, shows only certified specializations';


-- ============================================================
-- SECTION 8: UPDATABLE VIEWS WITH CHECK OPTION
-- ============================================================
-- Updatable views with WITH CHECK OPTION ensure that
-- any INSERT or UPDATE through the view maintains
-- the view's filtering condition.

-- ------------------------------------------------------------
-- VIEW 17: Active Memberships Management
-- ------------------------------------------------------------
-- Purpose: Manage only active memberships with constraint enforcement
-- Use Case: Membership updates that should only affect active records
-- Note: WITH CHECK OPTION prevents setting is_active = FALSE through view
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_memberships_mgmt AS
SELECT 
    membership_id,
    member_id,
    membership_type,
    price,
    start_date,
    end_date,
    is_active
FROM memberships
WHERE is_active = TRUE
WITH CHECK OPTION;

COMMENT ON VIEW v_active_memberships_mgmt IS 
'Updatable view with CHECK OPTION: Ensures updates maintain is_active = TRUE';


-- ------------------------------------------------------------
-- VIEW 18: Present Attendance Records
-- ------------------------------------------------------------
-- Purpose: Manage attendance records for members who attended
-- Use Case: Attendance confirmation without allowing status changes
-- Note: WITH LOCAL CHECK OPTION validates only this view's condition
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_present_attendance AS
SELECT 
    attendance_id,
    member_id,
    class_id,
    attendance_date,
    status
FROM attendance
WHERE status = 'present'
WITH LOCAL CHECK OPTION;

COMMENT ON VIEW v_present_attendance IS 
'Updatable view with LOCAL CHECK OPTION: Prevents changing status away from "present"';


-- ============================================================
-- SECTION 9: DEMO QUERIES
-- ============================================================
-- Sample SELECT statements demonstrating each view's usage

-- --- HORIZONTAL VIEWS ---
-- Demo 01: Get all member contacts
SELECT * FROM v_member_contacts ORDER BY last_name LIMIT 5;

-- Demo 02: Get active trainer profiles for website
SELECT * FROM v_trainer_profiles ORDER BY hire_date DESC;


-- --- VERTICAL VIEWS ---
-- Demo 03: Count active members
SELECT COUNT(*) AS active_member_count FROM v_active_members;

-- Demo 04: Show available cardio equipment
SELECT * FROM v_available_equipment WHERE category = 'Cardio';


-- --- MIXED VIEWS ---
-- Demo 05: List active trainer phone numbers
SELECT trainer_id, first_name, last_name, phone 
FROM v_active_trainers_contact 
ORDER BY last_name;

-- Demo 06: This week's attendance summary
SELECT COUNT(*) AS total_checkins 
FROM v_current_week_attendance 
WHERE status = 'present';


-- --- JOIN-BASED VIEWS ---
-- Demo 07: Monday class schedule
SELECT class_name, trainer_name, start_time, end_time, room
FROM v_class_schedule
WHERE schedule_day = 'Mon'
ORDER BY start_time;

-- Demo 08: Check member access validity
SELECT member_id, first_name, last_name, membership_type, is_valid
FROM v_member_membership_details
ORDER BY end_date;

-- Demo 09: Find yoga trainers
SELECT DISTINCT trainer_name, specialization, day_of_week, available_from, available_until
FROM v_trainer_schedule
WHERE LOWER(specialization) LIKE '%yoga%'
ORDER BY day_of_week, available_from;

-- Demo 10: Today's PT sessions
SELECT member_name, trainer_name, start_at, duration_minutes, status
FROM v_pt_sessions_detail
WHERE DATE(start_at) = CURRENT_DATE
ORDER BY start_at;


-- --- SUBQUERY-BASED VIEWS ---
-- Demo 11: Members with most active goals
SELECT first_name, last_name, active_goals_count, achieved_goals_count
FROM v_members_with_goals
ORDER BY active_goals_count DESC
LIMIT 10;

-- Demo 12: Show popular classes
SELECT class_name, schedule_day, start_time, trainer_name, total_attendance
FROM v_popular_classes
ORDER BY total_attendance DESC;


-- --- UNION-BASED VIEWS ---
-- Demo 13: All staff directory
SELECT role, staff_id, first_name, last_name, email
FROM v_all_staff
WHERE is_active = TRUE;

-- Demo 14: This week's fitness calendar
SELECT event_type, event_name, event_datetime, trainer_name, location
FROM v_upcoming_events
WHERE event_datetime >= CURRENT_TIMESTAMP
ORDER BY event_datetime
LIMIT 20;


-- --- LAYERED VIEWS ---
-- Demo 15: Premium member contact list
SELECT first_name, last_name, email, phone
FROM v_premium_members
ORDER BY last_name;

-- Demo 16: Certified trainer credentials
SELECT trainer_name, specialization, cert_date
FROM v_certified_specialists
ORDER BY trainer_name, cert_date DESC;


-- --- UPDATABLE VIEWS WITH CHECK OPTION ---
-- Demo 17: Update membership price (allowed)
-- UPDATE v_active_memberships_mgmt 
-- SET price = 99.99 
-- WHERE membership_id = 1;

-- Demo 17b: Try to deactivate membership (will fail due to CHECK OPTION)
-- UPDATE v_active_memberships_mgmt 
-- SET is_active = FALSE 
-- WHERE membership_id = 1;
-- ERROR: new row violates check option for view "v_active_memberships_mgmt"

-- Demo 18: Update attendance date (allowed if status remains 'present')
-- UPDATE v_present_attendance 
-- SET attendance_date = '2026-06-10' 
-- WHERE attendance_id = 1;

-- Demo 18b: Try to change status (will fail due to CHECK OPTION)
-- UPDATE v_present_attendance 
-- SET status = 'absent' 
-- WHERE attendance_id = 1;
-- ERROR: new row violates check option for view "v_present_attendance"


-- ============================================================
-- SECTION 10: SUMMARY & VALIDATION
-- ============================================================

-- Verify all views are created successfully
SELECT 
    table_name AS view_name,
    view_definition IS NOT NULL AS is_valid
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'v_%'
ORDER BY table_name;

-- Count views by category
SELECT 
    CASE 
        WHEN table_name IN ('v_member_contacts', 'v_trainer_profiles') 
            THEN 'Horizontal'
        WHEN table_name IN ('v_active_members', 'v_available_equipment') 
            THEN 'Vertical'
        WHEN table_name IN ('v_active_trainers_contact', 'v_current_week_attendance') 
            THEN 'Mixed'
        WHEN table_name IN ('v_class_schedule', 'v_member_membership_details', 
                           'v_trainer_schedule', 'v_pt_sessions_detail') 
            THEN 'Join-based'
        WHEN table_name IN ('v_members_with_goals', 'v_popular_classes') 
            THEN 'Subquery-based'
        WHEN table_name IN ('v_all_staff', 'v_upcoming_events') 
            THEN 'UNION-based'
        WHEN table_name IN ('v_premium_members', 'v_certified_specialists') 
            THEN 'Layered'
        WHEN table_name IN ('v_active_memberships_mgmt', 'v_present_attendance') 
            THEN 'WITH CHECK OPTION'
        ELSE 'Other'
    END AS view_category,
    COUNT(*) AS view_count
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'v_%'
GROUP BY view_category
ORDER BY view_category;

-- ============================================================
-- END OF FILE
-- ============================================================
