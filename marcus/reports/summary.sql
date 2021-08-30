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

CREATE OR REPLACE PROCEDURE rpt_top_customers IS
  -- Define error code
  -- ERR_CODE_FETCH_YEARS_FAILED CONSTANT NUMBER := -20066;
  -- ERR_CODE_FETCH_CUSTOMERS_FAILED CONSTANT NUMBER := -20067;

  -- Define exceptions
  -- e_fetch_years_failed EXCEPTION;
  -- e_fetch_customers_failed EXCEPTION;
  -- PRAGMA exception_init(e_fetch_years_failed, ERR_CODE_FETCH_YEARS_FAILED);
  -- PRAGMA exception_init(e_fetch_customers_failed, ERR_CODE_FETCH_CUSTOMERS_FAILED);

  -- Cursor for fetching customers
  CURSOR customers_cursor(in_top IN NUMBER, in_year IN NUMBER) IS
    SELECT 
      C.cust_id AS CustID, 
      C.name AS CustName,
      COUNT(PC.parcel_id) AS TotalOrder, 
      SUM(PM.amount) AS TotalAmount
    FROM "Customer" C, "Order" O, "Parcel" PC, "Payment" PM
    WHERE C.cust_id = O.cust_id
      AND PC.order_id = O.order_id 
      AND PM.payment_id = O.payment_id 
      AND EXTRACT(YEAR FROM PC.created_at) = in_year
    GROUP BY C.cust_id, C.name
    ORDER BY TotalOrder DESC
    FETCH FIRST in_top ROWS ONLY;

  -- Cursor for fetching all years
  CURSOR years_cursor IS
    SELECT DISTINCT EXTRACT(YEAR FROM created_at)  AS Year
    FROM "Parcel" 
    ORDER BY EXTRACT(YEAR FROM created_at);

  -- Variables
  v_index NUMBER;
BEGIN
  -- Print the header
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 72, '='));
  DBMS_OUTPUT.PUT_LINE(LPAD(' Top customers from each year ', 52, '-') || RPAD('-', 20, '-'));
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 72, '='));
  DBMS_OUTPUT.PUT_LINE('Accessed on ' || SYSDATE || '(' || TRIM(TO_CHAR(SYSDATE, 'DAY')) || ') by ' || USER || CHR(10));

  -- First loop will fetch the years
  FOR year_res IN years_cursor LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(' Year ' || year_res.Year || ' ', 41, '=') || RPAD('=', 31, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));
    DBMS_OUTPUT.PUT_LINE(LPAD('| ', 6, '-') || RPAD('Customer ID', 11, ' ') || RPAD(' | Customer Name', 23, ' ') || RPAD(' | Total Parcels', 15, ' ') || ' | Amount Spent |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));

    v_index := 0;
    -- Second loop fetch the top customers
    FOR customer IN customers_cursor(10, year_res.Year) LOOP
      v_index := v_index + 1;
      DBMS_OUTPUT.PUT_LINE(RPAD(v_index || '.', 3, ' ') || ' | ' || RPAD(customer.CustID, 11, ' ') || ' | ' || RPAD(customer.CustName, 20, ' ') || ' | ' || RPAD(customer.TotalOrder, 12, ' ') || ' | RM ' || RPAD(TO_CHAR(customer.TotalAmount, 'fm99999.90'), 6, ' ') || '    |');
    END LOOP;
    -- IF customers_cursor%NOTFOUND THEN
    --   RAISE_APPLICATION_ERROR(ERR_CODE_FETCH_CUSTOMERS_FAILED, 'Failed to fetch customers');
    -- END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
  END LOOP;
  -- IF years_cursor%NOTFOUND THEN
  --   RAISE_APPLICATION_ERROR(ERR_CODE_FETCH_YEARS_FAILED, 'Failed to fetch years');
  -- END IF;

  -- EXCEPTION
  --   WHEN e_fetch_years_failed THEN
  --     DBMS_OUTPUT.PUT_LINE('[FAILED] Something went wrong when trying to fetch years from "Parcel" table');
  --   WHEN e_fetch_customers_failed THEN
  --     DBMS_OUTPUT.PUT_LINE('[FAILED] Something went wrong when trying to fetch customers from "Customer", "Orderl", "Parce", "Payment" tables');
END;
/