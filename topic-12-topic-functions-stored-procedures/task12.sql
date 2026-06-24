

--function to calculate the absolute profit from memberships in given month of the given year
create or replace function profit_in_month_of_year(month_ INTEGER, year_ INTEGER)
returns decimal(10,2) as $$
declare 
total_profit decimal(10,2);
begin
select sum(price)
into total_profit
from memberships ms
join membership_types mst
on ms.membership_type_id = mst.id
	where status = 'expired' and --basically, we dont know our cancellation system (what percentage of money is returned after the cancellation)
								 -- and any active membership has a chance to be cancelled, so they arent included as well
	extract (year from end_date) = year_ and 
	extract (month from end_date) = month_;
return total_profit;
end;
$$
language plpgsql;


select profit_in_month_of_year(3,2026);



--this one could be useful for receptionist so that person knows how much 
--trainers will conduct classes as well as when and where
create or replace function classes_held_today()
returns table(
	id INTEGER,
	start_time TIMESTAMP,
	room_number INTEGER,
	title VARCHAR(25),
	coach_name VARCHAR(50)
)
as $$
begin
	return query
	select cs.id, cs.start_time, cs.room_number, c.title, t.full_name
	from class_schedule cs
	join classes c
	on c.id = cs.class_id
	join trainers t
	on t.id = cs.trainer_id
	where cast(now() as date) = cast(cs.start_time as date)
	order by start_time;
end;
$$
language plpgsql;
--drop function classes_held_today();
INSERT INTO class_schedule
(class_id,trainer_id,start_time,room_number,capacity)
VALUES
(1,1,'2026-06-24 15:00:00+00',42,5); --happening today, yay!
select * from classes_held_today();


--this procedure could be used with some cron job to update current active 
--memberships' statuses to 'expired' if current date $GE end date
create or replace procedure update_membership_statuses()
language plpgsql
as $$
begin
    update memberships
    set status = 'expired', updated_at = NOW()
    where status = 'active' and current_date >= end_date;
end;
$$;

select * from memberships
where status = 'active';
call update_membership_statuses();




--the amount of times the member has been present to a class.
--active members could receive discounts for memberships/personal_trainings
create or replace function member_attendance_count(member_id_ integer)
returns integer as $$
declare
    total integer;
begin
    select count(*)
    into total
    from attendance
    where member_id = member_id_;
    return total;
end;
$$ 
language plpgsql;



--this one is also used at the reception to register an attendance for a member
create or replace procedure register_attendance(member_id_ integer, schedule_id_ integer)
language plpgsql
as $$
declare
	current_count integer; 
	max_capacity integer;
begin
select count(*)
into current_count
from attendance
where schedule_id = schedule_id_;

select capacity
into max_capacity
from class_schedule
where id = schedule_id_;

if current_count>=max_capacity then
raise exception 'class % is full (% people)', schedule_id_, max_capacity;
end if;

insert into attendance 
(member_id, schedule_id)
values 
(member_id_, schedule_id_);
end;
$$;

call register_attendance(1,13);
select * from attendance
where cast(check_in_time as date) = cast(now() as date);
