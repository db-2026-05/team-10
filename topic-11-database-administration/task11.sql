create role receptionist;
--drop role receptionist;

create user reception_bob;
--drop user reception_bob;

grant receptionist to reception_bob;


--the receptionist should be able to register the member
--and help with the data concerning the membership
grant select, insert, update on members, memberships to receptionist;
--the receptionist should be able to inform the member
--about the class if asked, but he must not control 
-- the classes themselves and their schedule
grant select on classes, class_schedule, trainers to receptionist;
--(in my interpretation) the class attendance is recorded by receptionist
grant select, insert, update, delete on attendance to receptionist;
-- ai assisted {
grant usage, select on sequence members_id_seq, memberships_id_seq, attendance_id_seq to receptionist;
--}  i did not know that if ID is serial then i have to explicitly grant one more privilege


--the equipment manager is responsible for the 
--physical asset of the sports center.
--it should be able to see what is present in what state,
--add some equipment (note, that we're only adding working equipment
--(it would not make much sense if we bought some broken assets))
create role equipment_manager;
--drop role equipment_manager;

create user eq_manager_steve;
--drop user eq_manager_steve;

grant equipment_manager to eq_manager_steve;
--the eq_manager can only insert working equipment (view from previous task)
grant select, insert, update on working_equipment to equipment_manager;
grant select on equipment to equipment_manager;
--and eq_manager can obviously change the eq status and quantity
grant update (quantity, status) on equipment to equipment_manager;
--the same SERIAL problem that was before
grant usage, select on sequence equipment_id_seq to equipment_manager;