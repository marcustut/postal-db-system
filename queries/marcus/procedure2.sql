-- Author: Marcus Lee Kai Yang

-- Oracle settings
SET SERVEROUTPUT ON

-- Clear screen
cl scr

-- Description
PROMPT This procedure will help to make payment for a user-specifed order.
PROMPT
PROMPT By running this, following four things will be created
PROMPT 1. prc_make_payment (PROCEDURE)
PROMPT

-- Prompt Users whether to create procedure
PROMPT Enter 'Y' to continue or 'CTRL + C' to exit
ACCEPT allow CHAR PROMPT '>'

-- Drop first
DROP PROCEDURE prc_make_payment;

-- This procedure will help to make payment
CREATE PROCEDURE prc_make_payment(in_order_id IN NUMBER, in_credit IN NUMBER) IS
  -- Define error code
  ERR_CODE_PAYMENT_NOT_PROCESSING CONSTANT NUMBER := -20023;
  ERR_CODE_CREDIT_NOT_ENOUGH CONSTANT NUMBER := -20024;

  -- Define exceptions
  e_payment_not_processing EXCEPTION;
  e_credit_not_enough EXCEPTION;
  PRAGMA exception_init(e_payment_not_processing, ERR_CODE_PAYMENT_NOT_PROCESSING);
  PRAGMA exception_init(e_credit_not_enough, ERR_CODE_CREDIT_NOT_ENOUGH);

  -- Define variables
  v_payment_id "Payment".payment_id%TYPE;
  v_payment_status "Payment".status%TYPE;
  v_total_amount NUMBER;
  v_balance NUMBER;
BEGIN
  -- Fetch payment id from order
  SELECT payment_id
  INTO v_payment_id
  FROM "Order"
  WHERE order_id = in_order_id;

  -- Fetch the total amount to pay
  SELECT (amount + tax), status
  INTO v_total_amount, v_payment_status
  FROM "Payment"
  WHERE payment_id = v_payment_id;

  -- Raise exception if status is other than processing
  IF v_payment_status != 'processing' THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_PAYMENT_NOT_PROCESSING, 'Payment ' || v_payment_id || ' is not ''processing''');
  END IF;

  -- Raise exception if credit lesser than total amount
  IF in_credit < v_total_amount THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_CREDIT_NOT_ENOUGH, 'Credit of RM' || TO_CHAR(in_credit, 'FM99999.00') || ' is not enough');
  END IF;

  -- Update payment as succeeded
  UPDATE "Payment"
  SET status = 'succeeded', succeeded_at = SYSDATE
  WHERE payment_id = v_payment_id;

  -- Calculate the balance
  v_balance := in_credit - v_total_amount;

  -- Output result
  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Payment for order ' || in_order_id || ' is succeeded');
  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Payment ID:   ' || v_payment_id);
  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Credit:       RM' || TO_CHAR(in_credit, 'FM99999.00'));
  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Total amount: RM' || TO_CHAR(v_total_amount, 'FM99999.00'));
  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Balance:      RM' || TO_CHAR(v_balance, 'FM99999.00'));

  EXCEPTION
    WHEN no_data_found THEN
      DBMS_OUTPUT.PUT_LINE(
        CASE
          -- Unable to fetch from order
          WHEN v_payment_id IS NULL THEN '[FAILED] Order ID ' || in_order_id || ' is either invalid or have no ''payment_id'''
          -- Unable to fetch from payment
          WHEN v_total_amount IS NULL THEN '[FAILED] Unable to fetch amount from payment ' || v_payment_id
          WHEN v_payment_status IS NULL THEN '[FAILED] Unable to fetch status from payment ' || v_payment_id
        END
      );
    WHEN e_payment_not_processing THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] Payment of order ' || in_order_id || ' is already ''' || v_payment_status || '''');
    WHEN e_credit_not_enough THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] Total amount of order ' || in_order_id || ' is RM' || TO_CHAR(v_total_amount, 'FM99999.00'));
END;
/

-- [INVALID] 
-- 1. SAVEPOINT create_order;
-- 2. INSERT INTO "Order" (created_at) VALUES (SYSDATE);
-- 3. EXEC prc_make_payment(13001, 100); (Order have no payment_id)
-- 4. ROLLBACK TO create_order;
-- [INVALID] exec prc_make_payment(13000, 10); (Payment status is not processing)
-- [INVALID] exec prc_make_payment(12997, 10); (Credit not enough)
-- 
-- [VALID] exec prc_make_payment(12997, 100);

-- SELECT O.order_id, O.payment_id FROM "Order" O, "Payment" P WHERE O.payment_id = P.payment_id AND P.status = 'processing';