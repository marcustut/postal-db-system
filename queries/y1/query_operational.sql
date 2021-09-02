--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

TTITLE CENTER 'Staff Branch Timetable Search' SKIP 2

COLUMN state FORMAT A20 HEADING 'State';
COLUMN staff_id FORMAT 99999 HEADING 'Staff Id';
COLUMN staff_name FORMAT A30 HEADING 'Staff Name';
COLUMN delivery_date FORMAT A15 HEADING 'Delivery Date';
COLUMN total_parcel FORMAT 99999 HEADING 'Parcel';

PROMPT Delivery Information
ACCEPT a_state PROMPT 'Enter a State in Malaysia: '
ACCEPT d_date PROMPT 'Enter a working date: '
PROMPT

SELECT A.state, S.staff_id, S.staff_name, D.delivery_date, COUNT(P.parcel_id) AS total_parcel
FROM "Address" A, "Staff" S,  "Delivery" D, "Parcel" P
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id AND A.address_id = P.address_id AND
(UPPER(state) LIKE UPPER('%&a_state%') AND delivery_date LIKE '%&d_date%' )
GROUP BY A.state, S.staff_id, S.staff_name, D.delivery_date
Order By S.staff_id;
CLEAR COLUMN COLUMNS
TTITLE OFF

--Example: 
--State: Kuala Lumpur
--d_date: 25/02/2020