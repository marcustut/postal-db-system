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
-- 11. TaskAllocation
-- 12. Parcel
-- 13. Tracking
-- 14. Order

-- Settings for Oracle 
SET linesize 120
SET pagesize 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

-- Settings for PL/SQL
SET serveroutput ON -- Turning on the output for printing info from PL/SQL
-- WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK; -- Exit the script execution whenever an exception is raised
-- 
-- Startup Screen for Users
cl scr

----------------
-- 1. Address --
----------------
CREATE TABLE Address (
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
BEFORE INSERT ON Address
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
CREATE TABLE Card (
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
BEFORE INSERT ON Card
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
CREATE TABLE Customer (
	cust_id 		  NUMBER, -- PK
	name			    VARCHAR2(40)	NOT NULL,
	ic				    VARCHAR2(12)	NOT NULL,
	dob				    DATE,
	phone			    VARCHAR2(13)	NOT NULL,
	email			    VARCHAR2(45)	NOT NULL,
	created_at		VARCHAR2(10)	NOT NULL,
	updated_at		VARCHAR2(10)	NOT NULL,
	address_id		NUMBER	NOT NULL, -- FK
CONSTRAINT customer_pk PRIMARY KEY (cust_id),
CONSTRAINT customer_email_chk CHECK (REGEXP_LIKE(email, '^[a-zA-Z]\w+@(\S+)$')),
CONSTRAINT customer_phone_chk CHECK (REGEXP_LIKE(phone, '^(\+?6?01)[0|1|2|3|4|6|7|8|9]-*[0-9]{7,8}$')),
CONSTRAINT customer_address_fk
			FOREIGN KEY (address_id)
			REFERENCES Address(address_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE cust_id_seq
  START WITH 3001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER cust_id_ai_trg
BEFORE INSERT ON Customer
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
CREATE TABLE PaymentMethod (
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
           REFERENCES Customer(cust_id)
           ON DELETE CASCADE, -- if customer is deleted, this payment_method is deleted as well
CONSTRAINT payment_method_card_fk
           FOREIGN KEY (card_id)
           REFERENCES Card(card_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE payment_method_id_seq
  START WITH 4001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER payment_method_id_ai_trg
BEFORE INSERT ON PaymentMethod
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
CREATE TABLE Payment (
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
           REFERENCES PaymentMethod(payment_method_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE payment_id_seq
  START WITH 5001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER payment_id_ai_trg
BEFORE INSERT ON Payment
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
CREATE TABLE Service (
	service_id 	  VARCHAR2(6) NOT NULL,
	type 			    CHAR(10) NOT NULL,
	description 	CHAR(50) NOT NULL,
	price 			  NUMBER(5,2) NOT NULL,
CONSTRAINT service_pk PRIMARY KEY (service_id),
CONSTRAINT service_type_chk CHECK (type IN ('standard', 'express'))
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE service_id_seq
  START WITH 6001
  INCREMENT BY 1
  NOCYCLE 
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER service_id_ai_trg
BEFORE INSERT ON Service
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
CREATE TABLE Insurance (
	insurance_id 	VARCHAR2(6) NOT NULL,
	type 			    VARCHAR(10) NOT NULL,
	rate 			    NUMBER(8,2) NOT NULL,
	price 			  NUMBER(5,2) NOT NULL,
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
BEFORE INSERT ON Insurance
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
CREATE TABLE Pricing (
	pricing_id 		VARCHAR2(6) NOT NULL,
	lowest_weight 	NUMBER(5) 	NOT NULL,
	highest_weight 	NUMBER(5) 	NOT NULL,
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
BEFORE INSERT ON Pricing
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
CREATE TABLE Staff (
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
BEFORE INSERT ON Staff
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
CREATE TABLE Vehicle (
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
BEFORE INSERT ON Vehicle
FOR EACH ROW

BEGIN
    SELECT  vehicle_id_seq.NEXTVAL
    INTO    :new.vehicle_id
    FROM    dual;
END;
/

-----------------------
-- 11. TaskAllocation --
-----------------------
CREATE TABLE TaskAllocation (
	delivery_id		NUMBER,	--PK
	staff_id		NUMBER,	--PK,FK
	vehicle_id		NUMBER,	--PK,FK
	delivery_date	DATE NOT NULL,
CONSTRAINT taskallocation_pk PRIMARY KEY(delivery_id, staff_id, vehicle_id),
CONSTRAINT taskallocation_staff_fk
           FOREIGN KEY (staff_id)
           REFERENCES Staff(staff_id)
           ON DELETE CASCADE -- If the staff is deleted, this record is deleted as well
CONSTRAINT taskallocation_vehicle_fk
           FOREIGN KEY (vehicle_id)
           REFERENCES Vehicle(vehicle_id)
           ON DELETE CASCADE -- If the vehicle is deleted, this record is deleted as well		   
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE delivery_id_seq 
  START WITH 11001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER delivery_id_ai_trg
BEFORE INSERT ON TaskAllocation
FOR EACH ROW

BEGIN
    SELECT  delivery_id_seq.NEXTVAL
    INTO    :new.delivery_id
    FROM    dual;
END;
/

-----------------
-- 12. Parcel --
-----------------
CREATE TABLE Parcel (
	parcel_id			    NUMBER,		--PK
	type				    VARCHAR2(10)	NOT NULL,
	weight				    NUMBER(4) NOT NULL,
	details				    VARCHAR2(50),
	receipient_name      	VARCHAR2 NOT NULL,
	receipient_contact   	VARCHAR2 NOT NULL,
	created_at			    DATE NOT NULL,
	updated_at			    DATE,
	delivery_id			    NUMBER, -- FK
	service_id			    NUMBER, -- FK 
	insurance_id		    NUMBER, -- FK
	order_id  		       	NUMBER, -- FK
	address_id		        NUMBER, -- FK
	pricing_id		        NUMBER, -- FK
CONSTRAINT parcel_pk PRIMARY KEY(parcel_id),
CONSTRAINT parcel_type_chk CHECK (type IN ('fragile', 'flammable', 'normal')),
CONSTRAINT parcel_taskallocation_fk
           FOREIGN KEY (delivery_id)
           REFERENCES TaskAllocation(delivery_id),
CONSTRAINT parcel_service_fk
           FOREIGN KEY (service_id)
           REFERENCES Service(service_id),
CONSTRAINT parcel_insurance_fk
           FOREIGN KEY (insurance_id_id)
           REFERENCES Insurance(insurance_id),
CONSTRAINT parcel_order_fk
           FOREIGN KEY (order_id)
           REFERENCES Order(order_id),
CONSTRAINT parcel_address_fk
           FOREIGN KEY (address_id)
           REFERENCES Address(address_id),
CONSTRAINT parcel_pricing_fk
           FOREIGN KEY (pricing_id)
           REFERENCES Pricing(pricing_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE parcel_id_seq 
  START WITH 12001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER parcel_id_ai_trg
BEFORE INSERT ON Parcel
FOR EACH ROW

BEGIN
    SELECT  parcel_id_seq.NEXTVAL
    INTO    :new.parcel_id
    FROM    dual;
END;
/

------------------
-- 13. Tracking --
------------------
CREATE TABLE Tracking (
	tracking_id		NUMBER, -- PK
	status			VARCHAR2(10) NOT NULL,
	remark			VARCHAR2(50),
	created_at		DATE NOT NULL,
	parcel_id		NUMBER, -- FK
CONSTRAINT tracking_pk PRIMARY KEY (tracking_id),
CONSTRAINT tracking_status_chk CHECK (status IN ('pending', 'delivering', 'deliverd','canceled')),
CONSTRAINT tracking_parcel_fk
           FOREIGN KEY (parcel_id)
           REFERENCES Parcel(parcel_id)
           ON DELETE CASCADE -- If the parcel is deleted, this record is deleted as well
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE tracking_id_seq 
  START WITH 13001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER tracking_id_ai_trg
BEFORE INSERT ON Tracking
FOR EACH ROW

BEGIN
    SELECT  tracking_id_seq.NEXTVAL
    INTO    :new.tracking_id
    FROM    dual;
END;
/	

---------------
-- 14. Order --
---------------
CREATE TABLE Order (
    order_id        NUMBER, -- PK
    cust_id         NUMBER, -- FK
    payment_id      NUMBER, -- FK
CONSTRAINT order_pk PRIMARY KEY (order_id, cust_id, payment_id),
CONSTRAINT order_customer_fk
           FOREIGN KEY (cust_id)
           REFERENCES Customer(cust_id)
CONSTRAINT order_payment_fk
           FOREIGN KEY (payment_id)
           REFERENCES Payment(payment_id)
);

-- This sequence is to auto increment the id.
CREATE SEQUENCE order_id_seq 
  START WITH 14001
  INCREMENT BY 1
  NOCYCLE
  CACHE 20;

-- Below trigger is used to auto-increment the id with the use of sequence
CREATE OR REPLACE TRIGGER order_id_ai_trg
BEFORE INSERT ON Order
FOR EACH ROW

BEGIN
    SELECT  order_id_seq.NEXTVAL
    INTO    :new.order_id
    FROM    dual;
END;
/	
