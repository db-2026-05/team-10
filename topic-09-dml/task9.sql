-- NOTE: i've used AI because populating data
-- by oneself is tiresome (basically, we've failed the team part and went separate paths).
-- the parts that are AI-assisted are generally those that are large or do not have any constraints
-- one way or the other i need to have database populated at least 
-- to some extent so that other tasks would make sense.

INSERT INTO membership_types
(name,price,duration_days)
VALUES
('single_day',5,1),
('weekly',20,7),
('monthly',50,31),
('annualy',400,365),
('student',25,31); -- just like fee in public transport (divided by 2)


--checking constraints
INSERT INTO membership_types
(name,price,duration_days)
VALUES
('oops, negative price',-5,1),
('oops, negative duration',10,-2);


-- AI assisted piece {
INSERT INTO members (full_name, email, join_date) VALUES
    ('Alice Johnson',   'alice.johnson@gmail.com',   '2024-01-10'),
    ('Bob Martinez',    'bob.martinez@gmail.com',    '2024-02-14'),
    ('Carol White',     'carol.white@gmail.com',     '2024-03-05'),
    ('David Brown',     'david.brown@gmail.com',     '2024-04-20'),
    ('Eva Green',       'eva.green@gmail.com',       '2024-05-01'),
    ('Frank Lee',       'frank.lee@gmail.com',       '2024-06-15'),
    ('Grace Kim',       'grace.kim@gmail.com',       '2024-07-22'),
    ('Henry Wilson',    'henry.wilson@gmail.com',    '2024-08-09'),
    ('Iris Zhang',      'iris.zhang@gmail.com',      '2024-09-30'),
    ('Jack O''Brien',   'jack.obrien@gmail.com',     '2024-10-11');


INSERT INTO memberships (member_id, membership_type_id, start_date, end_date, status) VALUES
    -- Alice: renewed monthly twice, currently active
    (1,  3, '2026-01-01', '2026-02-01', 'expired'),
    (1,  3, '2026-02-01', '2026-03-04', 'expired'),
    (1,  3, '2026-03-04', '2026-04-04', 'active'),
 
    -- Bob: annual plan, still running
    (2,  4, '2026-01-01', '2027-01-01', 'active'),
 
    -- Carol: student plan, renewed once
    (3,  5, '2026-01-15', '2026-02-15', 'expired'),
    (3,  5, '2026-02-15', '2026-03-18', 'active'),
 
    -- David: tried a weekly, didn't renew
    (4,  2, '2026-03-10', '2026-03-17', 'expired'),
 
    -- Eva: student plan, cancelled mid-way
    (5,  5, '2026-03-01', '2026-04-01', 'cancelled'),
 
    -- Frank: monthly, active
    (6,  3, '2026-03-01', '2026-04-01', 'active'),
 
    -- Grace: annual, long-term member
    (7,  4, '2025-06-01', '2026-06-01', 'active'),
 
    -- Henry: just came in for a single day
    (8,  1, '2026-03-20', '2026-03-21', 'expired'),
 
    -- Iris: monthly, active
    (9,  3, '2026-03-01', '2026-04-01', 'active'),
 
    -- Jack: student plan, active
    (10, 5, '2026-02-01', '2026-03-04', 'expired'),
    (10, 5, '2026-03-04', '2026-04-04', 'active');
-- }

select distinct m.full_name
from members m 
join memberships ms
on m.id = ms.member_id
where extract (month from ms.start_date) = 3;

-- checking constraint 
INSERT INTO memberships
(member_id,membership_type_id,start_date,end_date,status)
VALUES
(2,2,'2025-09-09','2024-09-09','active');


INSERT INTO trainers
(full_name, experience_years,bio)
VALUES 
('Bob Fisher',5,'Experienced lower-body strength coach'),
('Sofiia Martinez',3,'Pilates and yoga practicioner'),
('Jason Walker',1,'Upper-body and core specialist'),
('Jack Benton',0,'Certified newbie coach in general workout'),
('Katie Jackson',3,'Overall endurance coach. HIIT is her middle name');

--checking constraints
INSERT INTO trainers
(full_name, experience_years,bio)
VALUES
('oops, negative experience',-42,NULL);


-- AI assisted {
INSERT INTO specializations (name) VALUES
    ('Powerlifting'),
    ('Yoga'),
    ('HIIT'),
    ('Pilates'),
    ('Boxing'),
    ('Body Recomposition'),
    ('Functional Fitness'),
    ('Stretching & Mobility'),
    ('Cardio'),
    ('Calisthenics');

INSERT INTO trainer_specializations (trainer_id, spec_id) VALUES
    (1, 1),   -- Bob:    Powerlifting
    (1, 7),   -- Bob:    Functional Fitness

    (2, 2),   -- Sofiia: Yoga
    (2, 4),   -- Sofiia: Pilates
    (2, 8),   -- Sofiia: Stretching & Mobility

    (3, 10),  -- Jason:  Calisthenics
    (3, 7),   -- Jason:  Functional Fitness

    (4, 7),   -- Jack:   Functional Fitness
    (4, 6),   -- Jack:   Body Recomposition

    (5, 3),   -- Katie:  HIIT
    (5, 9);   -- Katie:  Cardio

INSERT INTO classes (title, description) VALUES
    -- Bob Fisher (Powerlifting, Functional Fitness)
    ('Leg Day Fundamentals',  'Squat, deadlift and lunge progressions for lower-body strength.'),
    ('Functional Strength',   'Compound movements focused on real-world mobility and power.'),

    -- Sofiia Martinez (Yoga, Pilates, Stretching & Mobility)
    ('Morning Yoga Flow',     'Gentle vinyasa sequence to energize the body for the day.'),
    ('Pilates Core',          'Mat pilates targeting deep core stabilizers and posture.'),
    ('Mobility & Stretch',    'Full-body flexibility work and joint mobility drills.'),

    -- Jason Walker (Calisthenics, Functional Fitness)
    ('Bodyweight Basics',     'Push, pull and hinge patterns using bodyweight only.'),
    ('Upper Body Burn',       'Core and upper-body calisthenics circuit for all levels.'),

    -- Jack Benton (Functional Fitness, Body Recomposition)
    ('General Workout',       'Beginner-friendly full-body session covering all movement patterns.'),
    ('Recomp Circuit',        'Combined resistance and cardio circuit aimed at fat loss and muscle gain.'),

    -- Katie Jackson (HIIT, Cardio)
    ('HIIT Blast',            'High-intensity intervals alternating work and rest for maximum burn.'),
    ('Endurance Run',         'Structured cardio session building aerobic base and stamina.');

--select * from classes;
--}

INSERT INTO class_schedule
(class_id,trainer_id,start_time,room_number,capacity)
VALUES
(1,1,'2026-06-10 9:00:00+00',42,5), --this one happened in the past
(2,1,'2026-09-10 17:45:00+00',24,10),
(3,2,'2026-06-12 8:30:00+00',10,20),  --this one also
(4,2,'2026-09-09 15:15:00+00',10,20),
(5,2,'2026-09-09 18:30:00+00',10,20),
(6,3,'2026-09-09 12:00:00+00',15,8),
(7,3,'2026-09-09 18:00:00+00',15,8),
(8,4,'2026-09-09 10:00:00+00',5,10),
(9,4,'2026-09-09 19:00:00+00',5,10),
(10,5,'2026-06-15 10:00:00+00',10,20), --this as well
(11,5,'2026-09-09 11:15:00+00',6,10);

--select * from class_schedule;
--delete from class_schedule where 1=1;
--checking constraint 
INSERT INTO class_schedule
(class_id,trainer_id,start_time,room_number,capacity)
VALUES
(1,1,'2026-09-09 9:00:00+00',3,-5);


-- AI assisted {
INSERT INTO attendance (member_id, schedule_id, check_in_time) VALUES
(1,  1, '2026-06-10 08:55:00+00'),
(2,  1, '2026-06-10 08:58:00+00'),
(4,  1, '2026-06-10 09:01:00+00'),
(7,  1, '2026-06-10 09:03:00+00'),
(10, 1, '2026-06-10 08:50:00+00');
INSERT INTO attendance (member_id, schedule_id, check_in_time) VALUES
(1,  3, '2026-06-12 08:25:00+00'),
(3,  3, '2026-06-12 08:28:00+00'),
(5,  3, '2026-06-12 08:30:00+00'),
(6,  3, '2026-06-12 08:32:00+00'),
(8,  3, '2026-06-12 08:29:00+00'),
(9,  3, '2026-06-12 08:27:00+00');
INSERT INTO attendance (member_id, schedule_id, check_in_time) VALUES
(2,  10, '2026-06-15 09:55:00+00'),
(3,  10, '2026-06-15 09:58:00+00'),
(4,  10, '2026-06-15 10:00:00+00'),
(5,  10, '2026-06-15 10:02:00+00'),
(7,  10, '2026-06-15 09:57:00+00'),
(8,  10, '2026-06-15 09:53:00+00'),
(9,  10, '2026-06-15 09:59:00+00'),
(10, 10, '2026-06-15 10:01:00+00');


select c.title, count(*) num_members, cs.capacity
from attendance a
join class_schedule cs 
on a.schedule_id = cs.id
join classes c
on cs.class_id = c.id
group by (c.title, cs.capacity)
order by count(*);



INSERT INTO personal_training
(member_id, trainer_id, session_date, duration_minutes, status, notes)
VALUES
    -- completed sessions (past)
    (1,  1, '2026-06-01 10:00:00+03', 60, 'completed', 'Introduced Romanian deadlift. Good form from first attempt.'),
    (2,  1, '2026-06-03 11:00:00+03', 60, 'completed', 'Increased squat load by 10kg. Depth still needs work.'),
    (3,  2, '2026-06-05 09:00:00+03', 60, 'completed', 'Hip flexor mobility improved since last session.'),
    (6,  2, '2026-06-08 10:30:00+03', 45, 'completed', 'First pilates session. Core engagement was the main focus.'),
    (7,  3, '2026-06-10 08:00:00+03', 60, 'completed', 'Muscle-up progression: still working on false grip.'),
    (9,  5, '2026-06-12 07:30:00+03', 30, 'completed', 'Lactate threshold test completed. Baseline established.'),
    (10, 4, '2026-06-15 11:00:00+03', 60, 'completed', 'Reviewed basic movement patterns. Good starting point.'),
    (4,  1, '2026-06-18 10:00:00+03', 60, 'cancelled', NULL),  -- cancelled by David
 
    -- upcoming (booked)
    (1,  1, '2026-09-08 10:00:00+03', 60, 'booked', NULL),
    (3,  2, '2026-09-09 09:00:00+03', 60, 'booked', NULL),
    (5,  5, '2026-09-10 08:00:00+03', 45, 'booked', NULL),
    (7,  3, '2026-09-11 08:00:00+03', 60, 'booked', NULL),
    (9,  5, '2026-09-09 07:30:00+03', 30, 'booked', NULL),
    (10, 4, '2026-09-12 11:00:00+03', 60, 'booked', NULL);


INSERT INTO equipment (name, quantity, status) VALUES
    ('Barbell',           10, 'working'),
    ('Dumbbell Set',       8, 'working'),
    ('Yoga Mat',          20, 'working'),
    ('Resistance Band',   30, 'working'),
    ('Pull-up Bar',        4, 'working'),
    ('Boxing Bag',         6, 'working'),
    ('Rowing Machine',     3, 'working'),
    ('Treadmill',          8, 'working'),
    ('Kettlebell Set',     5, 'in_repair'),
    ('Cable Machine',      2, 'working'),
    ('Foam Roller',       15, 'working'),
    ('Spin Bike',          6, 'decommissioned');


INSERT INTO progress
(member_id, recorded_at, weight_kg, body_fat_pct, metric_name, metric_value)
VALUES
    -- Alice: losing weight gradually
    (1, '2026-01-01 09:00:00+03', 74.0, 28.0, NULL,                  NULL),
    (1, '2026-03-01 09:00:00+03', 72.5, 26.5, NULL,                  NULL),
    (1, '2026-06-01 09:00:00+03', 70.2, 24.8, NULL,                  NULL),
 
    -- Bob: powerlifter, tracking 1RM
    (2, '2026-01-15 08:00:00+03', 92.0, 17.5, 'Squat 1RM (kg)',      150.0),
    (2, '2026-03-15 08:00:00+03', 93.0, 17.0, 'Squat 1RM (kg)',      162.5),
    (2, '2026-06-10 08:00:00+03', 93.5, 16.8, 'Squat 1RM (kg)',      175.0),
 
    -- Carol: yoga/pilates, tracking flexibility proxy
    (3, '2026-02-01 10:00:00+03', 61.0, 29.0, 'Sit & Reach (cm)',    12.0),
    (3, '2026-05-01 10:00:00+03', 60.0, 27.5, 'Sit & Reach (cm)',    18.0),
 
    -- Grace: overall fitness
    (7, '2026-01-01 08:00:00+03', 80.0, 20.0, 'Pull-ups (reps)',      6.0),
    (7, '2026-03-01 08:00:00+03', 79.0, 19.0, 'Pull-ups (reps)',      9.0),
    (7, '2026-06-01 08:00:00+03', 78.0, 18.5, 'Pull-ups (reps)',     12.0),
 
    -- Iris: cardio-focused
    (9, '2026-03-01 11:00:00+03', 67.0, 31.0, '5km Time (min)',       34.0),
    (9, '2026-06-01 11:00:00+03', 65.5, 29.5, '5km Time (min)',       30.0),
 
    -- Jack: beginner, general tracking
    (10, '2026-03-04 12:00:00+03', 85.0, 24.0, NULL,                 NULL),
    (10, '2026-06-05 12:00:00+03', 83.5, 22.5, NULL,                 NULL);


INSERT INTO fitness_goals
(member_id, goal_type, target_value, target_date, achieved_at)
VALUES
    (1,  'Weight Loss (kg)',       65.0, '2026-12-01', NULL),
    (1,  'Body Fat (%)',           22.0, '2026-09-01', NULL),
    (2,  'Squat 1RM (kg)',        200.0, '2026-12-31', NULL),
    (3,  'Sit & Reach (cm)',       25.0, '2026-10-01', NULL),
    (3,  'Attend 30 Classes',      30.0, '2026-12-01', NULL),
    (5,  'Run Without Stopping',   NULL, '2026-07-31', NULL),
    (6,  'Lose 5kg',               NULL, '2026-11-01', NULL),
    (7,  'Pull-ups (reps)',        15.0, '2026-09-15', NULL),
    (9,  '5km under 27 min',       27.0, '2026-09-01', NULL),
    (10, 'Body Fat (%)',           18.0, '2026-12-01', NULL);




INSERT INTO equipment_specialization (equipment_id, spec_id) VALUES
    (1,  1),   -- Barbell          → Powerlifting
    (1,  7),   -- Barbell          → Functional Fitness
    (2,  1),   -- Dumbbell Set     → Powerlifting
    (2,  6),   -- Dumbbell Set     → Body Recomposition
    (3,  2),   -- Yoga Mat         → Yoga
    (3,  4),   -- Yoga Mat         → Pilates
    (3,  8),   -- Yoga Mat         → Stretching & Mobility
    (4,  2),   -- Resistance Band  → Yoga
    (4,  8),   -- Resistance Band  → Stretching & Mobility
    (5,  10),  -- Pull-up Bar      → Calisthenics
    (5,  7),   -- Pull-up Bar      → Functional Fitness
    (6,  5),   -- Boxing Bag       → Boxing
    (7,  9),   -- Rowing Machine   → Cardio
    (8,  9),   -- Treadmill        → Cardio
    (9,  3),   -- Kettlebell Set   → HIIT
    (9,  7),   -- Kettlebell Set   → Functional Fitness
    (10, 1),   -- Cable Machine    → Powerlifting
    (10, 6),   -- Cable Machine    → Body Recomposition
    (11, 8),   -- Foam Roller      → Stretching & Mobility
--}
--select * from attendance;
--delete from attendance where 1=1;

--yoga needs no equipment, thus is absent in this table


--checking constraints
INSERT INTO personal_training
(member_id, trainer_id, session_date, duration_minutes, status)
VALUES
(1,1,'2026-09-09',14,'booked');
insert into equipment
(name,quantity,status)
values
('oops,negative quantity',-3,'working');
--checking type
insert into equipment
(name,quantity,status)
values
('oops, wrong enum',2,'what?');
INSERT INTO progress
(member_id, recorded_at, weight_kg, body_fat_pct)
VALUES
(1,'2026-09-09',-2,42); --negative mass
INSERT INTO progress
(member_id, recorded_at, weight_kg, body_fat_pct)
VALUES
(1,'2026-09-09',1,1); --too low bfp


