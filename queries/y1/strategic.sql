SET TERMOUT OFF 
SET LINESIZE 90
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

TTITLE CENTER 'Top 10 Staff in Year' SKIP 2

COLUMN branch FORMAT A20 HEADING 'Branch' ;
COLUMN staff_id FORMAT 99999 HEADING 'Staff Id' ;
COLUMN staff_name FORMAT A30 HEADING 'Staff Name';
COLUMN total_parcel FORMAT 9999 HEADING 'Total Parcel';

COMPUTE SUM LABEL "Total: " OF total_parcel ON REPORT
BREAK ON REPORT

ACCEPT d_year number PROMPT 'Enter a Year: '

SELECT S.branch, S.staff_id, S.staff_name, COUNT(P.parcel_id) AS total_parcel
FROM "Staff" S, "Delivery" D, "Parcel" P
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id 
AND EXTRACT(YEAR FROM D.delivery_date) = &d_year
GROUP BY S.branch, S.staff_id, S.staff_name
ORDER BY total_parcel DESC
FETCH FIRST 10 ROWS ONLY;

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF
