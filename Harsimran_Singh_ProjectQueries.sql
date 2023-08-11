
-- ============================== CREATING TABLES =====================================


--------------------------- ADMIN TABLE -------------------------------

CREATE TABLE admin (
    id INT(20) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(150),
    role VARCHAR(50),    
    password VARCHAR(100)
);


-------------------------- CLIENT TABLE --------------------------------

CREATE TABLE client(
	id INT(20) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(150),
    address VARCHAR(255),
    password VARCHAR(100)
);



-------------------------- LOAN TABLE ---------------------------------

CREATE TABLE loan(
	id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    account_number INT,
    loan_amount DECIMAL(11,2),
    interest_rate DECIMAL(3,2),
    balance DECIMAL(11,2),
    due_date date,
    created_at timestamp NOT NULL DEFAULT current_timestamp(),
    
	CONSTRAINT loan_client_id_fk FOREIGN KEY (client_id)
    REFERENCES client(id)
    ON DELETE SET NULL
);


-------------------------- SECURED CARD TABLE -----------------------------


CREATE TABLE secured_card(
	  id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    account_number INT,
    card_number BIGINT,
    credit_limit DECIMAL(11,2),
    current_balance DECIMAL(11,2),
    due_date date,
    created_at timestamp NOT NULL DEFAULT current_timestamp(),
    
	CONSTRAINT securedCard_client_id_fk FOREIGN KEY (client_id)
    REFERENCES client(id)
    ON DELETE SET NULL
);





-- ================================= TRIGGERS ====================================


-- ================ LOAN Log table ================ --

CREATE TABLE loan_balance_update_log (
  logId INT PRIMARY KEY AUTO_INCREMENT,
  action  VARCHAR(255),
  account_id INT,
  balance_old VARCHAR(255),
  balance_new VARCHAR(255),
  timestamp TIMESTAMP,
    
	CONSTRAINT loan_log_id_fk FOREIGN KEY (account_id)
    REFERENCES loan(id)
    ON DELETE SET NULL
);


----------------TRIGGER--------------------

DELIMITER //
CREATE TRIGGER loan_balance_update_log_trigger
  AFTER UPDATE ON loan
  FOR EACH ROW
  BEGIN
    INSERT INTO loan_balance_update_log 
      (action, account_id, balance_new, balance_old, timestamp)
    VALUES
      ('update', NEW.id, NEW.balance, OLD.balance, NOW());
    END; //
DELIMITER ;





--============== Secured Card Trigger ================--

CREATE TABLE securedCard_balance_update_log (
  logId INT PRIMARY KEY AUTO_INCREMENT,
  action  VARCHAR(255),
  account_id INT,
  balance_old VARCHAR(255),
  balance_new VARCHAR(255),
  timestamp TIMESTAMP,
    
	CONSTRAINT securedCard_log_id_fk FOREIGN KEY (account_id)
    REFERENCES secured_card(id)
    ON DELETE SET NULL
);


-----------------TRIGGER-------------------

DELIMITER //
CREATE TRIGGER securedCard_balance_update_log_trigger 
  AFTER UPDATE ON secured_card
  FOR EACH ROW
  BEGIN
    INSERT INTO securedCard_balance_update_log 
      (action, account_id, balance_new, balance_old, timestamp)
    VALUES
      ('update', NEW.id, NEW.current_balance, OLD.current_balance, NOW());
    END; //
DELIMITER ;










--===================== Procedures ========================--


-- Updating balance of a secured card account

DELIMITER //
CREATE PROCEDURE securedCard_updateBalance(
  account_id INT,
  new_balance VARCHAR(255)
)
BEGIN
  UPDATE secured_card SET current_balance = new_balance WHERE id = account_id;
END;
//
DELIMITER ;


-- Updating balance of loan account --


DELIMITER //
CREATE PROCEDURE loan_updateBalance( 
    account_id INT, 
    new_balance VARCHAR(255) 
) 
BEGIN 
  UPDATE loan SET balance = new_balance WHERE id = account_id; 
END;
//
DELIMITER ;






-- ===================== VIEWS ===================--

--  passed due for SECURED CARD ACCOUNTS

CREATE VIEW secured_card_accounts_passed_due AS
SELECT * FROM secured_card
WHERE due_date < NOW();

CREATE VIEW display_secured_accounts_status AS 
SELECT account_number, credit_limit, current_balance, credit_limit - current_balance AS credit_remaining, card_number FROM secured_card 

--  passed due for SECURED CARD ACCOUNTS

CREATE VIEW loan_accounts_passed_due AS
SELECT * FROM loan
WHERE due_date < NOW();

CREATE VIEW display_loan_accounts_status AS 
SELECT account_number, loan_amount, balance, CAST((balance+((interest_rate/100)*loan_amount)) AS decimal(11,2)) AS You_Owe, due_date FROM loan; 



