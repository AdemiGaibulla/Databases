--Part 1

CREATE TABLE departments(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects(
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101,'IT','Building A'),
(102,'HR','Building B'),
(103,'Operations','Building C');

INSERT INTO employees VALUES
(1,'John Smith', 101, 50000),
(2,'Jane Doe', 101, 55000),
(3,'Mike Johnson', 102, 48000),
(4,'Sarah Williams', 102, 52000),
(5,'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201,'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203,'HR System Upgrade', 50000,102);

--Part 2
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
--Answer: 1) employees_pkey = PRIMARY KEY index
--2) emp_salary_idx = salary index

CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;
--Answer: Indexing a foreign key makes the database find matching rows faster and work more smoothly

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--Answer: employees_pkey, emp_salary_idx, emp_dept_idx, departments_pkey, projects_pkey
--automatically: employees_pkey, departments_pkey, projects_pkey

--Part 3
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, employees.salary
FROM employees
WHERE dept_id = 101 AND salary > 52000
--Answer: No, it would not be useful, because in a multicolumn index the first column(dept_id) must be used. f the query does not filter by dept_id, the index cannot help.

CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
--Answer: Yes, order matters. The index works here because `dept_id` (first column) is used; without it, the index wouldn’t help.

--Part 4
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id,emp_name,dept_id,salary,email)
VALUES (6, 'New Employee', 101, 55000,'johnsmith@company.com');
--Answer: ERROR:  duplicate key value violates unique constraint "emp_email_unique_idx"
--Because johnsmith@company.com already exists

ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pq_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
--Answer: Yes, PostgreSQL automatically creates a unique index on the phone column to enforce the UNIQUE constraint

--Part 5
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, employees.salary
FROM employees
ORDER BY salary DECS
--Answer: The index stores the salaries in descending order, so PostgreSQL can quickly return rows sorted by salary without extra sorting

CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, projects.budget
FROM projects
ORDER BY budget NULLS FIRST;

--Part 6
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
--Answer: Without the index, PostgreSQL would have to scan every row in the table and apply LOWER(emp_name) to each one, which is much slower.

ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--Part 7
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

DROP INDEX emp_salary_dept_idx;
--Answer: We might drop an index because it is unused, redundant, or slows down inserts/updates while taking extra space.

REINDEX INDEX employees_salary_index;

--Part 8

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
--Answer: A partial index is smaller and faster because it only includes rows that meet the condition, saving space and improving query performance.

EXPLAIN SELECT * FROM employees WHERE salary > 52000;
--Answer: It may show a Seq Scan, meaning PostgreSQL chose to scan the whole table instead of using the index.

--Part 9
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
--Answer: Use a HASH index only for simple equality checks (=), not for sorting or range queries.

CREATE INDEX proj_name_btree_idx ON projects(proj_name);

CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';

SELECT * FROM projects WHERE proj_name > 'Database';

--Part 10
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--Answer: The largest index is usually the PRIMARY KEY index on the biggest table, because it contains one entry for every row and is always unique.

DROP INDEX IF EXISTS proj_name_hash_idx;

CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

--1) B-tree
--2) When a column is used in WHERE filters, When a column is used in JOIN, When a column is used in ORDER BY
--3) When the table is very small, When the column is updated very often
--4) Indexes must be updated too, which makes these operations slower.
--5) Use EXPLAIN (or EXPLAIN ANALYZE).