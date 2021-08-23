--------------------------------------------------------------------------------------
-- Name         : Online Postal Delivery System 
-- Author       : Lee Kai Yang, Wong Wai Yi, Tang Xiao Zu
-- Version      : 1.0
-- Last Updated : 16/07/2021
-- Description  : This database is used for carrying out Online Postal Delivery. 
--------------------------------------------------------------------------------------

-- NOTE: Do not run this file, it has not been tested yet

-- This file creates the tables for the payment persective of the system:
-- 1. Address
-- 2. Card
-- 3. Customer
-- 4. PaymentMethod
-- 5. Payment
-- 6. Service
-- 7. Insurance
-- 8. Pricing
-- 9. Staff
-- 10. Vehicle
-- 11. Delivery
-- 12. Order
-- 13. Parcel
-- 14. Tracking

-- Settings for Oracle 
SET linesize 120
SET pagesize 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

-- Settings for PL/SQL
SET serveroutput ON -- Turning on the output for printing info from PL/SQL
SET VERIFY OFF -- Turn off the verification for PL/SQL
-- WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK; -- Exit the script execution whenever an exception is raised

-- Startup Screen for Users
cl scr
PROMPT Welcome to DBMS of Online Postal Delivery System
PROMPT

----------------------------
-- SECTION 1: DROP TABLES --
----------------------------

-- Prompt Users whether to drop tables
ACCEPT dropTable CHAR PROMPT 'Do you want to drop the tables? (Y/N): '

-- PL/SQL 1
DECLARE
    type tablesarray IS VARRAY(14) OF VARCHAR(30);
    tables tablesarray;
    total integer;
    nCount integer;
    successCount integer;
    dropTable char;
BEGIN
    -- Assigning user input
    dropTable := '&dropTable';

    -- Assigning tables names to the array
    tables := tablesarray('Address', 'Card', 'Customer', 'PaymentMethod', 'Payment', 'Service', 'Insurance', 'Pricing', 'Staff', 'Vehicle', 'Delivery', 'Order', 'Parcel', 'Tracking');
    total := tables.count;
    successCount := 0;

    -- Enabling DBMS_OUTPUT package
    DBMS_OUTPUT.ENABLE;

    -- If User input 'Y' or 'y' then drop tables
    IF UPPER(dropTable) = 'Y' THEN
        -- Looping through the array
        FOR i in REVERSE 1 .. total LOOP -- Droping tables from the back
            SELECT COUNT(*) INTO nCount FROM user_tables WHERE LOWER(table_name) LIKE LOWER(tables(i)); -- Put the count of table into nCount

            IF (nCount > 0) THEN -- If nCount > 0 then table exist
                EXECUTE IMMEDIATE 'DROP TABLE "' || tables(i) || '"'; -- Drop the table
                DBMS_OUTPUT.PUT_LINE('[SUCCESS] (' || tables(i) || ') is dropped.');
                successCount := successCount + 1;
            END IF;
        END LOOP;

        EXECUTE IMMEDIATE 'DROP SEQUENCE address_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE card_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE cust_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE payment_method_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE payment_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE service_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE insurance_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE pricing_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE staff_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE vehicle_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE delivery_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE order_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE parcel_id_seq';
        EXECUTE IMMEDIATE 'DROP SEQUENCE tracking_id_seq';
    END IF;

    -- Printing the summary
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE(successCount || '/' || total || ' tables are successfully dropped. (' || round((successCount/total)*100, 2) || '%)');
    DBMS_OUTPUT.NEW_LINE();
END;
/

ACCEPT continue CHAR PROMPT 'Continue? (Y/N): '

-- PL/SQL 2
DECLARE
    continue char;
BEGIN
    -- Assign user input to variable
    continue := '&continue';
    
    IF UPPER(continue) = 'Y' THEN
        -- Show Users tables to be created
        DBMS_OUTPUT.PUT_LINE(chr(13));
        DBMS_OUTPUT.PUT_LINE('Below are the tables that will be created');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('1. Address');
        DBMS_OUTPUT.PUT_LINE('2. Card');
        DBMS_OUTPUT.PUT_LINE('3. Customer');
        DBMS_OUTPUT.PUT_LINE('4. PaymentMethod');
        DBMS_OUTPUT.PUT_LINE('5. Payment');
        DBMS_OUTPUT.PUT_LINE('6. Service');
        DBMS_OUTPUT.PUT_LINE('7. Insurance');
        DBMS_OUTPUT.PUT_LINE('8. Pricing');
        DBMS_OUTPUT.PUT_LINE('9. Staff');
        DBMS_OUTPUT.PUT_LINE('10. Vehicle');
        DBMS_OUTPUT.PUT_LINE('11. Delivery');
        DBMS_OUTPUT.PUT_LINE('12. Order');
        DBMS_OUTPUT.PUT_LINE('13. Parcel');
        DBMS_OUTPUT.PUT_LINE('14. Tracking');
    ELSE
        -- Exit if user doesn't input 'Y' or 'y'
        DBMS_OUTPUT.PUT_LINE('Okay, Good Bye!');
        RAISE_APPLICATION_ERROR(-20000, 'User Exited');
    END IF;
