--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON

TTITLE CENTER 'Highest Number of Delivery Daily' SKIP 2

COLUMN delivery_date FORMAT A20 HEADING 'Delivery Date';
COLUMN branch FORMAT A20 HEADING 'Branch';
COLUMN total FORMAT 9999 HEADING 'Total Parcel';

PROMPT Every branch delivery quantity per month
ACCEPT d_date_start PROMPT 'Enter a Start Date wish to search: '
ACCEPT d_date_end PROMPT 'Enter a End Date wish to search: '
PROMPT

CREATE OR REPLACE VIEW TOTAL_DAILY_PARCEL_VIEW AS
SELECT D.delivery_id, D.delivery_date, S.branch, COUNT(P.parcel_id) AS total_parcel
FROM "Staff" S, "Delivery" D, "Parcel" P
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id 
GROUP BY D.delivery_id, D.delivery_date, S.branch;

BREAK ON delivery_date ON branch
SELECT D.delivery_date, V.branch, MAX(V.total_parcel) AS Total
FROM TOTAL_DAILY_PARCEL_VIEW V, "Delivery" D
WHERE D.delivery_id = V.delivery_id AND 
D.delivery_date BETWEEN TO_DATE('&d_date_start', 'DD/MM/YYYY') AND TO_DATE('&d_date_end', 'DD/MM/YYYY')
GROUP BY D.delivery_date, V.branch
ORDER BY D.delivery_date, Total DESC;

CLEAR COLUMN COLUMNS
CLEAR BREAKS
TTITLE OFF