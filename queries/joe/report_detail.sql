--Author: Tang Xiao Zu

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE RPT_DELIVERIES_AREAS(IN_year IN NUMBER) IS
E_NO_RECORD_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT(E_NO_RECORD_FOUND, -20008);
v_totalParcel NUMBER(5) := 0;
v_grandParcel NUMBER(5) := 0;
v_contribution NUMBER(4,2) := 0;
v_subCon NUMBER(5,2) := 0;
v_grandCon NUMBER(5,2) := 0; 
v_sumParcel NUMBER(10,2) := 0;
recordCount NUMBER := 0;

CURSOR DELIVERY_AREAS_CURSOR IS
SELECT DISTINCT branch
FROM "Staff"
ORDER BY branch; 

CURSOR DELIVERY_CURSOR(dev_branch IN VARCHAR2) IS
SELECT D.delivery_date, D.staff_id, S.branch, COUNT(P.parcel_id) AS total_parcel
FROM "Staff" S, "Delivery" D, "Parcel" P
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id AND branch = dev_branch AND EXTRACT(YEAR FROM D.delivery_date) = IN_year
GROUP BY D.delivery_date, D.staff_id, S.branch
ORDER BY D.delivery_date, total_parcel DESC;

BEGIN
    SELECT COUNT(created_at) INTO recordCount
    FROM "Parcel"
    WHERE EXTRACT(YEAR FROM created_at) = IN_year;

    IF (recordCount = 0) THEN
        RAISE_APPLICATION_ERROR(-20008, 'No Record Found.', true);
    ELSE
        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 21, ' ') || RPAD('-', 20, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 21, ' ') || RPAD('Delivery Report ' || IN_year, 30, ' '));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 21, ' ') || RPAD('-', 20, '-'));
        DBMS_OUTPUT.PUT_LINE(chr(10));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 8, ' ') || 'Report generated on : ' || TO_CHAR(CURRENT_DATE, 'DD-MM-YYYY HH:MI:SS') || ' by ' || USER);
        DBMS_OUTPUT.PUT_LINE(chr(10)); 

        FOR dev_branch IN DELIVERY_AREAS_CURSOR LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD('Branch', 10, ' ') || ': ' || RPAD(UPPER(dev_branch.branch), 60, ' '));
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 62, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Delivery Date', 20, ' ') || RPAD('Staff ID', 15, ' ') || RPAD('Total Parcel', 17, ' ') || RPAD('Percentage', 15, ' '));
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 62, '-'));

            v_totalParcel := 0;
            v_subCon := 0;
            v_contribution := 0;

            SELECT COUNT(parcel_id) INTO v_sumParcel
            FROM "Parcel"
            WHERE EXTRACT(YEAR FROM created_at) = IN_year;

                FOR del_rec IN DELIVERY_CURSOR(dev_branch.branch) LOOP

                v_contribution := (del_rec.total_parcel / v_sumParcel) * 100;

                    DBMS_OUTPUT.PUT_LINE(RPAD(del_rec.delivery_date, 20, ' ') || RPAD(del_rec.staff_id, 25, ' ') || RPAD(del_rec.total_parcel, 11, ' ') || 
                    RPAD(TRIM(TO_CHAR(v_contribution, '90D9')), 4, ' ') || ' %');

                    v_totalParcel := v_totalParcel + del_rec.total_parcel;
                    v_subCon := v_subCon + v_contribution;
                
                END LOOP;
            
            DBMS_OUTPUT.PUT_LINE(LPAD('=', 62, '='));
            DBMS_OUTPUT.PUT_LINE(RPAD('*', 35, ' ') || 'Subtotal: ' || RPAD(v_totalParcel, 8, ' ') || RPAD(' ', 3, ' ') || RPAD(TRIM(TO_CHAR(v_subCon, '990D9')), 4, ' ') || ' %');
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 62, '-'));
            DBMS_OUTPUT.PUT_LINE(chr(10));

            v_grandParcel := v_grandParcel + v_totalParcel;
            v_grandCon := v_grandCon + v_subCon;

        END LOOP;
        
    DBMS_OUTPUT.PUT_LINE(LPAD('=', 62, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('*', 32, ' ') || 'Grand Total: ' || RPAD(v_grandParcel, 8, ' ') || RPAD(' ', 3, ' ') || RPAD(TRIM(TO_CHAR(v_grandCon, '990D9')), 4, ' ') || ' %');
    DBMS_OUTPUT.PUT_LINE(LPAD('-', 62, '-'));
    DBMS_OUTPUT.PUT_LINE(chr(10));

    END IF;

    EXCEPTION 
        WHEN E_NO_RECORD_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('--------------------------------');
            DBMS_OUTPUT.PUT_LINE('Failed to print report for ' || IN_year || '.');
            DBMS_OUTPUT.PUT_LINE('--------------------------------');
            DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

