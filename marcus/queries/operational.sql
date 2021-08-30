-- Author: Marcus Lee Kai Yang

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
PROMPT This query is for customer to check orders between the start and end date 
PROMPT to find out the payment amount, parcel details and tracking status.
PROMPT
PROMPT Example Customer ID: 3042
PROMPT Example Start/End Date: 01/01/2019
PROMPT

-- Get user input
ACCEPT v_cust_id     NUMBER            PROMPT 'Enter Customer ID: '
ACCEPT v_start_date  CHAR   FORMAT A30 PROMPT 'Enter the Start Date: '
ACCEPT v_end_date    CHAR   FORMAT A30 PROMPT 'Enter the End Date: '

-- Formatting the result
SET UNDERLINE =
COLUMN "Order Fee (RM)"     FORMAT $999.99
COLUMN "Last Updated"       FORMAT A12
BREAK ON "Order ID" ON "Order Fee (RM)" ON "Order Date" SKIP 1

SELECT 
  B.order_id AS "Order ID",
  (B.tax + B.amount) AS "Order Fee (RM)",
  B.created_at AS "Order Date",
  B.parcel_id AS "Parcel ID", 
  B.weight AS "Parcel Weight (kg)", 
  A.tracking_id AS "Tracking ID", 
  A.status "Status", 
  A.created_at AS "Last Updated"
FROM 
  "Tracking" A,
  (
    SELECT 
      B.parcel_id, 
      B.weight,
      B.order_id,
      B.created_at,
      B.cust_id,
      B.tax,
      B.amount,
      MAX(T.created_at) AS "tracking_update_date"
    FROM 
      "Tracking" T,
      (
        SELECT P.parcel_id, P.weight, O.order_id, O.created_at, C.cust_id, PM.tax, PM.amount
        FROM "Parcel" P, "Order" O, "Customer" C, "Payment" PM
        WHERE O.order_id = P.order_id
          AND O.cust_id = C.cust_id
          AND O.payment_id = PM.payment_id
          AND C.cust_id = &v_cust_id
      ) B
    WHERE B.parcel_id = T.parcel_id
    GROUP BY B.parcel_id, B.weight, B.order_id, B.created_at, B.cust_id, B.tax, B.amount
  ) B
WHERE A.parcel_id = B.parcel_id 
  AND A.created_at = B."tracking_update_date"
  AND A.created_at BETWEEN TO_DATE('&v_start_date', 'DD/MM/YYYY') AND TO_DATE('&v_end_date', 'DD/MM/YYYY')
ORDER BY B.order_id, A.created_at DESC;
