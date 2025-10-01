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
    course_id INT REFERENCE courses(co),
    semester NUMERIC
);

-- SP to update students grades
CREATE OR REPLACE PROCEDURE sp_updateStudentgrade(
	p_student_id INT,
	p_grade TEXT
)

LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE students SET grade = p_grade
	WHERE student_id = p_student_id;
END;
$$;
CALL sp_updateStudentgrade(12, 'A')

-- SP to add new students 
CREATE OR REPLACE PROCEDURE sp_addNewstudent(
	p_name TEXT,
	p_age INT,
	p_grade TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO students(name,age,grade)
	VALUES(p_name, p_age, p_grade);
END;
$$;

CALL sp_addNewstudent('James Maiyo', 26, 'D');
SELECT * FROM students;

-- SP to add new students 
CREATE OR REPLACE PROCEDURE sp_deleteStudent(
	p_student_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM students 
	WHERE student_id = p_student_id;
END;
$$;
CALL sp_deleteStudent(21)
select * from students

-- SP to enroll students into a course
CREATE OR REPLACE PROCEDURE sp_enrollStudent(
	p_student_id INT,
	p_course_id INT,
	p_semester TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO enrollment(student_id, course_id, semester)
	VALUES(p_student_id, p_course_id, p_semester);
END;
$$;

CALL sp_enrollStudent(20, 5, 'SEM 4');
SELECT * FROM enrollment;













