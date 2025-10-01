CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    grade VARCHAR(100)
);
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);

CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCE students(student_id),
    course_id INT REFERENCE courses(course_id),
    semester varchar(100)
);

--Sub Queries
--A subquery is a query inside another query.
--It is usually enclosed in parentheses ( ) and can be used in SELECT, FROM, or WHERE clauses.

--TYPES OF SUBQUERIES
-- 1 Scalar Subquery: Returns a single value.
-- Find students older than the average age.
	SELECT name, age
	FROM students 
	WHERE age > (SELECT ROUND(AVG(age),2) FROM students);

-- 2 Column Subquery: Returns a single column of values
-- Get students enrolled in courses with more than 3 credits.
    SELECT name
	FROM students
	WHERE student_id IN (
	    SELECT student_id
	    FROM enrollment e
	    JOIN courses c ON e.course_id = c.course_id
	    WHERE c.credits > 3
	);

-- 3 Multiple column subqueries : Returns one or more columns.
-- Find students who are enrolled in the same course as a particular student
	SELECT s.name, e.course_id
	FROM students s
	JOIN enrollment e ON s.student_id = e.student_id
	WHERE (e.course_id, e.semester) IN (
	SELECT e2.course_id, e2.semester
	FROM enrollment e2
	WHERE e2.student_id = 5
	);

-- 4 Single row subquery : Returns a single row of values.
-- Get the student with the highest age.
	SELECT name, age
	FROM students
	WHERE age = (SELECT MAX(age) FROM students);
	
-- 5 Multiple row subquery : Returns one or more rows.
-- Find students enrolled in courses with more than 3 credits:
	SELECT name
	FROM students
	WHERE student_id IN (
	    SELECT e.student_id
	    FROM enrollment e
	    JOIN courses c ON e.course_id = c.course_id
	    WHERE c.credits > 3
	);

	

-- 6 Table Subquery: Returns a result set that can be treated as a table
-- Show average age per course, then filter it.
	SELECT course_name, credits
	FROM (
	 SELECT c.course_name, c.credits
	 FROM courses c
	 JOIN enrollment e ON c.course_id = e.course_id 
	 WHERE c.credits > 3
	) AS credits_table
	WHERE credits > 4;

-- 7 Correlated subqueries : Reference one or more columns in the outer SQL statement. The subquery is known as a correlated subquery because the subquery is related to the outer SQL statement.
-- Find students who are older than the average age of students in the same course.
	SELECT s.name, s.age, c.course_name
	FROM students s
	JOIN enrollment e ON s.student_id = e.student_id
	JOIN courses c ON e.course_id = c.course_id
	WHERE s.age > (
	SELECT AVG(s2.age)
	FROM students s2
	JOIN enrollment e2 ON s2.student_id = e2.student_id
	WHERE e2.course_id = e.course_id
	);
	
-- 8 Nested subqueries : Subqueries are placed within another subquery.
--Find students older than the youngest student in "Mathematics"
	SELECT name, age
	FROM students
	WHERE age > (
	SELECT MIN(age)
	FROM students
	WHERE student_id IN (
		SELECT e.student_id
		FROM enrollment e
		JOIN courses c ON e.course_id = c.course_id
		WHERE c.course_name = 'Math'
	)
	);

