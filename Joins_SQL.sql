
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
select * from courses;

--Section 4: Joins (Q21–Q40)
--Show each student with the courses they are enrolled in.

SELECT 
    students.name AS student_name,
    courses.course_name
FROM students
JOIN enrollment ON students.student_id = enrollment.student_id
JOIN courses ON enrollment.course_id = courses.course_id;

--Show student names and the semester of their enrollments.
SELECT 
students.name AS student_name,
enrollment.semester
FROM students
JOIN enrollment ON students.student_id = enrollment.student_id;

--Show course names along with the names of students enrolled.
SELECT 
courses.course_name AS Courses,
students.name AS student_name
FROM courses
JOIN enrollment ON courses.course_id = enrollment.course_id
JOIN students ON enrollment.student_id = students.student_id;

--Show all students who are NOT enrolled in any course (use LEFT JOIN).
SELECT 
    students.name AS student_name
FROM students
LEFT JOIN enrollment ON students.student_id = enrollment.student_id
WHERE enrollment.course_id IS NULL;

--Show the total number of students enrolled in each course.
SELECT courses.course_name,
       COUNT(enrollment.student_id) AS total_count 
FROM enrollment
JOIN courses ON enrollment.course_id = courses.course_id
GROUP BY courses.course_name;

--Show average age of students per course.
SELECT 
    courses.course_name,
    ROUND(AVG(students.age),2) AS average_age
FROM courses
JOIN enrollment ON courses.course_id = enrollment.course_id
JOIN students ON enrollment.student_id = students.student_id
GROUP BY courses.course_name;

--Show student names with their grades and the courses they take.
 SELECT students.name, students.grade, courses.course_name
 FROM enrollment
 JOIN courses ON enrollment.course_id = courses.course_id
 JOIN students ON enrollment.student_id = students.student_id;

--Show each course with the semester it is taken in.
 SELECT courses.course_name, enrollment.semester
 FROM enrollment
 JOIN courses ON enrollment.course_id = courses.course_id;

--Show names of students enrolled in courses with more than 3 credits.
 SELECT  DISTINCT students.name, courses.credits
 FROM students 
 JOIN enrollment ON students.student_id = enrollment.student_id 
 JOIN courses ON enrollment.course_id = courses.course_id
 WHERE courses.credits > 3
 ORDER BY students.name;

--Show all enrollments with student name, course name, and semester.
 SELECT students.name, courses.course_name, enrollment.semester
 FROM enrollment
 JOIN students ON enrollment.student_id = students.student_id
 JOIN courses ON enrollment.course_id = courses.course_id
 ORDER BY enrollment.semester;

--Show each student and their courses using INNER JOIN.(unmatching row excluded - “Only return rows where there’s a match in both tables.”)
 SELECT students.name, courses.course_name
 From students
 INNER JOIN enrollment ON students.student_id = enrollment.student_id
 INNER JOIN courses ON enrollment.course_id = courses.course_id;

--Show all students and their courses using LEFT JOIN.
-- All records on the left table and matching on the right (null values if there is on right)
 SELECT students.name, courses.course_name
 FROM students
 LEFT JOIN enrollment ON students.student_id = enrollment.student_id
 LEFT JOIN courses ON enrollment.course_id = courses.course_id
 ORDER BY courses.course_name;

-- Show all courses and their students using RIGHT JOIN.
--Returns all records from the right table and matching records from the left table
  SELECT courses.course_name, students.name
  FROM students
  RIGHT JOIN enrollment ON students.student_id = enrollment.student_id
  RIGHT JOIN courses ON enrollment.course_id = courses.course_id
  ORDER BY courses.course_name;

--Show all students and all courses (whether matched or not) using FULL JOIN.
-- returns all records when there is a match in left (table1) or right (table2) table records.
 SELECT students.name, courses.course_name
 FROM students
 FULL OUTER JOIN enrollment ON students.student_id = enrollment.student_id
 FULL JOIN courses ON enrollment.course_id = courses.course_id
 ORDER BY courses.course_name;

--Show each student and how many courses they are enrolled in.
 SELECT students.name, COUNT(enrollment.course_id) AS total_courses
 FROM students
 JOIN enrollment ON students.student_id = enrollment.student_id
 GROUP BY students.name
 ORDER BY total_courses DESC;

--Show each course and how many students are enrolled in it.
 SELECT courses.course_name, COUNT(enrollment.student_id) AS total_students
 FROM enrollment
 JOIN courses ON enrollment.course_id = courses.course_id
 GROUP BY courses.course_name
 ORDER BY total_students DESC;

 
 








