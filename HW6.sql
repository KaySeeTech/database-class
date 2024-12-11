/* **************************************************************************************** */
-- when set, it prevents potentially dangerous updates and deletes
set SQL_SAFE_UPDATES=0;

-- when set, it disables the enforcement of foreign key constraints.
set FOREIGN_KEY_CHECKS=0;

/* **************************************************************************************** 
-- These control:
--     the maximum time (in seconds) that the client will wait while trying to establish a 
	   connection to the MySQL server 
--     how long the client will wait for a response from the server once a request has 
       been sent over
**************************************************************************************** */
SHOW SESSION VARIABLES LIKE '%timeout%';       
SET GLOBAL mysqlx_connect_timeout = 600;
SET GLOBAL mysqlx_read_timeout = 600;
drop table accounts;
-- Create the accounts table
CREATE TABLE accounts (
  account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...), note change this so that you have have 6 digits id's
  branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
  balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
  account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
);


/* ***************************************************************************************************
The procedure generates 50,000 records for the accounts table, with the account_num padded to 5 digits.
branch_name is randomly selected from one of the six predefined branches.
balance is generated randomly, between 0 and 100,000, rounded to two decimal places.

***************************************************************************************************** */
-- Change delimiter to allow semicolons inside the procedure
drop procedure generate_accounts;

DELIMITER $$

CREATE PROCEDURE generate_accounts()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate x number of account records, note adjust this to get however many accounts you need
  WHILE i <= 150000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;


/* ***************************************************************************************************
The procedure does a timing analysis of a query only once.
***************************************************************************************************** */
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE generate_execution_time()
BEGIN
    -- Step 1: Capture the start time with microsecond precision (6)
    SET @start_time = NOW(6);

    -- Step 2: Run the query you want to measure
    SELECT count(*) FROM accounts 
    WHERE branch_name = 'Downtown'
    AND account_type = 'Savings';

    -- Step 3: Capture the end time with microsecond precision
    SET @end_time = NOW(6);

    -- Step 4: Calculate the difference in microseconds
    SELECT 
        TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
        TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS execution_time_seconds;
END$$
drop 
DELIMITER ;

/* ***************************************************************************************************
The procedure does a timing analysis of a query only once.
***************************************************************************************************** */
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE generate_report(IN sql_query VARCHAR(1000))
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total_time_microseconds BIGINT DEFAULT 0;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);

    -- Assign the input query to a user-defined variable
    SET @query_text = sql_query;

    -- Use PREPARE to dynamically execute the input query
    PREPARE task FROM @query_text;

    -- Execute the query 10 times and measure execution time
    WHILE i <= 10 DO
        -- Record the start time
        SET start_time = NOW(6);

        -- Execute the query
        EXECUTE task;

        -- Record the end time
        SET end_time = NOW(6);

        -- Add time to total time
        SET total_time_microseconds = total_time_microseconds + TIMESTAMPDIFF(MICROSECOND, start_time, end_time);

        -- Increment loop 
        SET i = i + 1;
    END WHILE;

    -- Clean up the prepared statement
    DEALLOCATE PREPARE task;

    -- Calculate and return the average execution time
    SELECT 
        total_time_microseconds / 10 AS average_execution_time_microseconds;
END$$

DELIMITER ;


-- ******************************************************************
-- execute the procedure
-- ******************************************************************
CALL generate_accounts();

-- Point Query 1: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE branch_name = "Downtown"');

-- Point Query 2: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE balance = 10000');

-- Point Query 3: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE account_type = "Savings"');

-- Range Query 1: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE branch_name = "Downtown" AND balance BETWEEN 10000 AND 5000');

-- Range Query 2: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE balance BETWEEN 10000 AND 5000');

-- Range Query 3: 
CALL generate_report('SELECT count(*) FROM accounts  WHERE account_type = "Savings" and BALANCE BETWEEN 10000 AND 5000');

select count(*) from accounts;

select * from accounts limit 10;

select branch_name, count(*)
from accounts
group by branch_name
order by branch_name;


-- ****************************************************************************************
-- This type of index will speed up queries that filter or search by the branch_name column.
-- *****************************************************************************************
CREATE INDEX idx_branch_name ON accounts (branch_name);
-- DROP INDEX idx_branch_name ON accounts;

CREATE INDEX idx_balance ON accounts (balance);
-- DROP INDEX idx_balance ON accounts;

CREATE INDEX idx_account_type ON accounts (account_type);
-- DROP INDEX idx_account_type ON accounts;

SELECT count(*) FROM accounts WHERE branch_name = 'Downtown';


-- ****************************************************************************************
-- If you frequently run queries that filter or sort by both branch_name and account_type, 
-- creating a composite index on these two columns can improve performance.
-- ****************************************************************************************
CREATE INDEX idx_branch_account_type ON accounts (branch_name, account_type);
-- DROP INDEX idx_branch_account_type ON accounts;

SELECT count(*) FROM accounts 
WHERE branch_name = 'Downtown' 
AND account_type = 'Savings';


-- ****************************************************************************************
-- The EXPLAIN statement shows how MySQL executes a query and whether it is using indexes 
-- to find rows efficiently. By running EXPLAIN before and after creating an index, you can 
-- see whether the query plan changes and whether the index is being used.
-- ****************************************************************************************
EXPLAIN SELECT count(*) FROM accounts 
WHERE branch_name = 'Downtown'
AND account_type = 'Savings';

alter table accounts drop primary key;
alter table accounts add primary key(account_num);