CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE,
    full_name VARCHAR(200),
    phone TEXT,
    email VARCHAR(200),
    status TEXT CHECK(status IN('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT NOW(),
    daily_limit_kzt INTEGER
);

CREATE TABLE accounts(
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_number TEXT UNIQUE,
    currency TEXT CHECK(currency IN('KZT', 'USD', 'EUR', 'RUB')),
    balance NUMERIC,
    is_active BOOLEAN,
    opened_at DATE,
    closed_at DATE
);

CREATE TABLE transactions(
    transaction_id  SERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts (account_id),
    to_account_id   INTEGER REFERENCES accounts (account_id),
    amount          NUMERIC,
    currency        TEXT CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    exchange_rate   NUMERIC,
    amount_kzt      NUMERIC,
    type            TEXT CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status          TEXT CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at      DATE,
    completed_at    DATE,
    description     TEXT
);

CREATE TABLE exchange_rate(
    rate_id SERIAL PRIMARY KEY,
    from_currency TEXT CHECK (from_currency IN ('KZT','USD','EUR','RUB')),
    to_currency TEXT CHECK (to_currency IN ('KZT','USD','EUR','RUB')),
    rate NUMERIC,
    valid_from DATE,
    valid_to DATE,
    CHECK (from_currency <> to_currency)
);

CREATE TABLE audit_log(
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(200),
    record_id INTEGER,
    action TEXT CHECK(action IN('INSERT','UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP DEFAULT NOW(),
    ip_address TEXT
);

INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('061211600500','Ademi Gaibulla','87472728455', 'ademi1112g@gmail.com', 'active', 10000),
('123456789234','Kim Alex','87472910106','alexkim@gmail.com','frozen', 20000),
('203032134323','Arun Karassay','87023457856','arun@gmail.com','blocked',32932),
('393203134352','Gulnaz Muratbek','87023884929','gulnazm@gmail.com','active',32500),
('788362728193','Aruzhan Shomanove','87472783459','shomanova@gmail.com','active',29000),
('848958348883','Alina Ten','87017653846','tenalina@gmail.com','frozen',10000),
('493024324321','Aisha Kudaibergen','87023579664','aisha@gmail.com','blocked', 30000),
('547381919299','Soobin Choi','84737822045','soobachoi@gmail.com','active',38290),
('300244221344','Taehyun Kang','87024836725','kangtae@gmail.com','blocked',290000),
('098765432212','Huening Kai','4839290213','kaikaikai@gmail.com','frozen',24400);

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active, opened_at, closed_at) VALUES
(1, '362819', 'KZT', 12000, true, '2003-12-12', '2023-02-05'),
(2, '12', 'USD', 349000, true, '2020-10-04', '2024-02-23'),
(3, '2345', 'RUB', 23600, false, '2022-03-22', '2025-01-14'),
(4, '7438', 'KZT', 36000, true, '2019-02-02', '2020-03-26'),
(4, '032032', 'USD', 320030, true, '2020-01-01', '2024-02-10'),
(5, '3993', 'EUR', 400000, false, '2006-12-11', '2008-10-11'),
(6, '40323', 'KZT', 202000, false, '2021-05-02', '2023-11-04'),
(7, '5677', 'USD', 560900, true, '2009-09-09', '2010-10-10'),
(8, '6795', 'EUR', 78890, true, '2029-09-29', '2030-08-06'),
(9, '6790', 'USD', 60000, true, '2007-07-17', '2008-08-18'),
(10,'5678', 'KZT', 8900000, true, '2018-11-11', '2023-12-12');

INSERT INTO exchange_rate(from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD','KZT',46000,'2025-12-11',NULL),
('EUR','KZT',5000000,'2025-12-12',NULL),
('RUB','KZT',600000,'2025-12-13',NULL),
('USD','EUR',45030,'2025-12-02',NULL),
('EUR','USD',10020,'2025-12-03',NULL),
('RUB','USD',1010,'2025-12-04',NULL),
('USD','RUB',680,'2025-12-05',NULL),
('USD','KZT',78050,'2025-12-06',NULL),
('EUR','KZT',90660,'2025-12-07',NULL),
('RUB','KZT',70000,'2025-12-08',NULL);

INSERT INTO transactions(from_account_id, to_account_id, amount,currency,exchange_rate,amount_kzt,type,status,created_at,completed_at,description) VALUES
(1,2,100000,'KZT',1.0,100000,'transfer','pending','2024-11-01','2025-11-01','gift'),
(2,1,200,'USD',460,92000,'transfer','completed','2024-11-02','2025-11-02','payment'),
(3,1,50000,'KZT',1.0,50000,'deposit','completed','2024-11-03','2025-11-03','cash deposit'),
(5,8,1000,'USD',460,460000,'transfer','completed','2024-11-04','2025-11-04','payroll'),
(7,8,50000,'RUB',6,300000,'transfer','failed','2024-11-05','2025-11-05','internet pay'),
(8,2,250000,'KZT',1.0,250000,'transfer','completed','2024-11-06','2025-11-06','payment'),
(10,6,100000,'KZT',1.0,100000,'transfer','completed','2024-11-07','2025-11-07','rent'),
(1,9,50,'USD',460,23000,'transfer','completed','2024-11-08','2025-11-08','gift'),
(9,4,100,'EUR',500,50000,'transfer','completed','2024-11-09','2025-11-09','transfer'),
(6,1,250000,'KZT',1.0,250000,'transfer','pending','2024-11-10','2025-11-10','pending transfer');

INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address) VALUES
('accounts', 1, 'INSERT', NULL, jsonb_build_object('account_number','KZ01Ademi0000000001','balance',4000000), 'system', NOW(), '127.0.0.1'),
('transactions', 1, 'INSERT', NULL, jsonb_build_object('amount',100000,'status','completed'), 'tester', NOW(), '127.0.0.1'),
('customers', 3, 'UPDATE', jsonb_build_object('status','blocked'), jsonb_build_object('status','active'), 'admin', NOW(), '192.168.1.10'),
('accounts', 4, 'UPDATE', jsonb_build_object('is_active',true), jsonb_build_object('is_active',false), 'system', NOW(), '127.0.0.1'),
('transactions', 5, 'UPDATE', jsonb_build_object('status','failed'), jsonb_build_object('status','completed'), 'tester', NOW(), '127.0.0.1'),
('exchange_rate', 2, 'UPDATE', jsonb_build_object('rate',5000000), jsonb_build_object('rate',5200000), 'rate_bot', NOW(), '10.10.10.10'),
('customers', 7, 'DELETE', jsonb_build_object('iin','493024324321','full_name','Aisha Kudaibergen'), NULL, 'admin', NOW(), '192.168.1.20'),
('accounts', 10, 'UPDATE', jsonb_build_object('balance',8900000), jsonb_build_object('balance',9000000), 'system', NOW(), '127.0.0.1'),
('transactions', 8, 'INSERT', NULL, jsonb_build_object('amount',50,'currency','USD'), 'tester', NOW(), '127.0.0.1'),
('exchange_rate', 6, 'DELETE', jsonb_build_object('from_currency','EUR','to_currency','USD'), NULL, 'rate_bot', NOW(), '10.10.10.10');

--Task 1
CREATE OR REPLACE FUNCTION process_transfer(
    from_acc_num TEXT,
    to_acc_num TEXT,
    amount NUMERIC,
    currency TEXT,
    description TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    from_acc RECORD;
    to_acc RECORD;
    cust RECORD;
    rate NUMERIC := 1;
    amount_kzt NUMERIC;
    daily_total NUMERIC;
BEGIN
    SELECT * INTO from_acc FROM accounts WHERE account_number = from_acc_num FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Error: source account not found'; END IF;

    SELECT * INTO to_acc FROM accounts WHERE account_number = to_acc_num FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Error: destination account not found'; END IF;

    IF NOT from_acc.is_active OR NOT to_acc.is_active THEN RAISE EXCEPTION 'Error: one account is inactive'; END IF;

    SELECT * INTO cust FROM customers WHERE customer_id = from_acc.customer_id;
    IF cust.status <> 'active' THEN RAISE EXCEPTION 'Error: customer not active'; END IF;

    SELECT COALESCE(SUM(amount_kzt),0) INTO daily_total
    FROM transactions
    WHERE from_account_id = from_acc.account_id
      AND created_at = CURRENT_DATE
      AND status = 'completed';

    IF from_acc.currency <> currency THEN
        SELECT rate INTO rate FROM exchange_rate
        WHERE from_currency = currency AND to_currency = from_acc.currency
        ORDER BY valid_from DESC LIMIT 1;
        IF rate IS NULL THEN RAISE EXCEPTION 'Error: exchange rate not found'; END IF;
    END IF;

    IF currency = 'KZT' THEN
        amount_kzt := amount;
    ELSE
        amount_kzt := amount * rate;
    END IF;

    IF daily_total + amount_kzt > cust.daily_limit_kzt THEN RAISE EXCEPTION 'Error: daily limit exceeded'; END IF;
    IF from_acc.balance < amount THEN RAISE EXCEPTION 'Error: insufficient balance'; END IF;

    UPDATE accounts SET balance = balance - amount WHERE account_id = from_acc.account_id;
    UPDATE accounts SET balance = balance + (amount * CASE WHEN from_acc.currency = to_acc.currency THEN 1 ELSE rate END)
    WHERE account_id = to_acc.account_id;

    INSERT INTO transactions(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, description)
    VALUES(from_acc.account_id, to_acc.account_id, amount, currency, rate, amount_kzt, 'transfer', 'completed', CURRENT_DATE, description);

    INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
    VALUES('transactions', currval('transactions_transaction_id_seq'), 'INSERT', NULL,
           jsonb_build_object('from', from_acc.account_number, 'to', to_acc.account_number, 'amount', amount, 'currency', currency),
           'system', NOW(), inet_client_addr());

    RETURN 'Transfer completed';
END;
$$;

--Task 2
--View 1
CREATE OR REPLACE VIEW customer_balance_summary AS
SELECT
    c.customer_id,
    c.full_name,
    a.account_number,
    a.currency,
    a.balance,
    a.balance * COALESCE(er.rate,1) AS balance_kzt,
    COALESCE(today.total_today,0) AS daily_used,
    ROUND(COALESCE(today.total_today,0) / c.daily_limit_kzt * 100,2) AS daily_limit_pct,
    RANK() OVER (ORDER BY a.balance * COALESCE(er.rate,1) DESC) AS rank_by_balance
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
LEFT JOIN exchange_rate er
    ON er.from_currency = a.currency AND er.to_currency='KZT' AND (er.valid_to IS NULL OR er.valid_to >= CURRENT_DATE)
LEFT JOIN (
    SELECT from_account_id, SUM(amount_kzt) AS total_today
    FROM transactions
    WHERE created_at = CURRENT_DATE AND status='completed'
    GROUP BY from_account_id
) today ON today.from_account_id = a.account_id;

--View 2
CREATE OR REPLACE VIEW daily_transaction_report AS
SELECT
    created_at,
    type,
    COUNT(*) AS total_count,
    SUM(amount_kzt) AS total_amount_kzt,
    AVG(amount_kzt) AS avg_amount_kzt,
    SUM(SUM(amount_kzt)) OVER (ORDER BY created_at) AS running_total,
    ROUND(
        (SUM(amount_kzt) - LAG(SUM(amount_kzt)) OVER (ORDER BY created_at))
        / NULLIF(LAG(SUM(amount_kzt)) OVER (ORDER BY created_at),0) * 100,2
    ) AS day_over_day_growth_pct
FROM transactions
WHERE status='completed'
GROUP BY created_at, type
ORDER BY created_at, type;

--View 3
CREATE OR REPLACE VIEW suspicious_activity_view
WITH (security_barrier = true) AS
SELECT
    t.transaction_id,
    t.from_account_id,
    t.to_account_id,
    t.amount,
    t.amount_kzt,
    t.currency,
    t.created_at,
    CASE
        WHEN t.amount_kzt > 5000000 THEN 'High amount'
        WHEN COUNT(*) OVER(PARTITION BY t.from_account_id, date_trunc('hour', t.created_at)) > 10 THEN 'Many transactions in 1 hour'
        WHEN EXTRACT(EPOCH FROM t.created_at - LAG(t.created_at) OVER(PARTITION BY t.from_account_id ORDER BY t.created_at)) < 60 THEN 'Rapid transfers'
        ELSE NULL
    END AS suspicious_flag
FROM transactions t
WHERE status='completed';

--Task 3
CREATE INDEX idx_accounts_number ON accounts(account_number);
CREATE INDEX idx_accounts_customer_hash ON accounts USING HASH(customer_id);
CREATE INDEX idx_accounts_currency_active ON accounts(currency, is_active);
CREATE INDEX idx_accounts_active_only ON accounts(account_id) WHERE is_active = true;
CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));
CREATE INDEX idx_audit_log_jsonb ON audit_log USING GIN(old_values);
CREATE INDEX idx_audit_log_jsonb_new ON audit_log USING GIN(new_values);
CREATE INDEX idx_transactions_covering ON transactions(from_account_id, to_account_id, amount, status, created_at);

--Task 4
CREATE OR REPLACE FUNCTION process_salary_batch(
    company_account_number TEXT,
    payments JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    company_acc RECORD;
    p JSONB;
    total_batch NUMERIC := 0;
    success_count INT := 0;
    fail_count INT := 0;
    failed_details JSONB := '[]'::JSONB;
    amount NUMERIC;
    emp RECORD;
BEGIN
    PERFORM pg_advisory_lock(hashtext(company_account_number));

    SELECT * INTO company_acc FROM accounts WHERE account_number = company_account_number FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Company account not found'; END IF;

    FOR p IN SELECT * FROM jsonb_array_elements(payments) LOOP
        amount := (p->>'amount')::NUMERIC;
        total_batch := total_batch + amount;
    END LOOP;

    IF company_acc.balance < total_batch THEN RAISE EXCEPTION 'Insufficient balance in company account'; END IF;

    FOR p IN SELECT * FROM jsonb_array_elements(payments) LOOP
        SAVEPOINT sp;
        BEGIN
            SELECT * INTO emp FROM customers WHERE iin = p->>'iin';
            IF NOT FOUND THEN
                fail_count := fail_count + 1;
                failed_details := failed_details || jsonb_build_object('iin', p->>'iin','error','Customer not found');
                CONTINUE;
            END IF;

            UPDATE accounts SET balance = balance + (p->>'amount')::NUMERIC
            WHERE customer_id = emp.customer_id
            RETURNING account_id;

            UPDATE accounts SET balance = balance - (p->>'amount')::NUMERIC
            WHERE account_id = company_acc.account_id;

            INSERT INTO transactions(from_account_id,to_account_id,amount,currency,exchange_rate,amount_kzt,type,status,created_at,description)
            VALUES(company_acc.account_id, emp.customer_id, (p->>'amount')::NUMERIC,'KZT',1,(p->>'amount')::NUMERIC,'transfer','completed',CURRENT_DATE,p->>'description');

            success_count := success_count + 1;
        EXCEPTION WHEN OTHERS THEN
            ROLLBACK TO SAVEPOINT sp;
            fail_count := fail_count + 1;
            failed_details := failed_details || jsonb_build_object('iin', p->>'iin','error',SQLERRM);
        END;
    END LOOP;

    PERFORM pg_advisory_unlock(hashtext(company_account_number));

    RETURN jsonb_build_object('successful_count', success_count, 'failed_count', fail_count, 'failed_details', failed_details);
END;
$$;

CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT
    t.to_account_id,
    c.full_name,
    SUM(t.amount_kzt) AS total_received,
    COUNT(*) AS total_payments
FROM transactions t
JOIN customers c ON t.to_account_id = c.customer_id
WHERE t.type='transfer' AND t.status='completed'
GROUP BY t.to_account_id, c.full_name;

