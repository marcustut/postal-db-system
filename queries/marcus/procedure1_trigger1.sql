-- Author: Marcus Lee Kai Yang

-- Oracle settings
SET SERVEROUTPUT ON

-- Clear screen
cl scr

-- Description
PROMPT This procedure is triggered on "Tracking" table when the inserted record is of status 'pending'.
PROMPT
PROMPT By running this, following four things will be created:
PROMPT 1. staff_id_allocation_seq (SEQUENCE)
PROMPT 2. vehicle_id_allocation_seq (SEQUENCE)
PROMPT 3. prc_assign_parcel_to_staff (PROCEDURE)
PROMPT 4. trg_create_delivery_for_new_tracking (TRIGGER)
PROMPT

-- Prompt Users whether to create procedure
PROMPT Enter 'Y' to continue or 'CTRL + C' to exit
ACCEPT allow CHAR PROMPT '>'

-- Drop things
DROP TRIGGER trg_create_delivery_for_new_tracking;
DROP PROCEDURE prc_assign_parcel_to_staff;
DROP SEQUENCE vehicle_id_allocation_seq;
DROP SEQUENCE staff_id_allocation_seq;

-- A sequence to allocate the next staff
CREATE SEQUENCE staff_id_allocation_seq
  MINVALUE 9001
  MAXVALUE 10000
  START WITH 9001
  INCREMENT BY 1
  CACHE 20
  CYCLE;

-- A sequence to allocate the next vehicle
CREATE SEQUENCE vehicle_id_allocation_seq
  MINVALUE 10001
  MAXVALUE 10500
  START WITH 10001
  INCREMENT BY 1
  CACHE 20
  CYCLE;

-- Procedure 1: This procedure will run after a parcel's tracking status is created
CREATE PROCEDURE prc_assign_parcel_to_staff(in_parcel_id IN NUMBER) IS
  -- Define delivery date offset
  DELIVERY_DATE_OFFSET CONSTANT NUMBER := 3;

  -- Define error code
  ERR_CODE_PAYMENT_NOT_SUCCEED CONSTANT NUMBER := -20021;
  ERR_CODE_CREATE_DELIVERY_FAILED CONSTANT NUMBER := -20022;

  -- Define exceptions
  e_payment_not_succeed EXCEPTION;
  e_create_delivery_failed EXCEPTION;
  PRAGMA exception_init(e_payment_not_succeed, ERR_CODE_PAYMENT_NOT_SUCCEED);
  PRAGMA exception_init(e_create_delivery_failed, ERR_CODE_CREATE_DELIVERY_FAILED);

  -- Define variables
  v_order_id "Order".order_id%TYPE;
  v_payment_id "Payment".payment_id%TYPE;
  v_payment_status "Payment".status%TYPE;
  v_delivery_id "Delivery".delivery_id%TYPE;
  v_delivery_date DATE;
BEGIN
  -- Fetch order_id from parcel table
  -- trigger 'no_data_found' exception if unable to fetch
  SELECT order_id
  INTO v_order_id
  FROM "Parcel"
  WHERE parcel_id = in_parcel_id;

  -- Fetch payment_id from order table
  SELECT payment_id, (SELECT created_at + DELIVERY_DATE_OFFSET FROM dual)
  INTO v_payment_id, v_delivery_date
  FROM "Order"
  WHERE order_id = v_order_id;

  -- Fetch payment status
  SELECT status
  INTO v_payment_status
  FROM "Payment"
  WHERE payment_id = v_payment_id;

  -- Check for whether payment is succeeded
  IF v_payment_status != 'succeeded' THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_PAYMENT_NOT_SUCCEED, 'Payment is not succeeded');
  END IF;

  -- Start a transacation for creating delivery
  SAVEPOINT create_delivery;

  -- Create a new delivery
  INSERT INTO "Delivery" (
    staff_id, 
    vehicle_id, 
    delivery_date
  ) VALUES (
    staff_id_allocation_seq.NEXTVAL, 
    vehicle_id_allocation_seq.NEXTVAL,
    v_delivery_date
  ) RETURNING delivery_id INTO v_delivery_id;

  -- If fail to create new delivery
  IF v_delivery_id IS NULL THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_CREATE_DELIVERY_FAILED, 'Unable to create delivery');
  END IF;

  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Delivery with id ' || v_delivery_id || ' is successfully created and is assigned to Staff with id ' 
                        || staff_id_allocation_seq.CURRVAL || ' with the Vehicle with id ' || vehicle_id_allocation_seq.CURRVAL);

  EXCEPTION
    WHEN no_data_found THEN
      DBMS_OUTPUT.PUT_LINE(
        CASE
          -- If unable to fetch from parcel
          WHEN v_order_id IS NULL THEN '[FAILED] Parcel ID ' || in_parcel_id || ' is invalid'
          -- If unable to fetch from order 
          WHEN v_payment_id IS NULL THEN '[FAILED] Unable to fetch payment for order ' || v_order_id
          -- If unable to fetch from order
          WHEN v_delivery_date IS NULL THEN '[FAILED] Order date is not defined in order ' || v_order_id
          -- if unable to fetch from payment
          WHEN v_payment_status IS NULL THEN '[FAILED] Unable to status for payment ' || v_payment_id
          -- any other case
          ELSE '[FAILED] Other data not found'
        END
      );
    WHEN e_payment_not_succeed THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] Payment for order ' || v_order_id || ' is ' || v_payment_status);
    WHEN e_create_delivery_failed THEN
      -- rollback to previous savepoint
      ROLLBACK TO create_delivery;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('[FAILED] Rollback-ed, so no data is modified or created');
END;
/

-- Trigger 1: This trigger will create a corresponding delivery when a new tracking is added
CREATE TRIGGER trg_create_delivery_for_new_tracking
AFTER INSERT ON "Tracking"
FOR EACH ROW
WHEN (new.status = 'pending')
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
  prc_assign_parcel_to_staff(:new.parcel_id);
  COMMIT;
END;
/

-- [VALID] INSERT INTO "Tracking" (status, remark, parcel_id) VALUES ('pending', 'valid test 1', 13001);
-- [INVALID] INSERT INTO "Tracking" (status, remark, parcel_id) VALUES ('canceled', 'invalid test 1', 13002);

-- [INVALID] exec prc_assign_parcel_to_staff(1300112312);
-- [VALID] exec prc_assign_parcel_to_staff(13001);
