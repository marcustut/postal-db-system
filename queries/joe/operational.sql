-- Author: Tang Xiao Zu

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

-- Description of query
PROMPT This query is for staff to check recipient address and contact details 
PROMPT based on the delivery id. 
PROMPT
PROMPT Example Delivery ID: 11001

-- Get user input
ACCEPT v_deliver_id NUMBER PROMPT 'Enter Delivery ID: '

SELECT a.country, a.state, a.city, a.line1, a.line2, a.postal_code, p.receipient_name, p.receipient_contact  
FROM "Address" a, "Parcel" p, "Delivery" d
WHERE a.address_id = p.address_id AND p.delivery_id = d.delivery_id AND d.delivery_id = &v_deliver_id;