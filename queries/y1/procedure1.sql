--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF


CREATE OR REPLACE PROCEDURE PRC_ADD_ORDER (IN_custId IN "Customer".cust_id%type, IN_parcelID IN "Parcel".parcel_id%type, IN_paymentmethodID IN "PaymentMethod".payment_method_id%type, IN_insuranceID IN "Insurance".insurance_id%type := 0)
IS 

E_CUST_NOT_FOUND EXCEPTION;
E_PARCEL_NOT_FOUND EXCEPTION;
E_METHOD_NOT_FOUND EXCEPTION;
E_INSURANCE_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (E_CUST_NOT_FOUND, -20000);
PRAGMA EXCEPTION_INIT (E_PARCEL_NOT_FOUND, -20001);
PRAGMA EXCEPTION_INIT (E_METHOD_NOT_FOUND, -20002);
PRAGMA EXCEPTION_INIT (E_INSURANCE_NOT_FOUND, -20003);
o_date DATE;
o_insurance_claim "Order".insurance_claim%type;
p_status "Payment".status%type;
p_tax number(10,2);
p_date DATE;
d_price number;
s_price number;
i_price number;
total_amount number;
p_id number;
o_id number;

CURSOR CUST_CURSOR IS 
    SELECT * FROM "Customer" WHERE cust_id = IN_custId;
CURSOR PARCEL_CURSOR IS 
    SELECT * FROM "Parcel" WHERE parcel_id = IN_parcelID;
CURSOR PAYMENT_CURSOR IS 
    SELECT * FROM "PaymentMethod" WHERE payment_method_id = IN_paymentmethodID;
CURSOR INSURANCE_CURSOR IS 
    SELECT * FROM "Insurance" WHERE INSURANCE_ID = IN_insuranceID;

CUST_REC CUST_CURSOR%ROWTYPE;
PARCEL_REC PARCEL_CURSOR%ROWTYPE;
PAYMENT_REC PAYMENT_CURSOR%ROWTYPE;
INS_REC INSURANCE_CURSOR%ROWTYPE;

BEGIN
    OPEN CUST_CURSOR;
    FETCH CUST_CURSOR INTO CUST_REC;
    IF (CUST_CURSOR%NOTFOUND) THEN
     RAISE E_CUST_NOT_FOUND;
     CLOSE CUST_CURSOR;
    END IF;

    OPEN PARCEL_CURSOR;
    FETCH PARCEL_CURSOR INTO PARCEL_REC;
    IF (PARCEL_CURSOR%NOTFOUND) THEN
     RAISE E_PARCEL_NOT_FOUND;
     CLOSE PARCEL_CURSOR;
    END IF;

    OPEN PAYMENT_CURSOR;
    FETCH PAYMENT_CURSOR INTO PAYMENT_REC;
    IF (PAYMENT_CURSOR%NOTFOUND) THEN
     RAISE E_METHOD_NOT_FOUND;
     CLOSE PAYMENT_CURSOR;
    END IF;


    SELECT P.east_price INTO d_price
    FROM "Pricing" P, "Parcel" PA
    WHERE PA.parcel_id = IN_parcelID AND P.pricing_id = PA.pricing_id;    

    SELECT S.price INTO s_price
    FROM "Service" S, "Parcel" P
    WHERE P.parcel_id = IN_parcelID AND S.service_id = P.service_id;

    p_date := sysdate;
    o_date := sysdate;

    IF (IN_insuranceID!=0) THEN 
        OPEN INSURANCE_CURSOR;
        FETCH INSURANCE_CURSOR INTO INS_REC;
        IF (INSURANCE_CURSOR%NOTFOUND) THEN
        RAISE E_INSURANCE_NOT_FOUND;
        CLOSE INSURANCE_CURSOR;
        END IF;
        SELECT price INTO i_price
        FROM "Insurance"
        WHERE insurance_id = IN_insuranceID;
    ELSE 
    i_price := 0;
    END IF;
    total_amount := d_price + s_price + i_price;
    p_tax := total_amount*11/100;
    
    
    INSERT INTO "Payment" (amount, currency, description, status, tax, created_at, updated_at, canceled_at, succeeded_at, payment_method_id) 
    VALUES (total_amount,'myr',null,'processing',p_tax,p_date,p_date,null,null,IN_paymentmethodID) returning payment_id INTO p_id;
    INSERT INTO "Order" (cust_id, payment_id, insurance_id, insurance_claim, created_at) 
    VALUES (IN_custId, p_id, IN_insuranceID,'N', o_date) returning order_id INTO o_id;

    UPDATE "Parcel" SET order_id = o_id,updated_at = sysdate WHERE parcel_id = IN_parcelID;
    
    

    DBMS_OUTPUT.PUT_LINE('------ORDER DETAILS-------');
    DBMS_OUTPUT.PUT_LINE('Order ID: '||order_id_seq.CURRVAL);
    DBMS_OUTPUT.PUT_LINE('Parcel ID: '||IN_parcelID);
    DBMS_OUTPUT.PUT_LINE('Total Amount: '||total_amount);
    DBMS_OUTPUT.PUT_LINE('Tax: '||p_tax);
    DBMS_OUTPUT.PUT_LINE('Order created, please proceed to the payment page');
    

EXCEPTION 
    WHEN E_CUST_NOT_FOUND THEN
     DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Customer ID '||IN_custId||' not found.');
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');    
    WHEN E_PARCEL_NOT_FOUND THEN
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Parcel ID '|| IN_parcelID||' not found.');
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    WHEN E_METHOD_NOT_FOUND THEN
     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Payment Method '||IN_paymentmethodID||' not found.');
     DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    WHEN E_INSURANCE_NOT_FOUND THEN
     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Insurance ID '||IN_insuranceID||' not found.');
     DBMS_OUTPUT.PUT_LINE('--------------------------------------------------'); 

END;
/

CREATE OR REPLACE TRIGGER TRG_UPDATE_PARCEL_DATE
AFTER UPDATE OF order_id
ON "Parcel"
FOR EACH ROW
WHEN (new.updated_at != sysdate)
BEGIN 
UPDATE "Parcel" SET updated_at = sysdate WHERE parcel_id = :old.parcel_ID;


END;
/

--exec PRC_ADD_ORDER(4000, 13001, 5000, 7004);
-- SELECT * FROM "Parcel" WHERE parcel_id = 13001;