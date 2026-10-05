-- SCENARIO 6: UNIVERSITY EVENT SEAT BOOKING - 202409794
DROP TABLE IF EXISTS bookings; DROP TABLE IF EXISTS events;
CREATE TABLE events (event_id SERIAL PRIMARY KEY, event_name VARCHAR(100), available_seats INT);
CREATE TABLE bookings (booking_id SERIAL PRIMARY KEY, student_number VARCHAR(20), event_id INT REFERENCES events(event_id), num_seats INT, status VARCHAR(20) DEFAULT 'BOOKED');
INSERT INTO events (event_name, available_seats) VALUES ('Tech Talk', 10), ('Graduation Ceremony', 2), ('Music Night', 0);
-- Q2
DO $$ DECLARE s INT; BEGIN SELECT available_seats INTO s FROM events WHERE event_id=1; IF s=0 THEN RAISE NOTICE 'Full'; ELSIF s<=2 THEN RAISE NOTICE 'Nearly full %', s; ELSE RAISE NOTICE 'Plenty %', s; END IF; END $$;
-- Q3
DO $$ DECLARE i INT:=1; BEGIN WHILE i<=3 LOOP RAISE NOTICE 'Reminder %', i; i:=i+1; END LOOP; FOR j IN 1..3 LOOP RAISE NOTICE 'Entrance check %', j; END LOOP; END $$;
-- Q4
CREATE OR REPLACE PROCEDURE book_seats(p_student VARCHAR, p_event_id INT, p_seats INT) LANGUAGE plpgsql AS $$ DECLARE avail INT; BEGIN IF p_seats<=0 THEN RAISE EXCEPTION 'Invalid seats %', p_seats; END IF; SELECT available_seats INTO avail FROM events WHERE event_id=p_event_id; IF avail>=p_seats THEN UPDATE events SET available_seats=available_seats-p_seats WHERE event_id=p_event_id; INSERT INTO bookings(student_number, event_id, num_seats) VALUES(p_student, p_event_id, p_seats); RAISE NOTICE 'Booking OK %', p_student; ELSE RAISE NOTICE 'FAILED Avail %, Req %', avail, p_seats; END IF; END $$;
-- Q5
CALL book_seats('2023001', 1, 3); CALL book_seats('2023002', 2, 1); CALL book_seats('2023003', 2, 5); SELECT * FROM events; SELECT * FROM bookings;
-- Q6
CREATE OR REPLACE PROCEDURE cancel_booking(p_booking_id INT) LANGUAGE plpgsql AS $$ DECLARE rec RECORD; BEGIN SELECT * INTO rec FROM bookings WHERE booking_id=p_booking_id; IF rec.status='CANCELLED' THEN RAISE NOTICE 'Already cancelled'; ELSE UPDATE events SET available_seats=available_seats+rec.num_seats WHERE event_id=rec.event_id; UPDATE bookings SET status='CANCELLED' WHERE booking_id=p_booking_id; RAISE NOTICE 'Cancelled %', p_booking_id; END IF; END $$;
CALL cancel_booking(1); CALL cancel_booking(1);
-- Q7
DO $$ DECLARE cur CURSOR FOR SELECT * FROM events WHERE available_seats<=2; r RECORD; BEGIN OPEN cur; LOOP FETCH cur INTO r; EXIT WHEN NOT FOUND; RAISE NOTICE 'Full/Nearly Full: % - %', r.event_name, r.available_seats; END LOOP; CLOSE cur; END $$;
-- Q8
DO $$ BEGIN CALL book_seats('2023004', 1, 0); EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Handled: %', SQLERRM; END $$;
-- Q9
SELECT * FROM events; SELECT * FROM bookings;