-- Author: Marcus Lee Kai Yang

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

-- Description of query
PROMPT This query is to show a detailed breakdown of earnings made
PROMPT each month for a specified year.
PROMPT 
PROMPT Example Year: 2020
PROMPT

-- Get user input
ACCEPT v_year     NUMBER            PROMPT 'Enter Year: '

-- Formatting the result
SET UNDERLINE =
COLUMN "Month"            FORMAT A13        HEADING "  Month  " JUSTIFY CENTER
COLUMN "Parcel Delivered"                   HEADING " Parcel| Delivered " JUSTIFY CENTER
COLUMN "Sales (RM)"       FORMAT $99999.99  HEADING " Sales (RM) " JUSTIFY CENTER
COLUMN "Tax (RM)"         FORMAT $99999.99  HEADING " Tax (RM) " JUSTIFY CENTER
COLUMN "Loss (RM)"        FORMAT $99999.99  HEADING " Loss (RM) " JUSTIFY CENTER
COLUMN "Profit (RM)"      FORMAT $99999.99  HEADING " Profit (RM) " JUSTIFY CENTER
BREAK ON REPORT
COMPUTE SUM LABEL "Total Profit" OF "Profit (RM)" ON REPORT

SELECT
  TO_CHAR(PM.updated_at, 'Month') AS "Month",
  COUNT(P.parcel_id) AS "Parcel Delivered",
  SUM(PM.amount + PM.tax) AS "Sales (RM)",
  SUM(PM.tax) AS "Tax (RM)",
  A."Loss" AS "Loss (RM)",
  SUM(PM.amount) - A."Loss" AS "Profit (RM)"
FROM
  "Parcel" P, 
  "Order" O, 
  "Payment" PM, 
  "Insurance" I,
  (
    SELECT
      TO_CHAR(PM.updated_at, 'Month') AS "Month",
      SUM(PM.amount * I.rate / 100) AS "Loss"
    FROM
      "Order" O, "Insurance" I, "Payment" PM
    WHERE O.insurance_id = I.insurance_id
      AND O.payment_id = PM.payment_id
      AND O.insurance_claim = 'Y'
      AND EXTRACT(YEAR FROM PM.updated_at) = &v_year
    GROUP BY TO_CHAR(PM.updated_at, 'Month')
  ) A
WHERE PM.status = 'succeeded'
  AND EXTRACT(YEAR FROM PM.updated_at) = &v_year
  AND O.payment_id = PM.payment_id
  AND O.order_id = P.order_id
  AND O.insurance_id = I.insurance_id
  AND TO_CHAR(PM.updated_at, 'Month') = A."Month"
GROUP BY TO_CHAR(PM.updated_at, 'Month'), A."Loss"
ORDER BY "Profit (RM)" DESC;
