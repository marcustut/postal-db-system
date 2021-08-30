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

  -- Cursor to get the year
  CURSOR years_cursor IS
    SELECT DISTINCT
      EXTRACT(YEAR FROM t.created_at) AS Year
    FROM 
      "Tracking" T
    ORDER BY EXTRACT(YEAR FROM t.created_at);

  -- Cursor to get the
  CURSOR branch_parcels_cursor(in_year IN NUMBER) IS
    SELECT DISTINCT
      A.state AS "State",
      COALESCE((
        SELECT "Quantity"
        FROM (
          SELECT "Quantity", "State"
          FROM branch_parcels BP
          WHERE BP."Status" = 'canceled'
            AND BP."Year" = in_year
        )
        WHERE "State" = A.State
      ), 0) "Canceled",
      COALESCE((
        SELECT "Quantity"
        FROM (
          SELECT "Quantity", "State"
          FROM branch_parcels BP
          WHERE BP."Status" = 'delivered'
            AND BP."Year" = in_year
        )
        WHERE "State" = A.State
      ), 0) "Delivered"
    FROM
      "Address" A
    ORDER BY "Canceled" DESC, "Delivered" DESC;

  -- Cursor to get the total number of tracking
  CURSOR total_cursor(in_status IN VARCHAR2, in_year IN NUMBER) IS
    SELECT COUNT(tracking_id) AS Total
    FROM "Tracking"
    WHERE EXTRACT(YEAR FROM created_at) = in_year
      AND status = in_status;
  
  v_total NUMBER;
  v_total_canceled NUMBER;
  v_total_delivered NUMBER;

  v_percentage_total_canceled NUMBER;
  v_percentage_total_delivered NUMBER;
BEGIN
  -- Printing the header
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 63, '='));
  DBMS_OUTPUT.PUT_LINE(LPAD(' Total parcels canceled and delivered ', 49, '-') || RPAD('-', 14, '-'));
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 63, '='));
  DBMS_OUTPUT.PUT_LINE('Accessed on ' || SYSDATE || '(' || TRIM(TO_CHAR(SYSDATE, 'DAY')) || ') by ' || USER || CHR(10));

  -- Fetch the category first
  FOR year_rec IN years_cursor LOOP
    -- Fetch the total tracking of 'canceled' for this year
    OPEN total_cursor('canceled', year_rec.Year);
    FETCH total_cursor INTO v_total_canceled;
    IF total_cursor%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERR_CODE_FETCH_TOTAL_FAILED, 'Failed to get total tracking for ''' 
                              || 'canceled' || ''' of year ' || year_rec.Year);
    END IF;
    CLOSE total_cursor;

    -- Fetch the total tracking of 'delivered' for this year
    OPEN total_cursor('delivered', year_rec.Year);
    FETCH total_cursor INTO v_total_delivered;
    IF total_cursor%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERR_CODE_FETCH_TOTAL_FAILED, 'Failed to get total tracking for ''' 
                              || 'delivered' || ''' of year ' || year_rec.Year);
    END IF;
    CLOSE total_cursor;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 63, '-'));
    DBMS_OUTPUT.PUT_LINE('| Year: ' || RPAD(year_rec.Year, 53, ' ') || ' |');

    -- Print the header
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 63, '-'));
    DBMS_OUTPUT.PUT_LINE('| ' || RPAD('State', 20, ' ') || ' | ' 
                         || RPAD('Parcels Canceled', 16, ' ') || ' | ' 
                         || RPAD('Parcels Delivered', 17, ' ') || ' |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 63, '-'));

    -- for each category, fetch all the state and quantity
    FOR branch_parcel IN branch_parcels_cursor(year_rec.Year) LOOP
      DBMS_OUTPUT.PUT_LINE('| ' || RPAD(branch_parcel."State", 20, ' ') || ' | ' 
                           || LPAD(branch_parcel."Canceled" || ' (' 
                           || LPAD(TO_CHAR(branch_parcel."Canceled" / v_total_canceled * 100, 'FM990.90'), 5, ' ') 
                           || '%)', 16, ' ') || ' | ' || LPAD(branch_parcel."Delivered" || ' (' 
                           || LPAD(TO_CHAR(branch_parcel."Delivered" / v_total_delivered * 100, 'FM990.90'), 5, ' ') 
                           || '%)', 17, ' ') || ' |');
    END LOOP;

    v_total := v_total_canceled + v_total_delivered;
    v_percentage_total_canceled := v_total_canceled / v_total * 100;
    v_percentage_total_delivered := v_total_delivered / v_total * 100;

    -- Print the total
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 63, '-'));
    DBMS_OUTPUT.PUT_LINE('| ' || LPAD('TOTAL', 20, ' ') || ' | ' || LPAD(v_total_canceled || ' (' 
                         || LPAD(TO_CHAR(v_percentage_total_canceled, 'FM990.90'), 6, ' ') 
                         || '%)', 16, ' ') || ' | ' || LPAD(v_total_delivered || ' (' 
                         || LPAD(TO_CHAR(v_percentage_total_delivered, 'FM990.90'), 6, ' ') 
                         || '%)', 17, ' ') || ' |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 63, '-'));

    DBMS_OUTPUT.PUT_LINE(CHR(10) || TO_CHAR(v_percentage_total_canceled, 'FM990.90') 
                         || '% parcels is canceled and ' || TO_CHAR(v_percentage_total_delivered, 'FM990.90')
                         || '% parcels is delivered in ' || year_rec.Year || '.' || CHR(10));
  END LOOP;

  EXCEPTION
  WHEN e_fetch_total_failed THEN
    DBMS_OUTPUT.PUT_LINE('[FAILED] Something went wrong when trying to fetch total from "Tracking" table');
END;
/

exec rpt_parcels();
