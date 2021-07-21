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
CONSTRAINT customer_pk PRIMARY KEY (cust_id),
CONSTRAINT chk_email (REGEXP_LIKE(email, '^[0-9a-zA-Z]\w+@(\s+)$'))
);

