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
-- 3. BillingDetails
-- 4. PaymentMethod
-- 5. Payment
-- 6. Customer
-- 7. Staff
-- 8. Vehicle
-- 9. TaskAllocation
-- 10. Parcel
-- 11. Tracking

-- Only uncomment the below if needed
-- -- Settings for Oracle 
-- SET linesize 120
-- SET pagesize 100
-- ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';
-- 
-- -- Settings for PL/SQL
-- SET serveroutput ON -- Turning on the output for printing info from PL/SQL
-- WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK; -- Exit the script execution whenever an exception is raised
-- 
-- -- Startup Screen for Users
-- cl scr

----------------
-- 1. Address --
----------------
CREATE TABLE Address (
  address_id          VARCHAR2,
  country             VARCHAR2 NOT NULL,
  state               VARCHAR2 NOT NULL,
  city                VARCHAR2 NOT NULL,
  line1               VARCHAR2 NOT NULL,
  line2               VARCHAR2,
  postal_code         CHAR(5) NOT NULL,
  created_at          DATE NOT NULL,
  updated_at          DATE NOT NULL,
CONSTRAINT address_pk PRIMARY KEY (address_id)
);

-------------
-- 2. Card --
-------------
CREATE TABLE Card (
  card_id             VARCHAR2,
  brand               VARCHAR2 NOT NULL,
  name                VARCHAR2 NOT NULL,
  exp_month           NUMBER NOT NULL,
  exp_year            NUMBER NOT NULL,
  last4               NUMBER NOT NULL,
  created_at          DATE NOT NULL,
  updated_at          DATE NOT NULL,
CONSTRAINT card_pk PRIMARY KEY (card_id),
CONSTRAINT card_brand_check CHECK (brand IN ('visa', 'unionpay', 'amex', 'mastercard'))
);

-----------------------
-- 3. BillingDetails --
-----------------------
CREATE TABLE BillingDetails (
  billing_details_id  VARCHAR2,
  name                VARCHAR2 NOT NULL,
  email               VARCHAR2 NOT NULL,
  phone               VARCHAR2 NOT NULL,
  created_at          DATE NOT NULL,
  updated_at          DATE NOT NULL,
  address_id          VARCHAR2,
CONSTRAINT billing_details_pk PRIMARY KEY (billing_details_id),
CONSTRAINT billing_details_address_fk
           FOREIGN KEY (address_id)
           REFERENCES Address(address_id)
           ON DELETE CASCADE -- if address is deleted, this billing_detail is deleted as well
);

----------------------
-- 4. PaymentMethod --
----------------------
CREATE TABLE PaymentMethod (
  payment_method_id   VARCHAR2,
  type                VARCHAR2 NOT NULL,
  created_at          DATE NOT NULL,
  updated_at          DATE NOT NULL,
  cust_id             VARCHAR2,
  card_id             VARCHAR2,
  billing_details_id  VARCHAR2,
CONSTRAINT payment_method_pk PRIMARY KEY (payment_method_id),
CONSTRAINT payment_method_type_check CHECK (type IN ('fpx', 'card', 'grabpay', 'tng')),
CONSTRAINT payment_method_customer_fk
           FOREIGN KEY (cust_id)
           REFERENCES Customer(cust_id)
           ON DELETE CASCADE, -- if customer is deleted, this payment_method is deleted as well
CONSTRAINT payment_method_card_fk
           FOREIGN KEY (card_id)
           REFERENCES Card(card_id),
CONSTRAINT payment_method_billing_details_fk
           FOREIGN KEY (billing_details_id)
           REFERENCES BillingDetails(billing_details_id)
           ON DELETE CASCADE -- if billing_details is deleted, this payment_method is deleted as well
);

----------------
-- 5. Payment --
----------------
CREATE TABLE Payment(
  payment_id          VARCHAR2,
  amount              NUMBER NOT NULL,
  currency            CHAR(3) NOT NULL,
  description         VARCHAR2,
  status              VARCHAR2 NOT NULL,
  tax                 NUMBER NOT NULL,
  canceled_at         DATE,
  succeeded_at        DATE,
  created_at          DATE NOT NULL,
  updated_at          DATE NOT NULL,
  payment_method_id  VARCHAR2,
CONSTRAINT payment_pk PRIMARY KEY (payment_id),
CONSTRAINT payment_currency_check CHECK (currency IN ('myr', 'sgd', 'usd')),
CONSTRAINT payment_status_check CHECK (status IN ('canceled', 'processing', 'succeeded', 'failed')),
CONSTRAINT payment_payment_method_fk
           FOREIGN KEY (payment_method_id)
           REFERENCES PaymentMethod(payment_method_id)
);

