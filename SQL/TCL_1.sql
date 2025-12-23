CREATE TABLE BankAccounts (
    AccountID INT PRIMARY KEY,
    HolderName VARCHAR(50),
    Balance INT
);

INSERT INTO BankAccounts VALUES
(1, 'John', 1000),
(2, 'Mary', 1500);



-- Dirty read
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;

SELECT * FROM dbo.BankAccounts WHERE AccountID = 1;  -- see current balance
-- keep this transaction open

BEGIN TRANSACTION;
UPDATE dbo.BankAccounts SET Balance = 9999 WHERE AccountID = 1;
-- do not commit yet


-- commmits
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- BEGIN TRANSACTION;
SELECT * FROM dbo.BankAccounts WHERE AccountID = 1;

BEGIN TRANSACTION;
UPDATE dbo.BankAccounts SET Balance = 1000 WHERE AccountID = 1;
-- Do not commit yet


SELECT name, snapshot_isolation_state_desc, is_read_committed_snapshot_on
FROM sys.databases
WHERE name = DB_NAME();

