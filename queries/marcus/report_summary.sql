-- Author: Marcus Lee Kai Yang
-- must create the 'insurance_claim' view first

-- Oracle settings
SET TERMOUT OFF 
SET LINESIZE 84
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

-- Clear screen
cl scr

CREATE OR REPLACE PROCEDURE rpt_earnings(in_year IN NUMBER) IS 
  -- Define error code
  ERR_CODE_EARNING_NOT_FOUND CONSTANT NUMBER := -20021;

  -- Define exceptions
  e_earning_not_found EXCEPTION;
  PRAGMA exception_init(e_earning_not_found, ERR_CODE_EARNING_NOT_FOUND);

  -- Earnings cursor
  CURSOR earnings_cursor IS
    SELECT
      TO_CHAR(PM.updated_at, 'Month') AS "Month",
      COUNT(P.parcel_id) AS "Parcel Delivered",
      SUM(PM.amount + PM.tax) AS "Sales (RM)",
      SUM(PM.tax) AS "Tax (RM)",
      IC."Loss" AS "Loss (RM)",
      SUM(PM.amount) - IC."Loss" AS "Profit (RM)"
    FROM
      "Parcel" P, 
      "Order" O, 
      "Payment" PM, 
      "Insurance" I,
      insurance_claim IC
    WHERE PM.status = 'succeeded'
      AND EXTRACT(YEAR FROM PM.updated_at) = in_year
      AND O.payment_id = PM.payment_id
      AND O.order_id = P.order_id
      AND O.insurance_id = I.insurance_id
      AND TO_CHAR(PM.updated_at, 'Month') = IC."Month"
      AND IC."Year" = in_year
    GROUP BY TO_CHAR(PM.updated_at, 'Month'), IC."Loss"
    ORDER BY "Profit (RM)" DESC;

  -- Variables for working with the cursor
  v_current_earning earnings_cursor%ROWTYPE;

  -- Variables for eaning figures
  v_total_parcel_delivered NUMBER := 0;
  v_total_sales NUMBER := 0;
  v_total_tax NUMBER := 0;
  v_total_loss NUMBER := 0;
  v_total_profit NUMBER := 0;

  -- Variables for calculating percentage
  v_percentage_total_sales NUMBER := 0;
  v_percentage_total_tax NUMBER := 0;
  v_percentage_total_loss NUMBER := 0;
  v_percentage_total_profit NUMBER := 0;
