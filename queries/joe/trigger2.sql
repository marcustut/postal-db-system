--Author: Tang Xiao Zu

CREATE OR REPLACE TRIGGER TRG_CHECK_CUS_AGE
BEFORE INSERT ON "Customer"
FOR EACH ROW

DECLARE
	c_age NUMBER;
	
BEGIN
	c_age := MONTHS_BETWEEN(SYSDATE, :NEW.DOB)/12;
	
	IF (c_age < 18) THEN
		RAISE_APPLICATION_ERROR(-20100, '[INVALID AGE] Record not inserted!');
	END IF;
	
	DBMS_OUTPUT.PUT_LINE(:NEW.name || 'Record inserted successfully!');
	
END;
/
