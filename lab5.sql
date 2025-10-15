---Ademi Gaibulla
---24B032126

CREATE TABLE employees ( ---employees table
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary>0)
);

CREATE TABLE product_catalog( ---product catalog table
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK(
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price)
);

CREATE TABLE bookings ( ---booking table
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK(num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_date CHECK(check_out_date>check_in_date)
);

CREATE TABLE customers( ---customers table
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE inventory( ---inventory table
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity>=0),
    unit_price NUMERIC NOT NULL CHECK(unit_price>0),
    last_update TIMESTAMP NOT NULL
);

---INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
---(1,'ademi1112g@gmail.com', '87472728455', '2022-12-11'),
---(2, 'karina123@gmail.com', NULL, '2024-02-23');

---INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
---(3, 'alkdka@gmail.com', '390303', NULL);

---INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
---(4, 'skmdke@gmail.com', NULL, '2025-10-15');

CREATE TABLE users( --users table
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP,
    CONSTRAINT unique_username CHECK(username),
    CONSTRAINT unique_email CHECK(email)
);

CREATE TABLE course_enrollments( ---course enrollment table
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment UNIQUE(student_id, course_code, semester)
);

---INSERT INTO users (user_id, username, email, created_at) VALUES
---(1,'ademi1212','ademigaibulla@gmail.com', '2020-04-15');

---INSERT INTO users(user_id, username, email, created_at) VALUES
---(2,'ademi1212', 'ademigaibulla@gmail.com', '2024-11-05');

CREATE TABLE departments ( ---departments table
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

---INSERT INTO departments(dept_id, dept_name, location) VALUES
---(1,'IT','Tole bi 57');

---INSERT INTO departments(dept_id, dept_name, location) VALUES
---(1, 'HR', 'Ablaikhan st.');

---INSERT INTO departments(dept_id, dept_name, location) VALUES
---(NULL,'Sales','Panfilov 10');

CREATE TABLE student_courses( ---student courses table
  student_id INTEGER,
  course_id INTEGER,
  enrollment_date DATE,
  grade TEXT,
  CONSTRAINT pk_student_course PRIMARY KEY(student_id, course_id)
);

---UNIQUE: ensures values are unique, allows NULLs, multiple per table
---PRIMARY KEY: identifies each row, no NULLs, only one per table
---Single-column: one column is enough to identify a row
--Composite: combination of columns needed to identify a row
---Only one PK as main identifier
--Multiple UNIQUE for other unique data (like email or username)

CREATE TABLE employees_dept( --employees departments table
  emp_id INTEGER PRIMARY KEY,
  emp_name TEXT NOT NULL,
  dept_id INTEGER REFERENCES departments(dept_id),
  hire_date DATE
);

---INSERT INTO employees_dept(emp_id, emp_name, dept_id, hire_date) VALUES
---(1,'ademi',1, '2038-05-24');

---INSERT INTO employees_dept(emp_id, emp_name, dept_id, hire_date) VALUES
---(2, 'karina', 11, '2012-10-14');

CREATE DATABASE library_db;

CREATE TABLE authors( --authors table
  author_id INTEGER PRIMARY KEY,
  author_name TEXT NOT NULL,
  country TEXT
);

CREATE TABLE publishers( --publishers table
  publisher_id INTEGER PRIMARY KEY,
  publisher_name TEXT NOT NULL,
  city TEXT
);

CREATE TABLE books( --books table
  book_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INTEGER REFERENCES authors(author_id),
  publisher_id INTEGER REFERENCES publishers(publisher_id),
  publication_year INTEGER,
  isbn TEXT UNIQUE
);

---INSERT INTO authors (author_id, author_name, country) VALUES
---(1,'Agatha', 'USA');

---INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
---(1,'Vogue', 'France');

---INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
---(1,'Harry Potter', 1, 1, 2017,'978-3-16-148410-0');

CREATE TABLE categories( --categories table
  category_id INTEGER PRIMARY KEY,
  category_name TEXT NOT NULL
);

CREATE TABLE products_fk( --products fk table
  product_id INTEGER PRIMARY KEY,
  product_name TEXT NOT NULL,
  category_id INTEGER REFERENCES categories(category_id) DELETE ON RESTRICT
);

CREATE TABLE orders( --orders table
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK(total_amount>=0),
    status TEXT NOT NULL CHECK(status IN('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items( --order items table
  item_id INTEGER PRIMARY KEY,
  order_id INTEGER REFERENCES orders(order_id) DELETE ON CASCADE,
  product_id INTEGER REFERENCES products_fk(product_id),
  quantity INTEGER CHECK(quantity>0)
);

DELETE FROM categories WHERE category_id = 1; ---Error occurs, deletion is prevented, dependent products remain
DELETE FROM orders WHERE order_id = 1; ---Order is deleted, all related order_items are automatically deleted

INSERT INTO customers(customer_id, name, email, phone, registrtion_date) VALUES
(1, 'Ademi', 'ademi1345@gmail.com', '12345678', '2023-01-10'),
(2, 'Karina', 'karin654@gmail.com', '585495490', '2020-05-23'),
(3, 'Aizhan', 'aizhan02020@gmail.com', '83993923', '2024-02-30'),
(4, 'Alice', 'alice102020@gmail.com', '390302', '2021-03-04'),
(5, 'Bob', 'bob93929@gmail.com', '932902', '2023-05-24');

CREATE TABLE products(
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK(price>=0),
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity>=0)
);

INSERT INTO products(product_id, name, description, price, stock_quantity) VALUES
(1,'Laptop', 'Gaming laptop', 1200, 10),
(2,'Smartphone', 'Latest model', 800, 25),
(3, 'Headphones', 'Noise cancelling', 150, 50),
(4, 'Keyboard', 'Mechanical keyboard', 100, 30),
(5, 'Mouse', 'Wireless mouse', 50, 40);

INSERT INTO orders(order_id, customer_id, order_date, total_amount, status) VALUES
(1,1, '2023-06-01', 1200, 'pending'),
(2,2, '2023-06-02', 800, 'processing'),
(3,3, '2023-06-03', 200, 'shipped'),
(4,1, ' 2023-06-04', 150, 'delivered'),
(5,4, '2023-06-05', 100, 'cancelled');

CREATE TABLE order_details(
  order_detail_id INTEGER PRIMARY KEY,
  order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(product_id),
  quantity INTEGER NOT NULL CHECK(quantity>0),
  unit_price NUMERIC NOT NULL CHECK(unit_price>=0)
);

INSERT INTO order_derails(order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(1,1,1,1,1200),
(2,2,2,1,800),
(3,3,3,2,150),
(4,4,4,1,100),
(5,5,5,2,50);
