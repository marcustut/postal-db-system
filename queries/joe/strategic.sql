-- Author: Tang Xiao Zu

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 180
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

TTITLE 'Percentage of total parcel based on status' SKIP 2

COLUMN state FORMAT A20 HEADING 'State';
COLUMN status FORMAT A10 HEADING 'Status';
COLUMN year FORMAT A5 HEADING 'Year';
COLUMN total_parcel FORMAT 999 HEADING 'Total Parcel';
COLUMN percentage FORMAT 99.99 HEADING 'Percentage';

-- Clear screen
cl scr

-- Description of query
PROMPT This query is a breakdown for management to track the statuses of the parcel
PROMPT based on area in a year. 
PROMPT

-- Get user input
ACCEPT s_year NUMBER PROMPT 'Enter a Year: ';
ACCEPT s_status PROMPT 'Enter a status: '; 

SELECT state, status, count(p.parcel_id) AS total_parcel, ((count(p.parcel_id))/ (select count(p.parcel_id) AS total_parcel 
FROM "Tracking" t, "Parcel" p, "Address" a
WHERE t.parcel_id = p.parcel_id AND a.address_id = p.address_id AND extract(year FROM t.created_at) = '&s_year')*100) AS Percentage
FROM "Parcel" p, "Address" a, "Tracking" t
WHERE p.address_id = a.address_id AND p.parcel_id = t.parcel_id AND t.status = '&s_status' AND extract(year FROM t.created_at) = '&s_year'
GROUP BY state, status, extract(year FROM t.created_at)
ORDER BY state;

CLEAR COLUMNS