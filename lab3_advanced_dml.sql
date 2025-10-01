CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50) NOT NULL,
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id    SERIAL PRIMARY KEY,
    project_name  VARCHAR(100) NOT NULL,
    dept_id       INTEGER,
    start_date    DATE,
    end_date      DATE,
    budget        INTEGER
);

INSERT INTO employees (first_name, last_name, department)
VALUES ('Ademi', 'Gaibulla', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Sokhi', 'Kang', 'Sales', DEFAULT, DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id) VALUES
  ('IT', 150000, NULL),
  ('Sales', 120000, NULL),
  ('HR', 80000, NULL);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('John', 'Park', 'IT', CAST(50000 * 1.1 AS INTEGER), CURRENT_DATE);

CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
  WHEN salary > 80000 THEN 'Management'
  WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
  ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments
SET budget = (SELECT AVG(salary) * 1.2
              FROM employees
              WHERE employees.department = departments.dept_name);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
  SELECT DISTINCT department
  FROM employees
  WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Arun', 'Karasay', NULL, NULL, CURRENT_DATE, 'Active');

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Bob', 'Kim', 'IT', 60000, CURRENT_DATE, 'Active')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT 'Mark', 'Lee', 'Sales', 55000, CURRENT_DATE, 'Active'
WHERE NOT EXISTS (
  SELECT 1 FROM employees
  WHERE first_name = 'Mark' AND last_name = 'Lee'
);

UPDATE employees
SET salary = salary * CASE
  WHEN (SELECT budget
        FROM departments
        WHERE departments.dept_name = employees.department) > 100000
  THEN 1.10
  ELSE 1.05
END;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
  ('Emp1','One','IT',50000,CURRENT_DATE,'Active'),
  ('Emp2','Two','IT',52000,CURRENT_DATE,'Active'),
  ('Emp3','Three','Sales',48000,CURRENT_DATE,'Active'),
  ('Emp4','Four','Sales',51000,CURRENT_DATE,'Active'),
  ('Emp5','Five','HR',45000,CURRENT_DATE,'Active');

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Emp1','Emp2','Emp3','Emp4','Emp5');


CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);
INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND EXISTS (
    SELECT 1
    FROM employees
    WHERE employees.department = projects.dept_id
    GROUP BY employees.department
    HAVING COUNT(*) > 3
  );

