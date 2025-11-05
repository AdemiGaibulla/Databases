---Part 1
 Create table: employees
 CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
 )

 CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
 )
 CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
 );

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 102, 60000),
 (3, 'Mike Johnson', 101, 55000),
 (4, 'Sarah Williams', 103, 65000),
 (5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
 (101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Finance', 'Building C'),
 (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
 (1, 'Website Redesign', 101, 100000),
 (2, 'Employee Training', 102, 50000),
 (3, 'Budget Analysis', 103, 75000),
 (4, 'Cloud Migration', 101, 150000),
 (5, 'AI Research', NULL, 200000);

---Part 2
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

---Answer: 5 employees * 4 departments = 20 rows

SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

SELECT e.emp_name, d.dept_name
FROM employees e,
INNER JOIN departments d ON TRUE;

SELECT e.emp_name, d.dept_name
FROM employees e,
CROSS JOIN projects p;

---Part 3
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
--Answer: 4 rows are returned. Tom Brown not included because he doesn't have dept_id. Inner join return only rows that included in both tables

SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
--Answer: with ON we can choose different columns, while with USING we can work only with one column

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

---Part 4
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
--Answer: Tom Brown appears in result with his department columns showing NULL

SELECT e.emp, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments USING (dept_id);

SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

---Part 5
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--Part 6
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
--Answer: on the left side Tom Brown have NULL value and on the right side Marketing

SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without
employees'
        WHEN d.dept_id IS NULL THEN 'Employee without
department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--Part 7
Filter in ON clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND
d.location = 'Building A';

Filter in WHERE clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--Answer:  Query 1 (ON clause): Applies the filter BEFORE the join, so all employees are included, but only departments in Building A are matched.
-- Query 2 (WHERE clause): Applies the filter AFTER the join, so employees are excluded if their department is not in Building A.

Filter in ON clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND
d.location = 'Building A';

Filter in WHERE clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Answer: when we use ON we have difference because with LEFT JOIN result will show all employees but with INNER JOIN it will show only that rows that match.
-- when we use WHERE we don't have difference because WHERE already do same that INNER JOIN do

--Part 8
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

ALTER TABLE employees ADD COLUMN manager_id INT

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

--1) INNER JOIN: returns only the rows that have matching values in both tables
--LEFT JOIN: returns all rows from the left table, and matching rows from the right table
--2) we use CROSS JOIN when you need all possible combinations of two tables
--3) for INNER JOIN, both ON and WHERE filters work the same, only matching rows remain
--for OUTER JOIN: ON keeps unmatched rows; WHERE can remove them
--4) 5 × 10 = 50 rows
--5) it automatically joins tables on columns with the same name in both tables, like dept_id
--6) it can accidentally join on the wrong columns or behave differently if the table structure changes
--7)
SELECT *
FROM B
RIGHT JOIN A ON A.id = B.id;
--8) we use it when we need all rows from both tables, even those without matches

--Additional tasks
SELECT *
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT *
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

SELECT e.emp_name, e.dept_id
FROM employees e
WHERE e.dept_id IN (
  SELECT dept_id
  FROM projects
  GROUP BY dept_id
  HAVING COUNT(*) > 1
);

SELECT e.emp_name AS employee,
       m.emp_name AS manager,
       mm.emp_name AS managers_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
LEFT JOIN employees mm ON m.manager_id = mm.emp_id;

SELECT e1.emp_name AS employee1, e2.emp_name AS employee2, e1.dept_id
FROM employees e1
JOIN employees e2
  ON e1.dept_id = e2.dept_id
 AND e1.emp_id < e2.emp_id;
