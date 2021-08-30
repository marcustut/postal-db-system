--Author: Tang Xiao Zu

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE PRC_UPDATE_RECORD(dCustID IN NUMBER, dOrderID IN NUMBER)IS
	E_CUSTOMER_NOT_FOUND EXCEPTION;
    E_ORDER_NOT_FOUND EXCEPTION;
    E_INSURANCE_CLAIM_ERROR EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_CUSTOMER_NOT_FOUND, -20069);
    PRAGMA EXCEPTION_INIT(E_ORDER_NOT_FOUND, -20070);
    PRAGMA EXCEPTION_INIT(E_INSURANCE_CLAIM_ERROR, -20071);
    v_insuranceid "Insurance".insurance_id%TYPE;
    v_insuranceclaim "Order".insurance_claim%TYPE;

    CURSOR CUSTOMER_CURSOR IS 
    SELECT * FROM "Customer" WHERE cust_id = dCustID;
    CURSOR ORDER_CURSOR IS
    SELECT * FROM "Order" WHERE order_id = dOrderID;

    CUSTOMER_REC CUSTOMER_CURSOR%ROWTYPE;
    ORDER_REC ORDER_CURSOR%ROWTYPE;

BEGIN

    OPEN CUSTOMER_CURSOR;
    FETCH CUSTOMER_CURSOR INTO CUSTOMER_REC;
    IF (CUSTOMER_CURSOR%NOTFOUND) THEN
     RAISE E_CUSTOMER_NOT_FOUND;
     CLOSE CUSTOMER_CURSOR;
    END IF;

    OPEN ORDER_CURSOR;
    FETCH ORDER_CURSOR INTO ORDER_REC;
    IF (ORDER_CURSOR%NOTFOUND) THEN
     RAISE E_ORDER_NOT_FOUND;
     CLOSE ORDER_CURSOR;
    END IF;

    SELECT I.insurance_id INTO v_insuranceid
    FROM "Insurance" I, "Order" O
    WHERE I.insurance_id = O.insurance_id AND O.order_id = dOrderID AND O.cust_id = dCustID;

    SELECT insurance_claim INTO v_insuranceclaim
    FROM "Order"
    WHERE order_id = dOrderID AND insurance_id = v_insuranceid;

    IF(v_insuranceclaim = 'Y') THEN
        RAISE_APPLICATION_ERROR(-20071, '[ERROR]Insurance already claimed! ');
    END IF;

    UPDATE "Order"
    SET insurance_claim = 'Y'
    WHERE order_id = dOrderID AND insurance_id = v_insuranceid; 


    EXCEPTION 
        WHEN E_CUSTOMER_NOT_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Customer ID '||dCustID||' not found.');
            DBMS_OUTPUT.PUT_LINE('------------------------------------------');
        WHEN E_ORDER_NOT_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Order ID '||dOrderID||' not found.');
            DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
        WHEN E_INSURANCE_CLAIM_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Insurance Claim for '||dOrderID||' ID has been claimed.');
            DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('[ERROR] No insurance id for this particular order id');

END;
/


-- 3901, 12436
-- 3265, 12437
