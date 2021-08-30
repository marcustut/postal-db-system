CREATE OR REPLACE PROCEDURE RPT_PARCEL_STATUS(IN_STATUS IN VARCHAR2) IS
E_NO_STATUS_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT(E_NO_STATUS_FOUND, -20077);
s_totalparcel NUMBER(5) := 0;
s_totalamt NUMBER(10,2) := 0;

CURSOR STATUS_CURSOR IS 
SELECT status 
FROM "Tracking"
WHERE status = IN_STATUS; 
STATUS_REC STATUS_CURSOR%ROWTYPE;

CURSOR MONTH_CURSOR IS 
SELECT DISTINCT EXTRACT(MONTH FROM created_at) AS s_month
FROM "Parcel"
ORDER BY s_month;

CURSOR STATUS_DETAIL_CURSOR(status_month IN VARCHAR2) IS
SELECT COUNT(P.parcel_id) AS total_parcel, P.type, SUM(Pm.amount) AS total_amount
FROM "Parcel" P, "Tracking" T, "Order" O, "Payment" Pm
WHERE P.parcel_id = T.parcel_id 
        AND P.order_id = O.order_id
        AND O.payment_id = Pm.payment_id
        AND EXTRACT(MONTH FROM P.created_at) = status_month
        AND T.status = IN_STATUS
GROUP BY P.type
ORDER BY P.type;

BEGIN 
    OPEN STATUS_CURSOR;
    FETCH STATUS_CURSOR INTO STATUS_REC;
    IF (STATUS_CURSOR%NOTFOUND) THEN 
        RAISE E_NO_STATUS_FOUND;
    CLOSE STATUS_CURSOR;
    END IF;

        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 15, ' ') || RPAD('-', 27, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 15, ' ') || RPAD('Report On ' || IN_STATUS, 27, ' status.'));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 15, ' ') || RPAD('-', 27, '-'));
        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 5, ' ') || 'Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
        DBMS_OUTPUT.PUT_LINE(chr(10));

        DBMS_OUTPUT.PUT_LINE(RPAD('Month',10)||RPAD('Total Parcel',16)||RPAD('Type',16)||RPAD('Price (RM)',15));
        DBMS_OUTPUT.PUT_LINE(RPAD('-',9,'-')||' '||RPAD('-',15,'-')||' '||RPAD('-',15,'-')||' '||RPAD('-',15,'-'));

        s_totalamt := 0;
        s_totalparcel := 0;

        FOR status_month IN MONTH_CURSOR LOOP

        FOR s_rec IN STATUS_DETAIL_CURSOR(status_month.s_month) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(status_month.s_month,10)||RPAD(s_rec.total_parcel,16)||RPAD(s_rec.type,16)||RPAD(s_rec.total_amount,20));

        s_totalamt := s_totalamt + s_rec.total_amount;
        s_totalparcel := s_totalparcel + s_rec.total_parcel;

        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(LPAD('=', 60, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('*', 3, ' ') || 'Total: ' || RPAD(s_totalparcel, 27, ' ') || RPAD(' ', 2, ' ') || 'RM ' || RPAD(TRIM(TO_CHAR(s_totalamt, '999G999D99')), 13, ' '));
    DBMS_OUTPUT.PUT_LINE(LPAD('=', 60, '='));
    DBMS_OUTPUT.PUT_LINE(chr(10));

    EXCEPTION
        WHEN E_NO_STATUS_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Failed to print report for ' || IN_STATUS || ' status.');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/