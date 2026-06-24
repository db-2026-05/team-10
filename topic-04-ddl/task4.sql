--as we've decided to take Maksym Romanenko's variant of task 3 as the primary,
--the following sql code is for his dbml,
--yet i've made some changes given the feedback for task 3 and specifically -- enums and created_at/updated_at where relevant

--i dont know whether this piece of code is well commented,
--but i tried to explain my logic as well as unsureness in some places 


DROP TABLE IF EXISTS membership_types CASCADE;
DROP TABLE IF EXISTS members CASCADE;
DROP TABLE IF EXISTS memberships CASCADE;
DROP TABLE IF EXISTS trainers CASCADE;
DROP TABLE IF EXISTS specializations CASCADE;
DROP TABLE IF EXISTS trainer_specializations CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS fitness_goals CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS personal_training CASCADE;
DROP TABLE IF EXISTS personal_training_status CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS equipment_status CASCADE;
DROP TABLE IF EXISTS progress CASCADE;
DROP TABLE IF EXISTS equipment_specialization CASCADE;
DROP TYPE IF EXISTS membership_status CASCADE;
DROP TYPE IF EXISTS personal_training_status CASCADE;
DROP TYPE IF EXISTS equipment_status CASCADE;
DROP TYPE IF EXISTS membership_type CASCADE;


CREATE TYPE membership_type AS ENUM ('single_day','weekly','monthly','annualy','student');
CREATE TABLE membership_types (
	id SERIAL PRIMARY KEY,
	name membership_type NOT NULL DEFAULT 'single_day',
	price DECIMAL(10,2) NOT NULL, --now i've took notice about decimal(10,2) for price
	duration_days INT NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT positive_price CHECK (price>0),
	CONSTRAINT positive_duration CHECK (duration_days>0)
);


CREATE TABLE members (
	id SERIAL PRIMARY KEY,
	full_name VARCHAR(50) NOT NULL,
	email VARCHAR(254) UNIQUE NOT NULL,  --254 is maximum possible email length, but it might be overkill
	join_date DATE NOT NULL DEFAULT CAST(NOW() AS DATE),
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

--there are only 3 types of membership_status, so varchar for them is inconsitent and memory inefficient
CREATE TYPE membership_status AS ENUM ('active', 'expired', 'cancelled');
CREATE TABLE memberships (
	id SERIAL PRIMARY KEY,
	member_id INT REFERENCES members(id) NOT NULL,
	membership_type_id INT REFERENCES membership_types(id) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	status membership_status NOT NULL DEFAULT 'active',
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT end_after_start CHECK (end_date > start_date)
);



CREATE TABLE trainers (
  	id SERIAL PRIMARY KEY,
  	full_name VARCHAR(50) NOT NULL,
  	experience_years INT NOT NULL DEFAULT 0,
  	bio TEXT NULL,
  	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT non_neg_exp CHECK (experience_years>=0)
);



CREATE TABLE specializations (
	id SERIAL PRIMARY KEY,
	name VARCHAR(25) NOT NULL,
  	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);



CREATE TABLE trainer_specializations (
	trainer_id INT REFERENCES trainers(id) NOT NULL,
	spec_id INT REFERENCES specializations(id) NOT NULL,
	PRIMARY KEY (trainer_id, spec_id) -- composite key
);
-- this is a mediator table, thus it is not necessary to include created_at/updated_at



CREATE TABLE classes (
	id SERIAL PRIMARY KEY,
	title VARCHAR(25) NOT NULL,
	description TEXT NULL,
  	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);




CREATE TABLE class_schedule (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES classes(id) NOT NULL,
	trainer_id INT REFERENCES trainers(id) NOT NULL,
	start_time TIMESTAMP NOT NULL,
	room_number INT NULL, -- not sure if i need to put a constraint here (perhaps some people would want to name rooms
						  -- depending on the floor of the building (very unlikely, but i decided to leave it as is))
	capacity INT NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT positive_capacity CHECK (capacity>0)
);



CREATE TABLE attendance (
	id SERIAL PRIMARY KEY,
	member_id INT REFERENCES members(id) NOT NULL,
	schedule_id INT REFERENCES class_schedule(id) NOT NULL,
	check_in_time TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE TYPE personal_training_status AS ENUM ('booked', 'completed', 'cancelled');
CREATE TABLE personal_training (
	id SERIAL PRIMARY KEY,
	member_id INT REFERENCES members(id) NOT NULL,
	trainer_id INT REFERENCES trainers(id) NOT NULL,
	session_date TIMESTAMPTZ NOT NULL,
	duration_minutes INT DEFAULT 60,
	status personal_training_status DEFAULT 'booked' NOT NULL,
	notes TEXT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT valid_duration CHECK(duration_minutes>=15) --i've decided that keeping just positive duration
														 -- wouldn't be enough and session must last $GE 15 minutes 
);

CREATE TYPE equipment_status AS ENUM ('working', 'in_repair', 'decommissioned');
CREATE TABLE equipment (
	id SERIAL PRIMARY KEY,
	name VARCHAR(25) NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	status equipment_status DEFAULT 'working' NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT non_neg_quantity CHECK(quantity>=0)
);

CREATE TABLE progress (
	id SERIAL PRIMARY KEY,
	member_id INT REFERENCES members(id) NOT NULL,
	recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	weight_kg DECIMAL NULL,
	body_fat_pct DECIMAL,
	metric_name VARCHAR(25),
	metric_value DECIMAL,

	CONSTRAINT positive_weight CHECK(weight_kg>0), -- the weight differs with age and btwn genders, thus
												   -- i am not sure abaout baseline, so just $GT 0 will suffice (maybe)
	CONSTRAINT valid_bfp CHECK (body_fat_pct>2) -- 2% for men and 10% for women are survivable baselines
);
-- i did not include created_at/updated_at, because the record is like a stamp in history - it cannot be changed,
-- and the table already contains recorded_at.



CREATE TABLE fitness_goals (
	id SERIAL PRIMARY KEY,
	member_id INT REFERENCES members(id),
	goal_type VARCHAR(25) NOT NULL,
	target_value DECIMAL NULL,
	target_date DATE NULL,
	achieved_at DATE NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	CONSTRAINT target_after_today CHECK (target_date> CAST(NOW() AS DATE))
	  -- im not sure if there exists a case where a person decided to achieve some fitness goal 
	  -- that exact day
);


--the mediator table btwn equipment and specialization
CREATE TABLE equipment_specialization (
	equipment_id INT REFERENCES equipment(id),
	spec_id INT REFERENCES specializations(id),
	PRIMARY KEY (equipment_id, spec_id),
	
	CONSTRAINT unique_equipment_spec UNIQUE (equipment_id, spec_id)
);



