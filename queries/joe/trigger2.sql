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

-- insert into "Address" (country, state, city, line1, line2, postal_code, created_at, updated_at) values ('Malaysia', 'Malacca', 'Sri Petaling', '0113 Briar Crest Terrace', '5 Village Plaza', '26620', '22/03/2021', '24/03/2021');