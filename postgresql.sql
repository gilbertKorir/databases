--INTRO TO POSTGRESQL
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    grade VARCHAR(100));

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT);

CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    semester VARCHAR(100));

-- FILTERING
SELECT name from students
ORDER BY age ASC ;

SELECT * from students
ORDER BY grade DESC ;

SELECT * FROM students
WHERE name LIKE '%J%' ;

SELECT * from courses
WHERE course_name LIKE 'Math%';

SELECT * from students
WHERE age BETWEEN 21 AND 27;

SELECT * from students
WHERE grade = 'C' OR grade = 'A';


-- FILTERING
SELECT name from students
ORDER BY age ASC ;

SELECT * from students
ORDER BY grade DESC ;

SELECT * FROM students
WHERE name LIKE '%J%' ;

SELECT * from courses
WHERE course_name LIKE 'Math%';

SELECT * from students
WHERE age BETWEEN 21 AND 27;

SELECT * from students
WHERE grade = 'C' OR grade = 'A';

--OTHERS
SELECT COUNT(*) AS grade_b
FROM students
WHERE grade = 'B';

SELECT COUNT(*) AS grade_e
FROM students
WHERE grade = 'E';

SELECT ROUND(AVG(age),2) AS student_avgage
FROM students;

SELECT ROUND(AVG(age),2) AS student_avgage
FROM students
WHERE grade = 'A'; -- Avg age for students

SELECT SUM(credits) AS total_credits
FROM courses;

SELECT SUM(credits) AS total_credits
FROM courses;

SELECT semester, COUNT(*) AS total_semcounts
FROM enrollment
GROUP BY semester
ORDER BY total_semcounts ASC;

--Update the table
UPDATE students 
SET grade ='B' WHERE grade = 'E';
select * FROM students;

UPDATE courses 
SET credits = 5 WHERE credits = 2;
select * FROM courses;

UPDATE enrollment 
SET semester = 'SEM 1'
WHERE student_id = 10 AND course_id = 5;
select * FROM enrollment;



