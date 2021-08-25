-- Author: Tang Xiao Zu

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 180
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

TTITLE 'Top 10 Customer' SKIP 2

COLUMN cust_id FORMAT 99999 HEADING 'Customer ID' 
COLUMN total_order FORMAT 9999 HEADING 'Total Order'
COLUMN total_amount FORMAT 9999 HEADING 'Total Price'

-- Clear screen
cl scr

-- Description of query
PROMPT This query is for management to check top customer based on their number of orders
PROMPT and the payment they made based on year.
PROMPT

-- Get user input
ACCEPT v_year NUMBER PROMPT 'Enter a Year: '

SELECT c.cust_id, count(pc.parcel_id) AS total_order, sum(pm.amount) AS total_amount
FROM "Customer" c, "Order" o, "Parcel" pc, "Payment" pm
WHERE c.cust_id = o.cust_id AND pc.order_id = o.order_id AND pm.payment_id = o.payment_id 
AND EXTRACT(YEAR FROM pc.created_at) = &v_year
GROUP BY c.cust_id
ORDER BY total_order DESC
FETCH FIRST 10 ROWS ONLY;

CLEAR COLUMNS
TTITLE OFF