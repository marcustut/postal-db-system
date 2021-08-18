----------------
-- 1. Address --
----------------
INSERT INTO Address (country, state, city, line1, line2, postal_code, created_at, updated_at) VALUES ('Malaysia', 'Kuala Lumpur', 'Cheras', '12, Jalan Girafa, Taman Gifra', '55300, Kuala Lumpur', '55300', SYSDATE, SYSDATE);

-------------
-- 2. Card --
-------------
INSERT INTO Card (brand, name, exp_month, exp_year, last4, created_at, updated_at) VALUES ('visa', 'Lee Kai Yang', 6, 2022, '7272', SYSDATE, SYSDATE);

-----------------
-- 3. Customer --
-----------------
INSERT INTO Customer (name, ic, dob, phone, email, created_at, updated_at, address_id) VALUES ('Marcus Lee Kai Yang', '000614102109', SYSDATE, '0163066883', 'marcustutorial@hotmail.com', SYSDATE, SYSDATE, 1001);

----------------------
-- 4. PaymentMethod --
----------------------
INSERT INTO PaymentMethod (type, created_at, updated_at, cust_id, card_id) VALUES ('fpx', SYSDATE, SYSDATE, 3001, 2001);