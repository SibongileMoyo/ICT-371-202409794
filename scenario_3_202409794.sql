-- SCENARIO 3: HOSTEL ROOM APPLICATION - 202409794
DROP TABLE IF EXISTS allocations; DROP TABLE IF EXISTS hostel_rooms;
CREATE TABLE hostel_rooms (room_id SERIAL PRIMARY KEY, room_name VARCHAR(100), available_spaces INT);
CREATE TABLE allocations (allocation_id SERIAL PRIMARY KEY, student_number VARCHAR(20), room_id INT REFERENCES hostel_rooms(room_id), num_spaces INT, status VARCHAR(20) DEFAULT 'ALLOCATED');
INSERT INTO hostel_rooms (room_name, available_spaces) VALUES ('Room A Block 1', 3), ('Room B Block 1', 1), ('Room C Block 2', 0);
-- Q2
DO $$ DECLARE s INT; BEGIN SELECT available_spaces INTO s FROM hostel_rooms WHERE room_id=1; IF s=0 THEN RAISE NOTICE 'Full'; ELSIF s<=1 THEN RAISE NOTICE 'Nearly full %', s; ELSE RAISE NOTICE 'Available %', s; END IF; END $$;
-- Q3
DO $$ DECLARE i INT:=1; BEGIN WHILE i<=3 LOOP RAISE NOTICE 'Reminder %', i; i:=i+1; END LOOP; FOR j IN 1..3 LOOP RAISE NOTICE 'Inspection %', j; END LOOP; END $$;
-- Q4
CREATE OR REPLACE PROCEDURE allocate_room(p_student VARCHAR, p_room_id INT, p_spaces INT) LANGUAGE plpgsql AS $$ DECLARE avail INT; BEGIN IF p_spaces<=0 THEN RAISE EXCEPTION 'Invalid spaces %', p_spaces; END IF; SELECT available_spaces INTO avail FROM hostel_rooms WHERE room_id=p_room_id; IF avail>=p_spaces THEN UPDATE hostel_rooms SET available_spaces=available_spaces-p_spaces WHERE room_id=p_room_id; INSERT INTO allocations(student_number, room_id, num_spaces) VALUES(p_student, p_room_id, p_spaces); RAISE NOTICE 'Allocated to %', p_student; ELSE RAISE NOTICE 'FAILED Avail %, Req %', avail, p_spaces; END IF; END $$;
-- Q5
CALL allocate_room('2023001', 1, 1); CALL allocate_room('2023002', 1, 1); CALL allocate_room('2023003', 3, 1); SELECT * FROM hostel_rooms; SELECT * FROM allocations;
-- Q6
CREATE OR REPLACE PROCEDURE checkout_room(p_alloc_id INT) LANGUAGE plpgsql AS $$ DECLARE rec RECORD; BEGIN SELECT * INTO rec FROM allocations WHERE allocation_id=p_alloc_id; IF rec.status='COMPLETE' THEN RAISE NOTICE 'Already checked out'; ELSE UPDATE hostel_rooms SET available_spaces=available_spaces+rec.num_spaces WHERE room_id=rec.room_id; UPDATE allocations SET status='COMPLETE' WHERE allocation_id=p_alloc_id; RAISE NOTICE 'Checkout %', p_alloc_id; END IF; END $$;
CALL checkout_room(1); CALL checkout_room(1);
-- Q7
DO $$ DECLARE cur CURSOR FOR SELECT * FROM hostel_rooms WHERE available_spaces<=1; r RECORD; BEGIN OPEN cur; LOOP FETCH cur INTO r; EXIT WHEN NOT FOUND; RAISE NOTICE 'Full/Nearly Full: % - %', r.room_name, r.available_spaces; END LOOP; CLOSE cur; END $$;
-- Q8
DO $$ BEGIN CALL allocate_room('2023004', 1, 0); EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Handled: %', SQLERRM; END $$;
-- Q9
SELECT * FROM hostel_rooms; SELECT * FROM allocations;