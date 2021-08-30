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
PROMPT This is a summary report of how many parcels are cancelled and delivered
PROMPT from 01/01/2019 until now
PROMPT

CREATE OR REPLACE PROCEDURE rpt_parcels IS
  -- Define error code
  ERR_CODE_FETCH_TOTAL_FAILED CONSTANT NUMBER := -20065;

  -- Define execeptions
  e_fetch_total_failed EXCEPTION;
  PRAGMA exception_init(e_fetch_total_failed, ERR_CODE_FETCH_TOTAL_FAILED);

  -- Cursor to get the category
  CURSOR category_cursor IS
    SELECT DISTINCT
      T.status AS Status, 
      EXTRACT(YEAR FROM t.created_at) AS Year
    FROM 
      "Tracking" T
    WHERE T.status IN ('canceled', 'delivered')
    ORDER BY EXTRACT(YEAR FROM t.created_at);

  -- Cursor to get the number of tracking each state
  CURSOR result_cursor(in_status IN VARCHAR2, in_year IN NUMBER) IS
    SELECT
      A.state AS State, 
      COUNT(P.parcel_id) AS Quantity
    FROM 
      "Tracking" T, 
      "Parcel" P, 
      "Address" A
    WHERE T.parcel_id = P.parcel_id
      AND A.address_id = P.address_id
      AND T.status = in_status
      AND EXTRACT(YEAR FROM t.created_at) = in_year
    GROUP BY A.state
    ORDER BY A.state;

  -- Cursor to get the total number of tracking
  CURSOR total_cursor(in_status IN VARCHAR2, in_year IN NUMBER) IS
    SELECT COUNT(tracking_id) AS Total
    FROM "Tracking"
    WHERE EXTRACT(YEAR FROM created_at) = in_year
      AND status = in_status;
  
  v_total NUMBER;
BEGIN
  -- Printing the header
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 59, '='));
  DBMS_OUTPUT.PUT_LINE(LPAD(' Total parcels canceled and delivered ', 47, '-') || RPAD('-', 12, '-'));
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 59, '='));
  DBMS_OUTPUT.PUT_LINE('Accessed on ' || SYSDATE || '(' || TRIM(TO_CHAR(SYSDATE, 'DAY')) || ') by ' || USER || CHR(10));

  -- Fetch the category first
  FOR category IN category_cursor LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 59, '-'));
    DBMS_OUTPUT.PUT_LINE('| Year: ' || RPAD(category.Year, 14, ' ') || ' | Status: ' || RPAD(category.Status, 24, ' ') || ' |');

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 59, '-'));
    DBMS_OUTPUT.PUT_LINE('| ' || RPAD('State', 20, ' ') || ' | ' || RPAD('Total Parcel', 32, ' ') || ' |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 59, '-'));

    -- for each category, fetch all the state and quantity
    FOR result IN result_cursor(category.Status, category.Year) LOOP
      DBMS_OUTPUT.PUT_LINE('| ' || RPAD(result.State, 20, ' ') || ' | ' || RPAD(LPAD(result.Quantity, 3, ' '), 33, ' ') || '|');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 59, '-'));

    -- Fetch the total tracking for this year
    OPEN total_cursor(category.Status, category.Year);
    FETCH total_cursor INTO v_total;
    IF total_cursor%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERR_CODE_FETCH_TOTAL_FAILED, 'Failed to get total tracking for ''' || category.Status || ''' of year ' || category.Year);
    END IF;
    CLOSE total_cursor;

    DBMS_OUTPUT.PUT_LINE('|' || LPAD('| ' || LPAD(v_total, 3, ' '), 27, ' '));

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 59, '-') || CHR(10));
  END LOOP;

  EXCEPTION
  WHEN e_fetch_total_failed THEN
    DBMS_OUTPUT.PUT_LINE('[FAILED] Something went wrong when trying to fetch total from "Tracking" table');
END;
/