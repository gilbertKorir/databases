-- CTES 
-- AVG age & least student 
 WITH AVG_age AS (
	SELECT AVG(age) AS A FROM students
 )
 SELECT name, age FROM students, AVG_age 
 WHERE age > A;

-- count enrollment per student
WITH enrollment_COUNT AS (
	SELECT student_id, COUNT(*) AS total 
	FROM enrollment
	GROUP BY student_id
)
SELECT s.name, e.total FROM students s
JOIN enrollment_COUNT e ON s.student_id = e.student_id;

-- Courses with total students enrolled
WITH COURSE_count AS (
	SELECT course_id, COUNT(*) AS total
	FROM enrollment
	GROUP BY course_id
)
SELECT c.course_name, total 
FROM courses c 
JOIN COURSE_count cc 
ON c.course_id = cc.course_id; 

-- Get students & total credits
WITH Student_Credit AS (
	SELECT e.student_id, SUM(c.credits) AS total_credits
	FROM enrollment e 
	JOIN courses c ON e.course_id = c.course_id
	GROUP BY e.student_id
)
SELECT s.name, total_credits FROM students s 
JOIN Student_Credit  sc ON s.student_id = sc.student_id;

-- All students in sem 3
WITH Sem_Students AS (
	 SELECT student_id FROM enrollment
	 WHERE semester = 'SEM 3'
)
SELECT name FROM students 
WHERE student_id IN(SELECT student_id FROM Sem_Students);

-- AVG credit taken by @ STUDENT
WITH AVG_Credit AS (
	 SELECT e.student_id, AVG(c.credits) AS AVG_credit
	 FROM enrollment e 
	 JOIN courses c ON e.course_id = c.course_id
	 GROUP BY e.student_id 
)
SELECT s.name, AVG_credit FROM students s 
JOIN AVG_Credit ac ON s.student_id = ac.student_id;

-- 



































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



























