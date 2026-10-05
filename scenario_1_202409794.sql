-- SCENARIO 1: UNIVERSITY LIBRARY BOOK LOANS - 202409794
DROP TABLE IF EXISTS book_loans;
DROP TABLE IF EXISTS books;
CREATE TABLE books (book_id SERIAL PRIMARY KEY, title VARCHAR(100), available_copies INT);
CREATE TABLE book_loans (loan_id SERIAL PRIMARY KEY, student_number VARCHAR(20), book_id INT REFERENCES books(book_id), quantity INT, status VARCHAR(20) DEFAULT 'BORROWED');
INSERT INTO books (title, available_copies) VALUES ('Database Systems', 5), ('Networking Basics', 2), ('AI Fundamentals', 0);
-- Q2
DO $$ DECLARE q INT; BEGIN SELECT available_copies INTO q FROM books WHERE book_id=1; IF q=0 THEN RAISE NOTICE 'Unavailable'; ELSIF q<=2 THEN RAISE NOTICE 'Low: %', q; ELSE RAISE NOTICE 'Available: %', q; END IF; END $$;
-- Q3
DO $$ DECLARE i INT:=1; BEGIN WHILE i<=3 LOOP RAISE NOTICE 'Library reminder %', i; i:=i+1; END LOOP; FOR j IN 1..3 LOOP RAISE NOTICE 'Shelf check %', j; END LOOP; END $$;
-- Q4
CREATE OR REPLACE PROCEDURE issue_book(p_student VARCHAR, p_book_id INT, p_qty INT) LANGUAGE plpgsql AS $$ DECLARE avail INT; BEGIN IF p_qty<=0 THEN RAISE EXCEPTION 'Invalid qty %', p_qty; END IF; SELECT available_copies INTO avail FROM books WHERE book_id=p_book_id; IF avail>=p_qty THEN UPDATE books SET available_copies=available_copies-p_qty WHERE book_id=p_book_id; INSERT INTO book_loans(student_number, book_id, quantity) VALUES(p_student, p_book_id, p_qty); RAISE NOTICE 'Issued to %', p_student; ELSE RAISE NOTICE 'FAILED Avail %, Req %', avail, p_qty; END IF; END $$;
-- Q5
CALL issue_book('2023001', 1, 2); CALL issue_book('2023002', 2, 1); CALL issue_book('2023003', 2, 5); SELECT * FROM books; SELECT * FROM book_loans;
-- Q6
CREATE OR REPLACE PROCEDURE return_book(p_loan_id INT) LANGUAGE plpgsql AS $$ DECLARE rec RECORD; BEGIN SELECT * INTO rec FROM book_loans WHERE loan_id=p_loan_id; IF rec.status='RETURNED' THEN RAISE NOTICE 'Already returned'; ELSE UPDATE books SET available_copies=available_copies+rec.quantity WHERE book_id=rec.book_id; UPDATE book_loans SET status='RETURNED' WHERE loan_id=p_loan_id; RAISE NOTICE 'Returned %', p_loan_id; END IF; END $$;
CALL return_book(1); CALL return_book(1);
-- Q7
DO $$ DECLARE cur CURSOR FOR SELECT * FROM books WHERE available_copies<=2; r RECORD; BEGIN OPEN cur; LOOP FETCH cur INTO r; EXIT WHEN NOT FOUND; RAISE NOTICE 'Low: % - %', r.title, r.available_copies; END LOOP; CLOSE cur; END $$;
-- Q8
DO $$ BEGIN CALL issue_book('2023004', 1, 0); EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Handled: %', SQLERRM; END $$;
-- Q9
SELECT * FROM books; SELECT * FROM book_loans;