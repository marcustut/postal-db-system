-- Function 1: Return the formatted percentage string
CREATE OR REPLACE FUNCTION func_percentage(
  dividend IN NUMBER,
  divisor IN NUMBER
)
RETURN VARCHAR2
IS
BEGIN
  RETURN TO_CHAR(dividend / divisor * 100, 'FM990.90') || '%';
END;
/
