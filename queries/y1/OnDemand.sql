--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 200
SET PAGESIZE 400
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE RPT_BRANCH_SALES (IN_BRANCH IN VARCHAR2) IS 
E_NO_RECORD_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (E_NO_RECORD_FOUND, -20010);
total_amount NUMBER;
total_tax NUMBER;

CURSOR BRANCH_CURSOR IS
    SELECT * FROM "Address" WHERE state=IN_BRANCH;
BRANCH_REC BRANCH_CURSOR%ROWTYPE;

CURSOR MONTH_CURSOR IS
SELECT DISTINCT EXTRACT(MONTH FROM created_at) as O_month
FROM "Order"
ORDER BY O_month;

CURSOR DETAILS_CURSOR(mon IN VARCHAR2) IS
SELECT 
SUM(PA.amount) AS "D_amount", 
SUM(PA.tax) AS "D_tax",  
COUNT(P.parcel_id) AS "total_parcel"
FROM "Payment" PA, "Order" O, "Parcel" P, "Address" A
WHERE 
PA.payment_id = O.payment_id AND 
O.order_id = P.order_id AND 
EXTRACT(MONTH FROM O.created_at) = mon AND 
A.address_id = P.address_id AND
A.state = IN_BRANCH;

BEGIN
    OPEN BRANCH_CURSOR;
    FETCH BRANCH_CURSOR INTO BRANCH_REC;
    IF (BRANCH_CURSOR%NOTFOUND) THEN
        RAISE E_NO_RECORD_FOUND;
    CLOSE BRANCH_CURSOR;
    END IF;

    --DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(RPAD('DATE',10,' ')||':'||SYSDATE);
    DBMS_OUTPUT.PUT_LINE(RPAD('DAY',10,' ')||':'||TO_CHAR(SYSDATE,'DAY'));
    DBMS_OUTPUT.PUT_LINE(chr(10));
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    DBMS_OUTPUT.PUT_LINE('|Sales for Branch '||IN_BRANCH||'|');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');


    DBMS_OUTPUT.PUT_LINE(
            RPAD('Month',15)||
            RPAD('Parcel Order',20)||
            RPAD('Tax (RM)',20)||
            RPAD('Price (RM)',20)
            );

         DBMS_OUTPUT.PUT_LINE(
            RPAD('-',14,'-')||' '||
            RPAD('-',19,'-')||' '||
            RPAD('-',19,'-')||' '||
            RPAD('-',19,'-')
        );   
    total_amount:=0;
    total_tax := 0;
        
    FOR mon IN MONTH_CURSOR LOOP
    

    FOR detail_rec IN DETAILS_CURSOR(mon.O_month) LOOP 
    DBMS_OUTPUT.PUT_LINE(
            RPAD(mon.O_month,15)||
            RPAD(detail_rec."total_parcel",20)||
            RPAD(detail_rec."D_tax",20)||
            RPAD(detail_rec."D_amount",20)
            );
    total_amount := total_amount + detail_rec."D_amount";
    total_tax := total_tax + detail_rec."D_tax";
    END LOOP;
    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(
        RPAD(' ',29,'-')|| 'Total:' ||
        RPAD(TRIM(TO_CHAR(total_tax,'9999D99')),20, ' ')||
        RPAD(TRIM(TO_CHAR(total_amount,'9999D99')),20,' ')        
        );

 EXCEPTION
        WHEN E_NO_RECORD_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('--------------------------');
            DBMS_OUTPUT.PUT_LINE('No Record Found in '||IN_BRANCH);
            DBMS_OUTPUT.PUT_LINE('--------------------------');

END;
/
