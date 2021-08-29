--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 200
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE RPT_ORDERS(IN_YEAR IN NUMBER) IS
o_total NUMBER;
E_NO_RECORD_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (E_NO_RECORD_FOUND, -20009);

CURSOR YEAR_CURSOR IS 
    SELECT * FROM "Parcel" WHERE EXTRACT(YEAR FROM updated_at) = IN_YEAR;
YEAR_REC YEAR_CURSOR%ROWTYPE;

CURSOR BRANCH_CURSOR IS 
SELECT DISTINCT state
FROM "Address"
ORDER BY state;

CURSOR ORDER_CURSOR(branch IN VARCHAR2) IS
SELECT 
    A.state AS "o_branch", 
    P.parcel_id AS "o_parcel_id",  
    O.order_id AS "o_order_id", 
    T.status AS "o_status", 
    PA.amount AS "o_amount"
FROM "Address" A, "Parcel" P, "Order" O, "Tracking" T, "Payment" PA
WHERE 
    A.address_id = P.address_id AND 
    P.order_id = O.order_id AND 
    P.parcel_id = T.parcel_id AND 
    EXTRACT(YEAR FROM P.updated_at) = IN_YEAR AND 
    O.payment_id=PA.payment_id AND 
    A.state = branch AND
    T.status != 'canceled'
ORDER BY A.state, O.order_id;
--order_rec ORDER_CURSOR&ROWTYPE;

BEGIN
    OPEN YEAR_CURSOR;
    FETCH YEAR_CURSOR INTO YEAR_REC;
    IF (YEAR_CURSOR%NOTFOUND) THEN
     RAISE E_NO_RECORD_FOUND;
     CLOSE YEAR_CURSOR;
     END IF;
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(RPAD('DATE',10,' ')||':'||SYSDATE);
    DBMS_OUTPUT.PUT_LINE(RPAD('DAY',10,' ')||':'||TO_CHAR(SYSDATE,'DAY'));
    DBMS_OUTPUT.PUT_LINE(chr(10));
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    DBMS_OUTPUT.PUT_LINE('|Order for Branch '||IN_YEAR||'|');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');

    FOR branch IN BRANCH_CURSOR LOOP
        o_total :=0;
        DBMS_OUTPUT.PUT_LINE(RPAD('-',70,'-'));
        DBMS_OUTPUT.PUT_LINE('Branch :'||branch.state);

        DBMS_OUTPUT.PUT_LINE(
            RPAD('Order ID',15)||
            RPAD('Parcel ID',15)||
            RPAD('Status',20)||
            RPAD('Price (RM)',20)
            );

        DBMS_OUTPUT.PUT_LINE(
            RPAD('-',14,'-')||' '||
            RPAD('-',14,'-')||' '||
            RPAD('-',19,'-')||' '||
            RPAD('-',19,'-')
        );
    
    FOR order_rec IN ORDER_CURSOR(branch.state) LOOP
    
        DBMS_OUTPUT.PUT_LINE(
            RPAD(order_rec."o_order_id",15)||
            RPAD(order_rec."o_parcel_id",15)||
            RPAD(order_rec."o_status",20)||
            RPAD(order_rec."o_amount",20)
            );
        o_total := o_total + order_rec."o_amount";

    END LOOP;
    -- CLOSE INSURANCE_ORDER_CURSOR;

    DBMS_OUTPUT.PUT_LINE(
        RPAD(' ',45,'-')|| 'Total:' ||
        RPAD(TRIM(TO_CHAR(o_total,'9999D99')),20,' '));
    END LOOP;

    EXCEPTION
        WHEN E_NO_RECORD_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('--------------------------');
            DBMS_OUTPUT.PUT_LINE('No Record Found in '||IN_YEAR);
            DBMS_OUTPUT.PUT_LINE('--------------------------');

END;
/