BEGIN
  -- Print the title
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 84, '='));
  DBMS_OUTPUT.PUT_LINE(LPAD(' EasyDelivery''s earnings breakdown of ' || in_year || ' ', 64, '-') 
                       || RPAD('-', 20, '-'));
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 84, '='));
  DBMS_OUTPUT.PUT_LINE('Accessed on ' || SYSDATE || '(' || TRIM(TO_CHAR(SYSDATE, 'DAY')) || 
                       ') by ' || USER || CHR(10));

  -- Print the header
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 84, '-'));
  DBMS_OUTPUT.PUT_LINE('| ' || RPAD('Month', 9, ' ') || ' | ' || RPAD('Parcel Delivered', 16, ' ') 
                        || ' | ' || RPAD('Sales (RM)', 11, ' ') || ' | ' || RPAD('Tax (RM)', 9, ' ') 
                        || ' | ' || RPAD('Loss (RM)', 9, ' ') || ' | ' || RPAD('Profit (RM)', 11, ' ')
                        || ' | ');
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 84, '-'));

  -- Open the cursor
  OPEN earnings_cursor;

  -- Loop through each row in the cursor
  LOOP
    -- Get current row's data
    FETCH earnings_cursor INTO v_current_earning;

    -- Raise exception when no row at all
    IF earnings_cursor%NOTFOUND AND earnings_cursor%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERR_CODE_EARNING_NOT_FOUND, 'Unable to fetch earning');
    END IF;

    -- Stop looping when reaches the end
    EXIT WHEN earnings_cursor%NOTFOUND;

    -- Increment the total figures
    v_total_parcel_delivered := v_total_parcel_delivered + v_current_earning."Parcel Delivered";
    v_total_sales := v_total_sales + v_current_earning."Sales (RM)";
    v_total_tax := v_total_tax + v_current_earning."Tax (RM)";
    v_total_loss := v_total_loss + v_current_earning."Loss (RM)";
    v_total_profit := v_total_profit + v_current_earning."Profit (RM)";

    -- Print the row
    DBMS_OUTPUT.PUT_LINE('| ' || RPAD(v_current_earning."Month", 9, ' ') || ' | ' 
                          || LPAD(v_current_earning."Parcel Delivered", 16, ' ') || ' | RM ' 
                          || LPAD(TO_CHAR(v_current_earning."Sales (RM)", 'FM99999.90'), 8, ' ') 
                          || ' | RM ' || LPAD(TO_CHAR(v_current_earning."Tax (RM)", 'FM99999.90'), 6, ' ') 
                          || ' | RM ' || LPAD(TO_CHAR(v_current_earning."Loss (RM)", 'FM99999.90'), 6, ' ')
                          || ' | RM ' || LPAD(TO_CHAR(v_current_earning."Profit (RM)", 'FM99999.90'), 8, ' ')
                          || ' |');
  END LOOP;

  -- Close the cursor
  CLOSE earnings_cursor;

  -- Calculate the percentage
  v_percentage_total_sales := (v_total_sales / v_total_sales) * 100;
  v_percentage_total_tax := (v_total_tax / v_total_sales) * 100;
  v_percentage_total_loss := (v_total_loss / v_total_sales) * 100;
  v_percentage_total_profit := (v_total_profit / v_total_sales) * 100;

  -- Print the total
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 84, '-'));
  DBMS_OUTPUT.PUT_LINE('| ' || LPAD('TOTAL', 9, ' ') || ' | ' 
                       || LPAD(v_total_parcel_delivered, 16, ' ')
                       || ' | RM ' || LPAD(TO_CHAR(v_total_sales, 'FM99999.90'), 8, ' ')
                       || ' | RM ' || LPAD(TO_CHAR(v_total_tax, 'FM99999.90'), 6, ' ') 
                       || ' | RM ' || LPAD(TO_CHAR(v_total_loss, 'FM99999.90'), 6, ' ') 
                       || ' | RM ' || LPAD(TO_CHAR(v_total_profit, 'FM99999.90'), 8, ' ') || ' |');
  -- Print the percentage
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 84, '-'));
  DBMS_OUTPUT.PUT_LINE('| ' || LPAD('SUMMARY IN PERCENTAGE', 28, ' ') || ' | ' 
                       || LPAD(TO_CHAR(v_percentage_total_sales, 'FM999.90') || '%', 11, ' ') 
                       || ' | ' || LPAD(TO_CHAR(v_percentage_total_tax, 'FM999.90') || '%', 9, ' ')
                       || ' | ' || LPAD(TO_CHAR(v_percentage_total_loss, 'FM999.90') || '%', 9, ' ')
                       || ' | ' || LPAD(TO_CHAR(v_percentage_total_profit, 'FM999.90') || '%', 11, ' ')
                       || ' |');
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 84, '-'));

  -- Print the summary
  DBMS_OUTPUT.PUT_LINE(CHR(10) || '[NOTE] Percentage is calculated assuming sales is the divisor.' || CHR(10));
  DBMS_OUTPUT.PUT_LINE('The company made ' || 'RM ' || TO_CHAR(v_total_profit, 'FM99999.90') || ' (' 
                       || TO_CHAR(v_percentage_total_profit, 'FM999.90') 
                       || '%) of profit from a total sales of RM ' 
                       || TO_CHAR(v_total_sales, 'FM99999.90') || ' (' 
                       || TO_CHAR(v_percentage_total_sales, 'FM999.90') || '%) in year ' || in_year
                       || '.');
  EXCEPTION
    WHEN e_earning_not_found THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] Unable to fetch earning for year ' || in_year);
END;
/

-- [VALID] rpt_earnings(2020);
-- [INVALID] rpt_earnings(2022);