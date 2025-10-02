-- Sub queries
--Finding average student age and least student student older than that
SELECT name, age
FROM students
WHERE age > (SELECT AVG(age) FROM students);

--Number of enrollment per student
SELECT s.name, (SELECT COUNT(*) FROM enrollment e WHERE e.student_id = s.student_id)
AS total
FROM students s;

--List courses and the total students enrolled.
SELECT c.course_name, (
	SELECT COUNT(*) FROM enrollment e WHERE e.course_id = c.course_id
) AS total 
FROM courses c;

-- Students & their total credits
SELECT s.name, (
	SELECT SUM(c.credits) 
	FROM enrollment e 
	JOIN courses c ON e.course_id = c.course_id
	WHERE e.student_id = s.student_id
) AS total_credit
FROM students s;

-- All students in the 3rd semester
SELECT name FROM students
WHERE student_id IN (SELECT student_id FROM enrollment WHERE semester = 'SEM 3');

-- AVG credit taken by @ student
	SELECT s.name, (SELECT AVG(c.credits) FROM enrollment e 
	JOIN courses c ON e.course_id = c.course_id
	WHERE e.student_id = s.student_id) AS average_credit
	FROM students s;

-- Youngest student in the class
SELECT name, age 
FROM students
ORDER BY age ASC
LIMIT 1;

-- students NOT enrolled in any course
SELECT name
FROM students 
WHERE student_id NOT IN(SELECT student_id FROM enrollment);

-- Students with Grade A and courses
SELECT s.name, c.course_name
FROM students s 
JOIN enrollment e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE grade = 'A';

-- COURSES with students >1
SELECT course_name
FROM courses
WHERE course_id IN(
	SELECT course_id FROM enrollment
	GROUP BY course_id HAVING COUNT(*) > 1
);

-- Max credit a student is taking
SELECT MAX(total_credits) 
FROM (
	SELECT e.student_id, SUM(c.credits) AS total_credits
	FROM enrollment e
	JOIN courses c ON e.course_id = c.course_id
	GROUP  BY e.student_id
)
students_credit;



























