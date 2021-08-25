-- Author: Tang Xiao Zu

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

TTITLE 'Receipient Details For Delivery' SKIP 2

COLUMN country FORMAT A10 HEADING 'Country';
COLUMN state FORMAT A20 HEADING 'State';
COLUMN city FORMAT A15 HEADING 'City';
COLUMN line1 FORMAT A30 HEADING 'Line1';
COLUMN line2 FORMAT A30 HEADING 'Line2';
COLUMN postal_code FORMAT A10 HEADING 'Post Code';
COLUMN receipient_name FORMAT A20 HEADING 'Receipient Name';
COLUMN receipient_contact FORMAT A20 HEADING 'Contact No';

-- Clear screen
cl scr

-- Description of query
PROMPT This query is for staff to check receipient address and contact details 
PROMPT based on the delivery id. 
PROMPT
PROMPT Example Delivery ID: 11001
PROMPT

-- Get user input
ACCEPT v_deliver_id NUMBER PROMPT 'Enter Delivery ID: '

SELECT a.country, a.state, a.city, a.line1, a.line2, a.postal_code, p.receipient_name, p.receipient_contact  
FROM "Address" a, "Parcel" p, "Delivery" d
WHERE a.address_id = p.address_id AND p.delivery_id = d.delivery_id AND d.delivery_id = &v_deliver_id;

CLEAR COLUMNS