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
PROMPT Get the perecentage of how many orders had purchased insurance
PROMPT based on different types of delivery service
PROMPT
PROMPT Example Start/End Date: 01/01/2019
PROMPT

-- Get user input
ACCEPT v_start_date  CHAR   FORMAT A30 PROMPT 'Enter the Start Date: '
ACCEPT v_end_date    CHAR   FORMAT A30 PROMPT 'Enter the End Date: '

-- Formatting the result
SeT UNDERLINE =
COLUMN "Delivery Service"        FORMAT A11    HEADING "Delivery|Service" JUSTIFY CENTER
COLUMN "Insurance Type"                        HEADING "Insurance|Type" JUSTIFY CENTER
COLUMN "Quantity Sold"                         HEADING " Quantity Sold "
COLUMN "Percentage"              FORMAT 999.99 HEADING " Percentage (%) "
BREAK ON "Delivery Service" SKIP 1
COMPUTE SUM LABEL "Total Sold" OF "Quantity Sold" ON "Delivery Service"
COMPUTE SUM OF "Percentage" ON "Delivery Service"

SELECT
  S.name "Delivery Service",
  I.type AS "Insurance Type",
  COUNT(I.type) AS "Quantity Sold",
  COUNT(I.type) / (
    SELECT COUNT(*)
    FROM "Order" O
    WHERE O.created_at BETWEEN TO_DATE('&v_start_date', 'DD/MM/YYYY') AND TO_DATE('&v_end_date', 'DD/MM/YYYY')
  ) * 100 AS "Percentage"
FROM 
  "Order" O,
  "Insurance" I,
  "Parcel" P,
  "Service" S
WHERE O.insurance_id = I.insurance_id
  AND O.order_id = P.order_id
  AND P.service_id = S.service_id
  AND O.created_at BETWEEN TO_DATE('&v_start_date', 'DD/MM/YYYY') AND TO_DATE('&v_end_date', 'DD/MM/YYYY')
GROUP BY S.name, I.type
ORDER BY S.name;