END;
/

------------------------------
-- SECTION 2: CREATE TABLES --
------------------------------

-- Prompt Users whether create tables or not
ACCEPT createTable CHAR PROMPT 'Do you want to create the tables? (Y/N): '

-- PL/SQL 3
DECLARE
    type tablesarray IS VARRAY(14) OF VARCHAR(30);
    tables tablesarray;
    total integer;
    nCount integer;
    successCount integer;
    createTable char;
BEGIN
    -- Assigning user input to variable
    createTable := '&createTable';

    -- If user input is not 'Y' or 'y' then exit
    IF UPPER(createTable) != 'Y' THEN
        DBMS_OUTPUT.PUT_LINE('No tables is created.');
        DBMS_OUTPUT.PUT_LINE('Okay, Good Bye!');
        RAISE_APPLICATION_ERROR(-20000, 'User Exited');
    END IF;
END;
/

----------------
-- 1. Address --
----------------
CREATE TABLE "Address" (
  address_id          NUMBER, -- PK
  country             VARCHAR2(60) NOT NULL,
  state               VARCHAR2(60) NOT NULL,
  city                VARCHAR2(60) NOT NULL,
  line1               VARCHAR2(255) NOT NULL,
  line2               VARCHAR2(255),
  postal_code         CHAR(5) NOT NULL,
  created_at          DATE DEFAULT SYSDATE NOT NULL,
  updated_at          DATE DEFAULT SYSDATE NOT NULL,
CONSTRAINT address_pk PRIMARY KEY (address_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE address_id_seq
  START WITH 1001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER address_id_ai_trg
BEFORE INSERT ON "Address"
FOR EACH ROW

BEGIN
    SELECT  address_id_seq.NEXTVAL
    INTO    :new.address_id
    FROM    dual;
END;
/

-------------
-- 2. Card --
-------------
CREATE TABLE "Card" (
  card_id             NUMBER, -- PK
  brand               VARCHAR2(25) NOT NULL,
  name                VARCHAR2(100) NOT NULL,
  exp_month           NUMBER(2) NOT NULL,
  exp_year            NUMBER(4) NOT NULL,
  last4               CHAR(4) NOT NULL,
  created_at          DATE DEFAULT SYSDATE NOT NULL,
  updated_at          DATE DEFAULT SYSDATE NOT NULL,
CONSTRAINT card_pk PRIMARY KEY (card_id),
CONSTRAINT card_brand_chk CHECK (brand IN ('visa', 'unionpay', 'amex', 'mastercard'))
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE card_id_seq
  START WITH 2001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER card_id_ai_trg
BEFORE INSERT ON "Card"
FOR EACH ROW

BEGIN
    SELECT  card_id_seq.NEXTVAL
    INTO    :new.card_id
    FROM    dual;
END;
/

-----------------
-- 3. Customer --
-----------------
CREATE TABLE "Customer" (
	cust_id 		 NUMBER, -- PK
	name			 VARCHAR2(40)	 NOT NULL,
	ic				 VARCHAR2(12)	 NOT NULL,
	dob				 DATE,
	phone			 VARCHAR2(13)	 NOT NULL,
	email			 VARCHAR2(45)	 NOT NULL,
	created_at		 DATE DEFAULT SYSDATE NOT NULL,
	updated_at		 DATE DEFAULT SYSDATE NOT NULL,
	address_id		 NUMBER NOT NULL, -- FK
CONSTRAINT customer_pk PRIMARY KEY (cust_id),
CONSTRAINT customer_email_chk CHECK (REGEXP_LIKE(email, '^[a-zA-Z]\w+@(\S+)$')),
CONSTRAINT customer_phone_chk CHECK (REGEXP_LIKE(phone, '^(\+?6?01)[0|1|2|3|4|6|7|8|9]-*[0-9]{7,8}$')),
CONSTRAINT customer_address_fk
			FOREIGN KEY (address_id)
			REFERENCES "Address"(address_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE cust_id_seq
  START WITH 3001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER cust_id_ai_trg
BEFORE INSERT ON "Customer"
FOR EACH ROW

BEGIN
    SELECT  cust_id_seq.NEXTVAL
    INTO    :new.cust_id
    FROM    dual;
END;
/

----------------------
-- 4. PaymentMethod --
----------------------
CREATE TABLE "PaymentMethod" (
  payment_method_id   NUMBER, -- PK
  type                VARCHAR2(25) NOT NULL,
  created_at          DATE DEFAULT SYSDATE NOT NULL,
  updated_at          DATE DEFAULT SYSDATE NOT NULL,
  cust_id             NUMBER NOT NULL, -- FK
  card_id             NUMBER, -- FK
CONSTRAINT payment_method_pk PRIMARY KEY (payment_method_id),
CONSTRAINT payment_method_type_check CHECK (type IN ('fpx', 'card', 'grabpay', 'tng')),
CONSTRAINT payment_method_customer_fk
           FOREIGN KEY (cust_id)
           REFERENCES "Customer"(cust_id)
           ON DELETE CASCADE, -- if customer is deleted, this payment_method is deleted as well
CONSTRAINT payment_method_card_fk
           FOREIGN KEY (card_id)
           REFERENCES "Card"(card_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE payment_method_id_seq
  START WITH 4001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER payment_method_id_ai_trg
BEFORE INSERT ON "PaymentMethod"
FOR EACH ROW

BEGIN
    SELECT  payment_method_id_seq.NEXTVAL
    INTO    :new.payment_method_id
    FROM    dual;
END;
/

----------------
-- 5. Payment --
----------------
CREATE TABLE "Payment" (
  payment_id          NUMBER, -- PK
  amount              NUMBER NOT NULL,
  currency            CHAR(3) NOT NULL,
  description         VARCHAR2(255),
  status              VARCHAR2(25) NOT NULL,
  tax                 NUMBER NOT NULL,
  canceled_at         DATE,
  succeeded_at        DATE,
  created_at          DATE DEFAULT SYSDATE NOT NULL,
  updated_at          DATE DEFAULT SYSDATE NOT NULL,
  payment_method_id   NUMBER, -- FK
CONSTRAINT payment_pk PRIMARY KEY (payment_id),
CONSTRAINT payment_currency_check CHECK (currency IN ('myr', 'sgd', 'usd')),
CONSTRAINT payment_status_check CHECK (status IN ('canceled', 'processing', 'succeeded', 'failed')),
CONSTRAINT payment_payment_method_fk
           FOREIGN KEY (payment_method_id)
           REFERENCES "PaymentMethod"(payment_method_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE payment_id_seq
  START WITH 5001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER payment_id_ai_trg
BEFORE INSERT ON "Payment"
FOR EACH ROW

BEGIN
    SELECT  payment_id_seq.NEXTVAL
    INTO    :new.payment_id
    FROM    dual;
END;
/

------------------
-- 6. Service --
------------------
CREATE TABLE "Service" (
	service_id 		NUMBER NOT NULL,
	name 			CHAR(10) NOT NULL,
	description 	CHAR(50) NOT NULL,
	price 			NUMBER(5,2) NOT NULL,
CONSTRAINT service_pk PRIMARY KEY (service_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE service_id_seq
  START WITH 6001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER service_id_ai_trg
BEFORE INSERT ON "Service"
FOR EACH ROW

BEGIN
    SELECT  service_id_seq.NEXTVAL
    INTO    :new.service_id
    FROM    dual;
END;
/

-------------------
-- 7. Insurance --
-------------------
CREATE TABLE "Insurance" (
	insurance_id 	NUMBER NOT NULL,
	type 			VARCHAR(10) NOT NULL,
	rate 			NUMBER(8,2) NOT NULL,
	price 			NUMBER(5,2) NOT NULL,
CONSTRAINT insurance_pk PRIMARY KEY (insurance_id),
CONSTRAINT insurance_type_check CHECK (type IN ('bronze', 'silver', 'gold', 'platinum'))
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE insurance_id_seq
  START WITH 7001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER insurance_id_ai_trg
BEFORE INSERT ON "Insurance"
FOR EACH ROW

BEGIN
    SELECT  insurance_id_seq.NEXTVAL
    INTO    :new.insurance_id
    FROM    dual;
END;
/

-----------------
-- 8. Pricing --
-----------------
CREATE TABLE "Pricing" (
	pricing_id 		NUMBER NOT NULL,
	lowest_weight 	NUMBER(5,2) NOT NULL,
	highest_weight 	NUMBER(5,2)	NOT NULL,
	east_price 		NUMBER(5,2) NOT NULL,
	west_price 		NUMBER(5,2) NOT NULL,
CONSTRAINT pricing_pk PRIMARY KEY (pricing_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE pricing_id_seq
  START WITH 8001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER pricing_id_ai_trg
BEFORE INSERT ON "Pricing"
FOR EACH ROW

BEGIN
    SELECT  pricing_id_seq.NEXTVAL
    INTO    :new.pricing_id
    FROM    dual;
END;
/

-----------------
--- 9. Staff ---
-----------------
CREATE TABLE "Staff" (
	staff_id		 NUMBER, -- PK
	staff_name		 VARCHAR2(40)	 NOT NULL,
	email 			 VARCHAR2(45) 	 NOT NULL,
	phone			 VARCHAR2(13)	 NOT NULL,
	branch 			 VARCHAR2(30)	 NOT NULL,
CONSTRAINT staff_pk PRIMARY KEY (staff_id),
CONSTRAINT staff_email_chk CHECK (REGEXP_LIKE(email, '^[a-zA-Z]\w+@(\S+)$')),
CONSTRAINT staff_phone_chk CHECK (REGEXP_LIKE(phone, '^(\+?6?01)[0|1|2|3|4|6|7|8|9]-*[0-9]{7,8}$'))
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE staff_id_seq 
  START WITH 9001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER staff_id_ai_trg
BEFORE INSERT ON "Staff"
FOR EACH ROW

BEGIN
    SELECT  staff_id_seq.NEXTVAL
    INTO    :new.staff_id
    FROM    dual;
END;
/

-----------------
-- 10. Vehicle --
-----------------
CREATE TABLE "Vehicle" (
	vehicle_id				 NUMBER, -- PK
	car_plate_no			 VARCHAR2(7)	 NOT NULL,
	transportation_type 	 VARCHAR2(10) 	 NOT NULL,	
CONSTRAINT vehicle_pk PRIMARY KEY (vehicle_id),
CONSTRAINT vehicle_transportation_type_chk CHECK (transportation_type IN ('Motorcycle', 'Van', 'Car'))
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE vehicle_id_seq 
  START WITH 10001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER vehicle_id_ai_trg
BEFORE INSERT ON "Vehicle"
FOR EACH ROW

BEGIN
    SELECT  vehicle_id_seq.NEXTVAL
    INTO    :new.vehicle_id
    FROM    dual;
END;
/

-------------------
-- 11. Delivery --
-------------------
CREATE TABLE "Delivery" (
	delivery_id		 NUMBER,	--PK
	staff_id		 NUMBER,	--PK,FK
	vehicle_id		 NUMBER,	--PK,FK
	delivery_date	 DATE  NOT NULL,
CONSTRAINT delivery_delivery_pk PRIMARY KEY(delivery_id),
CONSTRAINT delivery_delivery_staff_fk
           FOREIGN KEY (staff_id)
           REFERENCES "Staff"(staff_id),         
CONSTRAINT delivery_delivery_vehicle_fk
           FOREIGN KEY (vehicle_id)
           REFERENCES "Vehicle"(vehicle_id)	   
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE delivery_id_seq 
  START WITH 11001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER delivery_id_ai_trg
BEFORE INSERT ON "Delivery"
FOR EACH ROW

BEGIN
    SELECT  delivery_id_seq.NEXTVAL
    INTO    :new.delivery_id
    FROM    dual;
END;
/

---------------
-- 12. Order --
---------------
CREATE TABLE "Order" (
    order_id        NUMBER, -- PK
    cust_id         NUMBER, -- FK
    payment_id      NUMBER, -- FK
CONSTRAINT order_pk PRIMARY KEY (order_id),
CONSTRAINT order_customer_fk
           FOREIGN KEY (cust_id)
           REFERENCES "Customer"(cust_id),
CONSTRAINT order_payment_fk
           FOREIGN KEY (payment_id)
           REFERENCES "Payment"(payment_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE order_id_seq 
  START WITH 12001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER order_id_ai_trg
BEFORE INSERT ON "Order"
FOR EACH ROW

BEGIN
    SELECT  order_id_seq.NEXTVAL
    INTO    :new.order_id
    FROM    dual;
END;
/	
-----------------
-- 13. Parcel --
-----------------
CREATE TABLE "Parcel" (
	parcel_id			    NUMBER,		--PK
	"type"				    VARCHAR2(10)	NOT NULL,
	weight				    NUMBER(4) NOT NULL,
	details				    VARCHAR2(50),
	receipient_name      	VARCHAR2(50) NOT NULL,
	receipient_contact   	VARCHAR2(15) NOT NULL,
	created_at			    DATE DEFAULT SYSDATE NOT NULL,
	updated_at			    DATE DEFAULT SYSDATE,
	delivery_id			    NUMBER, -- FK
	service_id			    NUMBER, -- FK 
	insurance_id		    NUMBER, -- FK
	order_id  		       	NUMBER, -- FK
	address_id		        NUMBER, -- FK
	pricing_id		        NUMBER, -- FK
CONSTRAINT parcel_pk PRIMARY KEY(parcel_id),
CONSTRAINT parcel_type_chk CHECK ("type" IN ('fragile', 'flammable', 'normal')),
CONSTRAINT parcel_delivery_fk
           FOREIGN KEY (delivery_id)
           REFERENCES "Delivery"(delivery_id),
CONSTRAINT parcel_service_fk
           FOREIGN KEY (service_id)
           REFERENCES "Service"(service_id),
CONSTRAINT parcel_insurance_fk
           FOREIGN KEY (insurance_id)
           REFERENCES "Insurance"(insurance_id),
CONSTRAINT parcel_order_fk
           FOREIGN KEY (order_id)
           REFERENCES "Order"(order_id),
CONSTRAINT parcel_address_fk
           FOREIGN KEY (address_id)
           REFERENCES "Address"(address_id),
CONSTRAINT parcel_pricing_fk
           FOREIGN KEY (pricing_id)
           REFERENCES "Pricing"(pricing_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE parcel_id_seq 
  START WITH 13001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER parcel_id_ai_trg
BEFORE INSERT ON "Parcel"
FOR EACH ROW

BEGIN
    SELECT  parcel_id_seq.NEXTVAL
    INTO    :new.parcel_id
    FROM    dual;
END;
/

------------------
-- 14. Tracking --
------------------
CREATE TABLE "Tracking" (
	tracking_id		 NUMBER, -- PK
	status			 VARCHAR2(10) NOT NULL,
	remark			 VARCHAR2(50),
	created_at		 DATE DEFAULT SYSDATE NOT NULL,
	parcel_id		 NUMBER, -- FK
CONSTRAINT tracking_pk PRIMARY KEY (tracking_id),
CONSTRAINT tracking_status_chk CHECK (status IN ('pending', 'delivering', 'delivered','canceled')),
CONSTRAINT tracking_parcel_fk
           FOREIGN KEY (parcel_id)
           REFERENCES "Parcel"(parcel_id)
           ON DELETE CASCADE -- If the parcel is deleted, this record is deleted as well
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE tracking_id_seq 
  START WITH 14001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER tracking_id_ai_trg
BEFORE INSERT ON "Tracking"
FOR EACH ROW

BEGIN
    SELECT  tracking_id_seq.NEXTVAL
    INTO    :new.tracking_id
    FROM    dual;
END;
/	

-----------------------------
-- SECTION 3: CHECK TABLES --
-----------------------------
DECLARE
    type tablesarray IS VARRAY(14) OF VARCHAR(30);
    tables tablesarray;
    total integer;
    nCount integer;
    successCount integer;
BEGIN
    -- Assigning tables names to the array
    tables := tablesarray('Address', 'Card', 'Customer', 'PaymentMethod', 'Payment', 'Service', 'Insurance', 'Pricing', 'Staff', 'Vehicle', 'Delivery', 'Order', 'Parcel', 'Tracking');
    total := tables.count;
    successCount := 0;

    -- Enabling DBMS_OUTPUT package
    DBMS_OUTPUT.ENABLE;

    -- Printing info screen
    DBMS_OUTPUT.PUT_LINE('Online Postal Delivery System');
    DBMS_OUTPUT.PUT_LINE(chr(13));

    -- Looping through the array
    FOR i in 1 .. total LOOP
        SELECT COUNT(*) INTO nCount FROM user_tables WHERE LOWER(table_name) LIKE LOWER(tables(i)); -- Put the count of table into nCount

        IF (nCount <= 0) THEN -- If nCount <= 0 then table doesn't exist
            DBMS_OUTPUT.PUT_LINE('[FAILED] (' || tables(i) || ') is not created.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('[SUCCESS] (' || tables(i) || ') is created.');
            successCount := successCount + 1;
        END IF;
    END LOOP;

    -- Printing the summary
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE(successCount || '/' || total || ' tables are successfully created. (' || round((successCount/total)*100, 2) || '%)');
END;
/
