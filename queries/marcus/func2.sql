-- Function 2: Check if a string is number
CREATE OR REPLACE FUNCTION is_number(
  in_string IN VARCHAR2
)
  RETURN CHAR
IS
  v_new_num NUMBER;
BEGIN
  v_new_num := TO_NUMBER(in_string);
  RETURN 'Y';

  EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN 'N';
END;
/