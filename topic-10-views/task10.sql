--vertical view (for example, the sports center site
--would want to showcase the most experienced coaches)
create or replace view experiened_trainers as
select full_name, experience_years, bio
from trainers
where experience_years >=3
order by experience_years desc;


--horizontal view
create or replace view membership_view as
select name, price
--basically skipping duration_days, because it is straightforward (except for student membership)
from membership_types;


--mixed view
--the inventory showcase (some customers may want to use specific equipment
--and it is good to tell what equipment is present in the gym)
--but this one is 'with check option'
create or replace view working_equipment as
select id, name, quantity, status
from equipment
where status = 'working'
with check option;



--join (and group) view
--(yes, i took it from the previous task)
--this view is useful for running some statistics concerning the 
--class and it's attendance quality.
--for example, if attendance is poor, maybe we need
-- to change the DOTW or change the room to the smaller one.
-- as for fully attended classes, it might be profitable
--to conduct it more often.
create or replace view overall_class_attendance as
select c.title, count(*) num_members, cs.capacity
from attendance a
join class_schedule cs 
on a.schedule_id = cs.id
join classes c
on cs.class_id = c.id
group by (c.title, cs.capacity)
order by count(*);



--subquery view
--currently active members
--yes, in fact, there is a status column in memberships
--that would determine this, but 
--i've made this view in case that the status updating 
--logic might be absent
create or replace view active_members as
select m.id, m.full_name, m.email
from members m
where (
    select end_date
    from memberships ms
    where ms.member_id = m.id
    order by end_date desc
    limit 1
) >= current_date;


--union view
--all people that have been to gym as well as coaches
--may be useful for history
create or replace view all_people as
select id, full_name, 'member' as role
from members
union
select id, full_name, 'trainer' as role
from trainers;


