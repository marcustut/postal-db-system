--Author: Tang Xiao Zu

SET TERMOUT OFF 
SET LINESIZE 180
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE RPT_STAFF_PERFORMANCE(S_YEAR IN NUMBER) IS
--staffid, staffname, email, phone, branch, totalparceldelivered, amountoftheparcel, percentage 

E_NO_RECORD_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT(E_NO_RECORD_FOUND, -20076);
dev_month "Delivery".delivery_date%TYPE;
v_totalParcel NUMBER(5) := 0;
v_totalAmt NUMBER(10,2) := 0;
recordCount NUMBER := 0;
v_subCon NUMBER(5,2) := 0;
v_percentage NUMBER(4,2) := 0;
v_sumParcel NUMBER(10,2) := 0;
v_grandParcel NUMBER(5) := 0;
v_grandAmt NUMBER(10,2) := 0;
v_grandCon NUMBER(5,2) := 0;


CURSOR PERFORMANCE_MONTH_CURSOR IS
SELECT DISTINCT EXTRACT(MONTH FROM delivery_date) AS dev_month
FROM "Delivery"
ORDER BY dev_month;

CURSOR STAFF_CURSOR(s_month IN NUMBER) IS
SELECT S.staff_id, S.staff_name, S.email, S.phone, S.branch, COUNT(P.parcel_id) AS total_parcel, SUM(Pm.amount) AS total_amount
FROM "Staff" S, "Delivery" D, "Parcel" P, "Payment" Pm, "Order" O
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id AND P.order_id = O.order_id AND O.payment_id = Pm.payment_id 
        AND EXTRACT(MONTH FROM D.delivery_date) = s_month AND EXTRACT(YEAR FROM D.delivery_date) = S_YEAR
GROUP BY S.staff_id, S.staff_name, S.email, S.phone, S.branch
ORDER BY S.staff_id; 

BEGIN 
    SELECT COUNT(created_at) INTO recordCount
    FROM "Parcel"
    WHERE EXTRACT(YEAR FROM created_at) = S_YEAR;

    IF (recordCount = 0) THEN
        RAISE_APPLICATION_ERROR(-20076, 'No Record Found.', true);
    ELSE
        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 58, ' ') || RPAD('-', 23, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 58, ' ') || RPAD('Performance Report ' || S_YEAR, 30, ' '));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 58, ' ') || RPAD('-', 23, '-'));
        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 45, ' ') || 'Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
        DBMS_OUTPUT.PUT_LINE(chr(10));

        FOR s_month IN PERFORMANCE_MONTH_CURSOR LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD('Month', 10, ' ') || ': ' || RPAD(UPPER(s_month.dev_month), 60, ' '));
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 142, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Staff ID', 10, ' ') || RPAD('Staff Name', 25, ' ') || RPAD('Staff Email', 40, ' ') || RPAD('Phone Number', 15, ' ') || RPAD('Branch', 17, ' ') || 
            RPAD('Parcel', 10, ' ') || RPAD('Total Amount', 15, ' ') || RPAD('Percentage', 15, ' '));
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 142, '-'));

            v_totalParcel := 0;
            v_totalAmt := 0;
            v_subCon := 0;
            v_percentage := 0;

            SELECT COUNT(parcel_id) INTO v_sumParcel
            FROM "Parcel"
            WHERE EXTRACT(YEAR FROM created_at) = S_YEAR;

                FOR sta_rec IN STAFF_CURSOR(s_month.dev_month) LOOP

                v_percentage := (sta_rec.total_parcel / v_sumParcel) * 100;
                
                    DBMS_OUTPUT.PUT_LINE(RPAD(sta_rec.staff_id, 10, ' ') || RPAD(sta_rec.staff_name, 25, ' ') || RPAD(sta_rec.email, 40, ' ') || RPAD(sta_rec.phone, 15, ' ') || 
                    RPAD(sta_rec.branch, 19, ' ') || RPAD(sta_rec.total_parcel, 8, ' ') || 'RM ' || RPAD(sta_rec.total_amount, 17, ' ') ||
                    RPAD(TRIM(TO_CHAR(v_percentage, '90D9')), 4, ' ') || '%');

                    v_totalParcel := v_totalParcel + sta_rec.total_parcel;
                    v_totalAmt := v_totalAmt + sta_rec.total_amount;
                    v_subCon := v_subCon + v_percentage;
                
                END LOOP;

            DBMS_OUTPUT.PUT_LINE(LPAD('=', 142, '='));
            DBMS_OUTPUT.PUT_LINE(RPAD('*', 99, ' ') || 'Subtotal: ' || RPAD(v_totalParcel, 6, ' ') || RPAD(' ', 2, ' ') || 'RM ' || 
            RPAD(TRIM(TO_CHAR(v_totalAmt, '999G999D99')), 14, ' ') || RPAD(' ', 3, ' ') || RPAD(TRIM(TO_CHAR(v_subCon, '990D9')), 4, ' ') || '%');
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 142, '-'));
            DBMS_OUTPUT.PUT_LINE(chr(10));

            v_grandParcel := v_grandParcel + v_totalParcel;
            v_grandAmt := v_grandAmt + v_totalAmt;
            v_grandCon := v_grandCon + v_subCon;
        
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(LPAD('=', 142, '='));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 96, ' ') || 'Grand Total: ' || RPAD(v_grandParcel, 6, ' ') || RPAD(' ', 2, ' ') || 'RM ' || RPAD(TRIM(TO_CHAR(v_grandAmt, '999G999D99')), 13, ' ') || RPAD(' ', 3, ' ') || RPAD(TRIM(TO_CHAR(v_grandCon, '990D9')), 5, ' ') || '%');
        DBMS_OUTPUT.PUT_LINE(LPAD('=', 142, '='));
        DBMS_OUTPUT.PUT_LINE(chr(10));

    END IF;

    EXCEPTION 
        WHEN E_NO_RECORD_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('--------------------------------');
            DBMS_OUTPUT.PUT_LINE('Failed to print report for ' || S_YEAR || '.');
            DBMS_OUTPUT.PUT_LINE('--------------------------------');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/
