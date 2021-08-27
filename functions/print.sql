-- WARNING: Not usable yet

CREATE OR REPLACE PROCEDURE func_print(type IN VARCHAR2, msg IN VARCHAR2) 
BEGIN
  -- CASE type
  --   WHEN 'success' THEN v_msg := '[' || UPPER(type) || '] ' || msg;
  --   WHEN 'failed' THEN v_msg := '[' || UPPER(type) || '] ' || msg;
  -- END

  IF type NOT IN ('success', 'failed') THEN
    RETURN '';
  ELSE
    v_msg := '[' || UPPER(type) || '] ' || msg;
  END IF;

  DBMS_OUTPUT.PUT_LINE(v_msg);

  RETURN v_msg;
END;