CREATE TABLE accounts(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE products(
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name 'Bob';
COMMIT;

--a) Alice(-100) = 900, Bob(+100) = 600, Wally = 750
--b)Because the money transfer is one logical operation. A transaction ensures either both changes happen or none, preventing inconsistency.
--c) Alice’s balance would decrease, but Bob wouldn’t receive the money.

BEGIN;
UPDATE accounts SET balance = balance - 500.00
    WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--a)500
--b)1000. Rollback undoes the change
--c)When the wrong data was entered or when an error occurs during a transaction

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;

--a) Alice: 900, Bob: 500, Wally: 850
--b) Yes, temporarily, but the ROLLBACK TO savepoint undid it, so in the final state his balance didn’t change
--c) Allows partial rollback without undoing the entire transaction

--Scenario A
--Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
      SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

--Scenario B
--Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
      SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

--a) Before: Terminal 1 sees the original products(Coke, Pepsi). After: Terminal 1 sees updated products(Fanta)
--b) Terminal 1 cannot see changes made by Terminal 2 until it commits
--c) READ COMMITTED: sees only committed changes, can see updated data from other transaction
--SERIALIZABLE: highest isolation, transactions appear sequential

--Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

--a) No, because REPEATABLE READ prevents changes to the rows it has already read.
--b) A phantom read is when new or deleted rows appear in repeated queries within a transaction
-- c) SERIALIZABLE isolation level prevents phantom reads

--Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
      SELECT * FROM products WHERE shop  = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;

--Terminal 2
BEGIN;
UPDATE products SET price = 99.99
    WHERE product = 'Fanta';
-- Wait here (don't commit yet)-- Then:
ROLLBACK;

--a) Yes, Terminal 1 saw the price of 99.99 before Terminal 2 rolled back, which is problematic because it reads uncommitted, potentially invalid data
--b) A dirty read occurs when a transaction reads data that has been modified by another transaction but not yet committed
--c) READ UNCOMMITTED should be avoided because it can cause inconsistent or incorrect results due to reading uncommitted changes

--4. Independent Exercises
--Exercise 1
BEGIN;
UPDATE accounts SET balance = balance - 200.00
    WHERE name = 'Bob' AND balance >= 200.00;
UPDATE accounts SET balance = balance + 200
    WHERE name = 'Wally' AND (SELECT balance FROM accounts WHERE name = 'Bob') >= 0;
COMMIT;

--Exercise 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
SAVEPOINT sp1;

UPDATE products SET price = 4.50
WHERE product = 'Sprite';
SAVEPOINT sp2;

DELETE FROM products
WHERE product = 'Sprite';
ROLLBACK TO sp1;

COMMIT;

--Exercise 3
--Terminal 1,1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 1.2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 2.1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 2.2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 3.1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 3.2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
ROLLBACK;

--Terminal 4.1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

--Terminal 4.2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
ROLLBACK;

--Exercise 4
BEGIN TRANSACTION;
UPDATE Sells SET price = price + 20 WHERE shop = 'A';
COMMIT;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT MIN(price) FROM Sells;
SELECT MAX(price) FROM Sells;
COMMIT;

--Question:
--1) Atomicity: All-or-nothing; e.g., $100 transfer: either deducted and added or nothing changes.
--Consistency: Keeps data valid; e.g., total balance stays the same after transfer.
--Isolation: Transactions don’t interfere; e.g., concurrent withdrawals see correct balances.
--Durability: Changes are permanent; e.g., committed transfer stays even if the system crashes.

--2) COMMIT saves changes permanently; ROLLBACK undoes them.
--3) Allows partial rollback within a transaction without undoing all changes
--4) READ UNCOMMITTED allows dirty reads; READ COMMITTED prevents dirty reads; REPEATABLE READ prevents non-repeatable reads; SERIALIZABLE prevents phantom reads.
--5) Reading uncommitted changes; allowed in READ UNCOMMITTED.
--6) Reading the same row twice shows different values due to another committed transaction. Example: Transaction T1 reads balance = 100. T2 withdraws 50 and commits. T1 reads balance again -> 50.
--7) New rows appear between queries in a transaction; prevented by SERIALIZABLE
--8) READ COMMITTED allows higher concurrency and better performance
--9) ACID properties ensure multiple users do not corrupt the database
--10)All uncommitted changes are lost; database rolls back to last committed state.

--Conclusion: Transactions ensure database reliability by enforcing ACID properties. They prevent inconsistencies during concurrent access, allow controlled rollback with SAVEPOINTs, and maintain data integrity even in case of system failures.




