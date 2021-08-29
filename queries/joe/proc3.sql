--Author: Tang Xiao Zu

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE ADD_ADDRESS_TO_CUSTOMER(vCountry IN VARCHAR2, vState IN VARCHAR2, vCity IN VARCHAR2, vLine1 IN VARCHAR2, vLine2 IN VARCHAR2, vPostCode IN CHAR, vCustID IN NUMBER) AS

E_CUSTID_NOT_FOUND EXCEPTION;
E_INVALID_STATE EXCEPTION;
E_INVALID_POSTCODE EXCEPTION;
E_INVALID_ADDRESSLINE EXCEPTION;
PRAGMA EXCEPTION_INIT(E_CUSTID_NOT_FOUND, -20100);
PRAGMA EXCEPTION_INIT(E_INVALID_STATE, -20101);
PRAGMA EXCEPTION_INIT(E_INVALID_POSTCODE, -20102);
PRAGMA EXCEPTION_INIT(E_INVALID_ADDRESSLINE, -20103);
v_address_id "Address".address_id%TYPE;
v_state "Address".state%TYPE;

BEGIN 
	IF (vState NOT IN('Johor','Kedah','Kelantan','Malacca','Negeri Sembilan','Pahang','Penang','Perak','Perlis','Sabah','Sarawak','Selangor',
	'Terengganu','W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya')) THEN
		RAISE_APPLICATION_ERROR(-20101,'[FAILED] State Error');
	ELSIF (LENGTH(vPostCode) != 5) THEN
		RAISE_APPLICATION_ERROR(-20102,'[FAILED] Post Code Error');
	ELSIF (LENGTH(vLine1) < 5) THEN
		RAISE_APPLICATION_ERROR(-20103,'[FAILED] Address Line Error');
	END IF;

	INSERT INTO "Address"(country, state, city, line1, line2, postal_code)
	VALUES(vCountry, vState, vCity, vLine1, vLine2, vPostCode)RETURNING address_id INTO v_address_id;
	
	UPDATE 
		"Customer"
	SET address_id = v_address_id
	WHERE cust_id = vCustID;  

	IF (SQL%NOTFOUND) THEN
		RAISE_APPLICATION_ERROR(-20100, '[ALERT]!');
	END IF;
	
	DBMS_OUTPUT.PUT_LINE('Successfully added address to '|| vCustID || ' customer.');

	EXCEPTION
		WHEN E_CUSTID_NOT_FOUND
			THEN
				DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
				DBMS_OUTPUT.PUT_LINE('-----------------------');
				DBMS_OUTPUT.PUT_LINE('| Cust ID Not Found ! |');
				DBMS_OUTPUT.PUT_LINE('-----------------------');
		WHEN E_INVALID_STATE
			THEN
				DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
				DBMS_OUTPUT.PUT_LINE('--------------------------');
				DBMS_OUTPUT.PUT_LINE('| No Such State Exists ! |');
				DBMS_OUTPUT.PUT_LINE('--------------------------');
		WHEN E_INVALID_POSTCODE
			THEN
				DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
				DBMS_OUTPUT.PUT_LINE('------------------------------');
				DBMS_OUTPUT.PUT_LINE('| No Such Post Code Exists ! |');
				DBMS_OUTPUT.PUT_LINE('------------------------------');
		WHEN E_INVALID_ADDRESSLINE
			THEN
				DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
				DBMS_OUTPUT.PUT_LINE('---------------------------');
				DBMS_OUTPUT.PUT_LINE('| Address Line Too Short! |');
				DBMS_OUTPUT.PUT_LINE('---------------------------');
END;
/


-- check state in malaysia 
-- check postal code if > 5 jiu false
-- check line1 if char < 5 jiu false
