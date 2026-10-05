-- SCENARIO 5: ENGINEERING WORKSHOP TOOL LOANS - 202409794
DROP TABLE IF EXISTS tool_loans; DROP TABLE IF EXISTS tools;
CREATE TABLE tools (tool_id SERIAL PRIMARY KEY, tool_name VARCHAR(100), available_quantity INT);
CREATE TABLE tool_loans (loan_id SERIAL PRIMARY KEY, student_number VARCHAR(20), tool_id INT REFERENCES tools(tool_id), quantity INT, status VARCHAR(20) DEFAULT 'BORROWED');
INSERT INTO tools (tool_name, available_quantity) VALUES ('Hammer', 5), ('Drill Machine', 2), ('Soldering Iron', 0);
-- Q2
DO $$ DECLARE q INT; BEGIN SELECT available_quantity INTO q FROM tools WHERE tool_id=1; IF q=0 THEN RAISE NOTICE 'Unavailable'; ELSIF q<=2 THEN RAISE NOTICE 'Low %', q; ELSE RAISE NOTICE 'Available %', q; END IF; END $$;
-- Q3
DO $$ DECLARE i INT:=1; BEGIN WHILE i<=3 LOOP RAISE NOTICE 'Safety reminder %', i; i:=i+1; END LOOP; FOR j IN 1..3 LOOP RAISE NOTICE 'Inspection %', j; END LOOP; END $$;
-- Q4
CREATE OR REPLACE PROCEDURE issue_tool(p_student VARCHAR, p_tool_id INT, p_qty INT) LANGUAGE plpgsql AS $$ DECLARE avail INT; BEGIN IF p_qty<=0 THEN RAISE EXCEPTION 'Invalid qty %', p_qty; END IF; SELECT available_quantity INTO avail FROM tools WHERE tool_id=p_tool_id; IF avail>=p_qty THEN UPDATE tools SET available_quantity=available_quantity-p_qty WHERE tool_id=p_tool_id; INSERT INTO tool_loans(student_number, tool_id, quantity) VALUES(p_student, p_tool_id, p_qty); RAISE NOTICE 'Issued to %', p_student; ELSE RAISE NOTICE 'FAILED Avail %, Req %', avail, p_qty; END IF; END $$;
-- Q5
CALL issue_tool('2023001', 1, 2); CALL issue_tool('2023002', 2, 1); CALL issue_tool('2023003', 2, 5); SELECT * FROM tools; SELECT * FROM tool_loans;
-- Q6
CREATE OR REPLACE PROCEDURE return_tool(p_loan_id INT) LANGUAGE plpgsql AS $$ DECLARE rec RECORD; BEGIN SELECT * INTO rec FROM tool_loans WHERE loan_id=p_loan_id; IF rec.status='RETURNED' THEN RAISE NOTICE 'Already returned'; ELSE UPDATE tools SET available_quantity=available_quantity+rec.quantity WHERE tool_id=rec.tool_id; UPDATE tool_loans SET status='RETURNED' WHERE loan_id=p_loan_id; RAISE NOTICE 'Returned %', p_loan_id; END IF; END $$;
CALL return_tool(1); CALL return_tool(1);
-- Q7
DO $$ DECLARE cur CURSOR FOR SELECT * FROM tools WHERE available_quantity<=2; r RECORD; BEGIN OPEN cur; LOOP FETCH cur INTO r; EXIT WHEN NOT FOUND; RAISE NOTICE 'Low: % - %', r.tool_name, r.available_quantity; END LOOP; CLOSE cur; END $$;
-- Q8
DO $$ BEGIN CALL issue_tool('2023004', 1, 0); EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Handled: %', SQLERRM; END $$;
-- Q9
SELECT * FROM tools; SELECT * FROM tool_loans;