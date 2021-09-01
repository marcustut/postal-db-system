-- Author: Marcus Lee Kai Yang

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 72
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

-- Report (On demand): Show top customers give a year and quantity
CREATE OR REPLACE PROCEDURE rpt_top_customers(in_year IN NUMBER, in_top IN NUMBER) IS
  -- Define error code
  ERR_CODE_CUSTOMER_NOT_FOUND CONSTANT NUMBER := -20030;

  -- Define exceptions
  e_customer_not_found EXCEPTION;
  PRAGMA exception_init(e_customer_not_found, ERR_CODE_CUSTOMER_NOT_FOUND);

  -- Cursor for fetching customers
  CURSOR customers_cursor IS
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
    ORDER BY TotalAmount DESC
    FETCH FIRST in_top ROWS ONLY;

  -- Variables
  v_current_customer customers_cursor%ROWTYPE;
  v_top_customer customers_cursor%ROWTYPE;
BEGIN
  -- Print the title
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 72, '='));
  DBMS_OUTPUT.PUT_LINE(LPAD(' EasyDelivery''s top customers from year ' || in_year || ' ', 60, '-') 
                       || RPAD('-', 12, '-'));
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 72, '='));
  DBMS_OUTPUT.PUT_LINE('Accessed on ' || SYSDATE || '(' || TRIM(TO_CHAR(SYSDATE, 'DAY')) || ') by ' 
                       || USER || CHR(10));

  -- Print the header
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));
  DBMS_OUTPUT.PUT_LINE(LPAD('| ', 6, '-') || RPAD('Customer ID', 11, ' ') 
                            || RPAD(' | Customer Name', 23, ' ') 
                            || RPAD(' | Total Parcels', 15, ' ') || ' | Amount Spent |');
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));

  -- Open the cursor
  OPEN customers_cursor;

  -- Loop through each row in the cursor
  LOOP
    -- Get current row's data
    FETCH customers_cursor INTO v_current_customer;

    -- If row not found, raise an error
    IF customers_cursor%NOTFOUND AND customers_cursor%ROWCOUNT < in_top THEN
      RAISE_APPLICATION_ERROR(ERR_CODE_CUSTOMER_NOT_FOUND, 'Unable to fetch customer');
    END IF;

    -- Exit when reaches the end
    EXIT WHEN customers_cursor%NOTFOUND;

    -- Put the top customer into a variable
    IF customers_cursor%ROWCOUNT = 1 THEN
      v_top_customer := v_current_customer;
    END IF;

    -- Print the current row
    DBMS_OUTPUT.PUT_LINE(RPAD(customers_cursor%ROWCOUNT || '.', 3, ' ') || ' | ' || LPAD(v_current_customer.CustID, 11, ' ') 
                         || ' | ' || RPAD(v_current_customer.CustName, 20, ' ') || ' | ' 
                         || LPAD(v_current_customer.TotalOrder, 12, ' ') || ' | RM ' 
                         || LPAD(TO_CHAR(v_current_customer.TotalAmount, 'FM99999.90'), 9, ' ') || ' |');
  END LOOP;

  -- Close the cursor
  CLOSE customers_cursor;

  -- Print the summary text
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));
  DBMS_OUTPUT.PUT_LINE(CHR(10) || 'The top customer of ' || in_year || ' is ' 
                       || v_top_customer.CustName || '(' || v_top_customer.CustID || ') with a '
                       || 'total spending of RM ' 
                       || TO_CHAR(v_top_customer.TotalAmount, 'FM99999.90') || '.');

  EXCEPTION
    WHEN e_customer_not_found THEN
      DBMS_OUTPUT.PUT_LINE(CHR(10) || SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] No customers are found in year ' || in_year || ' or there are '
                           || 'less than ' || in_top || ' customers.');
END;
/

-- [VALID] exec rpt_top_customers(2020, 20);
-- [VALID] exec rpt_top_customers(2020, 10);
-- [INVALID] exec rpt_top_customers(2022, 20);