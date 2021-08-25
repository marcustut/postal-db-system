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

BREAK ON delivery_date ON branch
SELECT D.delivery_date, S.branch, COUNT(P.parcel_id) AS total_parcel
FROM "Staff" S, "Delivery" D, "Parcel" P
WHERE S.staff_id = D.staff_id AND D.delivery_id = P.delivery_id AND
    delivery_date BETWEEN TO_DATE('&d_date_start', 'DD/MM/YYYY') AND TO_DATE('&d_date_end', 'DD/MM/YYYY')
GROUP BY D.delivery_date, S.branch
ORDER BY D.delivery_date, total_parcel DESC;

CLEAR COLUMN COLUMNS
CLEAR BREAKS
TTITLE OFF