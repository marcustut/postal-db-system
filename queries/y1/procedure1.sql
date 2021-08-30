--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF





CREATE OR REPLACE PROCEDURE PRC_ADD_PAYMENT_METHOD(
    IN_custId IN "Customer".cust_id%type, 
    IN_methodType IN "PaymentMethod".type%type, 
    IN_brand IN "Card".brand%type := '0', 
    IN_name IN "Card".name%type := '0', 
    IN_expmonth IN "Card".exp_month%type := 1,
    IN_expyear IN "Card".exp_year%type := 2022,
    IN_last4 IN "Card".last4%type := '0'
    ) IS 
E_CUST_NOT_FOUND EXCEPTION;
E_CARD_INFORMATION_NC EXCEPTION;
E_CARD_EXPIRED EXCEPTION;
E_CARD_EXPIRING EXCEPTION;
PRAGMA EXCEPTION_INIT (E_CUST_NOT_FOUND, -20000);
PRAGMA EXCEPTION_INIT (E_CARD_INFORMATION_NC, -20001);
PRAGMA EXCEPTION_INIT (E_CARD_EXPIRING, -20057);
PRAGMA EXCEPTION_INIT (E_CARD_EXPIRED, -20056);



CURSOR CUST_CURSOR IS 
    SELECT * FROM "Customer" WHERE cust_id = IN_custId;
CUST_REC CUST_CURSOR%ROWTYPE;


BEGIN
    OPEN CUST_CURSOR;
    FETCH CUST_CURSOR INTO CUST_REC;
    IF (CUST_CURSOR%NOTFOUND) THEN
     RAISE E_CUST_NOT_FOUND;
     CLOSE CUST_CURSOR;
    END IF;

    IF (IN_methodType = 'card') THEN 
        CASE 
        WHEN (IN_brand = '0') THEN 
            RAISE E_CARD_INFORMATION_NC;
        WHEN (IN_name = '0') THEN 
            RAISE E_CARD_INFORMATION_NC;
        WHEN (IN_last4 = '0') THEN 
            RAISE E_CARD_INFORMATION_NC;
        ELSE
            insert into "Card" (brand, name, exp_month, exp_year, last4) 
            values (IN_brand,IN_name,IN_expmonth, IN_expyear, IN_last4);
            insert into "PaymentMethod" (type, cust_id, card_id) 
            values (IN_methodType, IN_custId, card_id_seq.CURRVAL);
        END CASE;

        

        DBMS_OUTPUT.PUT_LINE('=========================================================');
        DBMS_OUTPUT.PUT_LINE('Card Name:         '||IN_name);
        DBMS_OUTPUT.PUT_LINE('Card Brand:        '||IN_brand);
        DBMS_OUTPUT.PUT_LINE('Card Last 4 digit: '||IN_last4);
        DBMS_OUTPUT.PUT_LINE('Card Expiry:       '||IN_expmonth||'/'||IN_expyear);
        DBMS_OUTPUT.PUT_LINE('This new card will be ready for payment');
        DBMS_OUTPUT.PUT_LINE('=========================================================');
    ELSE
        insert into "PaymentMethod" (type, cust_id, card_id) 
        values (IN_methodType, IN_custId, null);
         DBMS_OUTPUT.PUT_LINE('=========================================================');
         DBMS_OUTPUT.PUT_LINE('Payment Method:         '||IN_methodType);
         DBMS_OUTPUT.PUT_LINE('This new payment method will be ready for payment');
         DBMS_OUTPUT.PUT_LINE('=========================================================');
    END IF;


EXCEPTION 
    WHEN E_CUST_NOT_FOUND THEN
     DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Customer ID '||IN_custId||' not found.');
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');  

    WHEN E_CARD_INFORMATION_NC THEN
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');  
     DBMS_OUTPUT.PUT_LINE('New Card Information Entered were not complete. ');
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');  

     WHEN E_CARD_EXPIRED THEN
     DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Card had expired, try a new one.');
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');

     WHEN E_CARD_EXPIRING THEN
     DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
     DBMS_OUTPUT.PUT_LINE('Card will be expired in this month, try a new one.');
     DBMS_OUTPUT.PUT_LINE('------------------------------------------');

END;
/

CREATE OR REPLACE TRIGGER TRG_VALIDATE_EXPDATE
BEFORE INSERT OR UPDATE
ON "Card"
FOR EACH ROW

DECLARE
c_exp_month  "Card".exp_month%type;
c_exp_year "Card".exp_year%type;
t_month "Card".exp_month%type;
t_year "Card".exp_year%type;


BEGIN
c_exp_month := :new.exp_month;
c_exp_year := :new.exp_year;
SELECT EXTRACT(MONTH FROM SYSDATE) INTO t_month FROM dual;
SELECT EXTRACT(YEAR FROM SYSDATE) INTO t_year FROM dual;



IF (c_exp_year < t_year) THEN
    RAISE_APPLICATION_ERROR (-20056,'Card had expired, try a new one.');
ELSIF (c_exp_year = t_year) THEN 
    IF (c_exp_month = t_month) THEN
        RAISE_APPLICATION_ERROR (-20057,'Card will be expired in this month, try a new one.');
    ELSIF (c_exp_month < t_month) THEN
       RAISE_APPLICATION_ERROR (-20056,'Card had expired, try a new one.');
    END IF;
END IF;



END;
/

--exec PRC_ADD_PAYMENT_METHOD(3916,'card');
-- exec PRC_ADD_PAYMENT_METHOD(3916,'grabpay');
--exec PRC_ADD_PAYMENT_METHOD(3916,'card','visa','Wong Wai Yi',12,2023,'1234');