-----------------
-- 6. Customer --
-----------------
CREATE TABLE Customer(
	cust_id 		VARCHAR2(6)		NOT NULL,
	name			VARCHAR2(40)	NOT NULL,
	ic				VARCHAR2(12)	NOT NULL,
	dob				DATE,
	phone			VARCHAR2(13)	NOT NULL,
	email			VARCHAR2(45)	NOT NULL,
	created_at		VARCHAR2(10)	NOT NULL,
	updated_at		VARCHAR2(10)	NOT NULL,
	address_id		VARCHAR2(100)	NOT NULL,
CONSTRAINT customer_pk PRIMARY KEY (cust_id),
CONSTRAINT chk_email (REGEXP_LIKE(email, '^[0-9a-zA-Z]\w+@(\s+)$'))
CONSTRAINT customer_address_fk
			FOREIGN KEY (address_id)
			REFERENCES Address(address_id)
);

-----------------
--- 7. Staff ---
-----------------
CREATE TABLE Staff(
	staff_id		NUMBER, --PK
	staff_name		VARCHAR2	NOT NULL,
	email 			VARCHAR2 	NOT NULL,
	phone			VARCHAR2	NOT NULL,
	branch 			VARCHAR2	NOT NULL,
CONSTRAINT staff_pk PRIMARY KEY (staff_id),
CONSTRAINT check_semail (REGEXP_LIKE(email, '^[0-9a-zA-Z]\w+@(\s+)$'))
);

-- Following code is to auto-increment staff_id

-- This sequence is to auto increment the id.
CREATE SEQUENCE staff_id_seq 
				INCREMENT BY 1
				START WITH 7001
				NOCYCLE
				CACHE 20;

-- Below code is to trigger sequence to increment by 1 when CREATE or REPLACE is detected.
CREATE OR REPLACE TRIGGER staff_id_bir
BEFORE INSERT ON Staff
FOR EACH ROW

BEGIN
    SELECT  staff_id_seq.NEXTVAL
    INTO    :new.staff_id
    FROM    dual;
END;
/

-----------------
-- 8. Vehicle --
-----------------
CREATE TABLE Vehicle(
	vehicle_id				NUMBER, --PK
	car_plate_no			VARCHAR2	NOT NULL,
	transportation_type 	VARCHAR2 	NOT NULL,	
CONSTRAINT vehicle_pk PRIMARY KEY (vehicle_id),
CONSTRAINT vehicle_type_check CHECK (transportation_type IN ('motorcycle', 'van', 'airplane'))
);
-- Following code is to auto-increment vehicle_id

-- This sequence is to auto increment the id.
CREATE SEQUENCE vehicle_id_seq 
				INCREMENT BY 1
				START WITH 8001
				NOCYCLE
				CACHE 20;

-- Below code is to trigger sequence to increment by 1 when CREATE or REPLACE is detected.
CREATE OR REPLACE TRIGGER vehicle_id_bir
BEFORE INSERT ON Vehicle
FOR EACH ROW

BEGIN
    SELECT  vehicle_id_seq.NEXTVAL
    INTO    :new.vehicle_id
    FROM    dual;
END;
/

