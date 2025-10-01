
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

--Section 4: Joins (Q21–Q40)
--Show each student with the courses they are enrolled in.
SELECT 
    s.name AS student_name,
    c.course_name
FROM students s
JOIN enrollment e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

--Show student names and the semester of their enrollments.
SELECT 
s.name AS student_name,
e.semester
FROM students s
JOIN enrollment e ON s.student_id = e.student_id
ORDER BY e.semester;

--Show course names along with the names of students enrolled.
SELECT 
c.course_name AS Courses,
s.name AS student_name
FROM courses c
JOIN enrollment e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
ORDER BY c.course_name;

--Show all students who are NOT enrolled in any course (use LEFT JOIN).
SELECT 
    s.name AS student_name, c.course_name
FROM students s
LEFT JOIN enrollment e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
WHERE e.course_id IS NULL;

--Show the total number of students enrolled in each course.
SELECT c.course_name, COUNT(e.student_id) AS total_count 
FROM enrollment e
LEFT JOIN courses c ON e.course_id = c.course_id
GROUP BY c.course_name 
ORDER BY total_count DESC;

--Show average age of students per course.
SELECT 
    c.course_name,
    ROUND(AVG(s.age),2) AS average_age
FROM courses c
JOIN enrollment e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
GROUP BY c.course_name;

--Show student names with their grades and the courses they take.
 SELECT s.name, s.grade, c.course_name
 FROM enrollment e
 JOIN courses c ON e.course_id = c.course_id
 JOIN students s ON e.student_id = s.student_id;

--Show each course with the semester it is taken in.
 SELECT DISTINCT c.course_name, e.semester
 FROM enrollment e
 JOIN courses c ON e.course_id = c.course_id
 ORDER BY e.semester;

--Show names of students enrolled in courses with more than 3 credits.
 SELECT  DISTINCT s.name, c.credits
 FROM students s
 JOIN enrollment e ON s.student_id = e.student_id 
 JOIN courses c ON e.course_id = c.course_id
 WHERE c.credits > 3
 ORDER BY s.name;

--Show all enrollments with student name, course name, and semester.
 SELECT s.name, c.course_name, e.semester
 FROM enrollment e
 JOIN students s ON e.student_id = s.student_id
 JOIN courses c ON e.course_id = c.course_id
 ORDER BY e.semester;

--Show each student and their courses using INNER JOIN.(unmatching row excluded - “Only return rows where there’s a match in both tables.”)
 SELECT s.name, c.course_name
 FROM students s
 INNER JOIN enrollment e ON s.student_id = e.student_id
 INNER JOIN courses c ON e.course_id = c.course_id
 ORDER BY c.course_name;

--Show all students and their courses using LEFT JOIN.
-- All records on the left table and matching on the right (null values if there is on right)
	SELECT s.name, c.course_name
	FROM students s
	LEFT JOIN enrollment e ON s.student_id = e.student_id
	LEFT JOIN courses c ON e.course_id = c.course_id
	ORDER BY c.course_name;

-- Show all courses and their students using RIGHT JOIN.
--Returns all records from the right table and matching records from the left table
 SELECT c.course_name, s.name
 FROM courses c
 RIGHT JOIN enrollment e ON c.course_id  = e.course_id
 RIGHT JOIN students s ON e.student_id = s.student_id
 ORDER BY c.course_name;

--Show all students and all courses (whether matched or not) using FULL JOIN.
-- returns all records when there is a match in left (table1) or right (table2) table records.
 SELECT s.name, c.course_name
 FROM students s
 FULL OUTER JOIN enrollment e ON s.student_id = e.student_id
 FULL JOIN courses c ON e.course_id = c.course_id
 ORDER BY c.course_name;

--Show each student and how many courses they are enrolled in.
 SELECT s.name, COUNT(e.course_id) AS total_courses
 FROM students s
 JOIN enrollment e ON s.student_id = e.student_id
 GROUP BY s.name
 ORDER BY total_courses DESC;

--Show each course and how many students are enrolled in it.
 SELECT c.course_name, COUNT(e.student_id) AS total_students
 FROM enrollment e
 JOIN courses c ON e.course_id = c.course_id
 GROUP BY c.course_name
 ORDER BY total_students DESC;