-----------------------
-- 9. TaskAllocation --
-----------------------
CREATE TABLE TaskAllocation(
	delivery_id		NUMBER;		--PK
	staff_id		NUMBER,	--PK,FK
	vehicle_id		NUMBER,	--PK,FK
	delivery_date	DATE	NOT NULL,
	
PRIMARY KEY(delivery_id, staff_id, vehicle_id),
CONSTRAINT chk_identifications_staff
           FOREIGN KEY (staff_id)
           REFERENCES Staff(staff_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
CONSTRAINT chk_identifications_vehicle
           FOREIGN KEY (vehicle_id)
           REFERENCES Vehicle(vehicle_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well		   
);
-- Following code is to auto-increment delivery_id

-- This sequence is to auto increment the id.
CREATE SEQUENCE delivery_id_seq 
				INCREMENT BY 1
				START WITH 9001
				NOCYCLE
				CACHE 20;

-- Below code is to trigger sequence to increment by 1 when CREATE or REPLACE is detected.
CREATE OR REPLACE TRIGGER delivery_id_bir
BEFORE INSERT ON TaskAllocation
FOR EACH ROW

BEGIN
    SELECT  delivery_id_seq.NEXTVAL
    INTO    :new.delivery_id
    FROM    dual;
END;
/

-----------------
-- 10. Parcel --
-----------------
CREATE TABLE Parcel(
	parcel_id			NUMBER,		--PK
	type				VARCHAR2	NOT NULL,
	weight				NUMBER(4)	NOT NULL,
	details				VARCHAR2,
	receipient_name		VARCHAR2	NOT NULL,
	receipient_contact  VARCHAR2	NOT NULL,
	created_at			DATE		NOT NULL,
	updated_at			DATE,
	delivery_id			NUMBER,
	services_id			NUMBER,
	insurance_id		NUMBER,
	order_id			NUMBER,
	address_id			NUMBER,
	pricing_id			NUMBER,
PRIMARY KEY(delivery_id, staff_id, vehicle_id),
CONSTRAINT parcel_type_check CHECK (type IN ('fragile', 'flammable', 'normal'))
CONSTRAINT chk_identifications_delivery
           FOREIGN KEY (delivery_id)
           REFERENCES TaskAllocation(delivery_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
CONSTRAINT chk_identifications_services
           FOREIGN KEY (services_id)
           REFERENCES Services(services_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
CONSTRAINT chk_identifications_insurance
           FOREIGN KEY (insurance_id_id)
           REFERENCES Insurance(insurance_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
CONSTRAINT chk_identifications_order
           FOREIGN KEY (order_id)
           REFERENCES Order(order_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well		   
CONSTRAINT chk_identifications_address
           FOREIGN KEY (address_id)
           REFERENCES Address(address_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
CONSTRAINT chk_identifications_price
           FOREIGN KEY (pricing_id)
           REFERENCES Pricing(pricing_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well		   		  
);
-- Following code is to auto-increment parcel_id

-- This sequence is to auto increment the id.
CREATE SEQUENCE parcel_id_seq 
				INCREMENT BY 1
				START WITH 10001
				NOCYCLE
				CACHE 20;

-- Below code is to trigger sequence to increment by 1 when CREATE or REPLACE is detected.
CREATE OR REPLACE TRIGGER parcel_id_bir
BEFORE INSERT ON Parcel
FOR EACH ROW

BEGIN
    SELECT  parcel_id_seq.NEXTVAL
    INTO    :new.parcel_id
    FROM    dual;
END;
/

------------------
-- 11. Tracking --
------------------
CREATE TABLE Tracking(
	tracking_id		NUMBER,		--PK
	status			VARCHAR2	NOT NULL,
	remark			VARCHAR2,
	created_at		DATE		NOT NULL,
	parcel_id		NUMBER,
CONSTRAINT tracking_pk PRIMARY KEY (tracking_id),
CONSTRAINT tracking_status_check CHECK (status IN ('pending', 'delivering', 'deliverd','canceled'))
CONSTRAINT chk_identifications_parcel
           FOREIGN KEY (parcel_id)
           REFERENCES Parcel(parcel_id)
           ON DELETE CASCADE -- If the disease is deleted, this record is deleted as well
);
-- Following code is to auto-increment tracking_id

-- This sequence is to auto increment the id.
CREATE SEQUENCE tracking_id_seq 
				INCREMENT BY 1
				START WITH 11001
				NOCYCLE
				CACHE 20;

-- Below code is to trigger sequence to increment by 1 when CREATE or REPLACE is detected.
CREATE OR REPLACE TRIGGER tracking_id_bir
BEFORE INSERT ON Tracking
FOR EACH ROW

BEGIN
    SELECT  tracking_id_seq.NEXTVAL
    INTO    :new.tracking_id
    FROM    dual;
END;
/	

------------------
-- 12. Services --
------------------
CREATE TABLE Services{
	services_id 	VARCHAR2(6) NOT NULL,
	type 			CHAR(10) NOT NULL,
	description 	CHAR(50) NOT NULL,
	price 			NUMBER(5,2) NOT NULL,
CONSTRAINT services_pk PRIMARY KEY (services_id)
CONSTRAINT services_type_check CHECK (type IN ('standard', 'express'))
);

-------------------
-- 13. Insurance --
-------------------
CREATE TABLE Insurance{
	insurance_id 	VARCHAR2(6) NOT NULL,
	type 			VARCHAR(10) NOT NULL,
	rate 			NUMBER(5,2) NOT NULL,
	price 			NUMBER(5,2) NOT NULL,
CONSTRAINT insurance_pk PRIMARY KEY (insurance_id)
CONSTRAINT insurance_type_check CHECK (type IN ('bronze', 'silver', 'gold', 'platinum'))
);

-----------------
-- 14. Pricing --
-----------------
CREATE TABLE Pricing{
	pricing_id 		VARCHAR2(6) NOT NULL,
	weight 			NUMBER(5) 	NOT NULL,
	east_price 		NUMBER(5,2) NOT NULL,
	west_price 		NUMBER(5,2) NOT NULL,
CONSTRAINT pricing_pk PRIMARY KEY (pricing_id)
);