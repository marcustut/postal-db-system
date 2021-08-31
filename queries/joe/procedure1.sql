--Author: Tang Xiao Zu

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF

CREATE OR REPLACE PROCEDURE PRC_UPDATE_STATUS(track_id IN NUMBER, track_status IN VARCHAR2)IS
	E_STATUS_NOT_EXISTS EXCEPTION;
	E_STATUS_DELIVERING_ERROR EXCEPTION;
	E_STATUS_DELIVERED_ERROR EXCEPTION;
	E_STATUS_CANCELED_ERROR EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_STATUS_NOT_EXISTS, -20000);
	PRAGMA EXCEPTION_INIT(E_STATUS_DELIVERING_ERROR, -20001);
	PRAGMA EXCEPTION_INIT(E_STATUS_DELIVERED_ERROR, -20002);
	PRAGMA EXCEPTION_INIT(E_STATUS_CANCELED_ERROR, -20003);
	c_status "Tracking".status%TYPE;
	
BEGIN 
	--get tracking id from Tracking table--
	SELECT status INTO c_status
	FROM "Tracking"
	WHERE tracking_id = track_id; 

	--check if the status is the same or not--
	IF track_status = c_status THEN
		RAISE_APPLICATION_ERROR(-20000, '[FAILED]Status Update');
	END IF;
	
	IF (c_status = 'delivering' AND track_status IN ('pending','canceled')) THEN
		RAISE_APPLICATION_ERROR(-20001, '[FAILED]Status delivering in ' || track_id || ' cannot update to pending!');
	ELSIF (c_status = 'canceled' AND track_status IN('pending','delivering','delivered')) THEN
		RAISE_APPLICATION_ERROR(-20003, '[FAILED]Status canceled in ' || track_id || ' cannot update to any other status!');
	ELSIF (c_status = 'delivered' AND track_status IN('pending', 'delivering', 'canceled')) THEN
		RAISE_APPLICATION_ERROR(-20002, '[FAILED]No updating in ' || track_id || ' allowed for delivered!');
	END IF;
	
	--if not, update--
	UPDATE "Tracking"
	SET status = track_status
	WHERE tracking_id = track_id;
	
	DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE('[SUCCESS]Status of tracking number ' || track_id || ' is updated to ' || track_status);
	DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------');
	
	EXCEPTION
		WHEN E_STATUS_NOT_EXISTS THEN
			DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('Status of tracking number ' || track_id || ' match with the old one');
		WHEN E_STATUS_DELIVERING_ERROR THEN
			DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('------------------------');
			DBMS_OUTPUT.PUT_LINE('| ! Delivering Error ! |');
			DBMS_OUTPUT.PUT_LINE('------------------------');
		WHEN E_STATUS_DELIVERED_ERROR THEN
			DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('-----------------------');
			DBMS_OUTPUT.PUT_LINE('| ! Delivered Error ! |');
			DBMS_OUTPUT.PUT_LINE('-----------------------');
		WHEN E_STATUS_CANCELED_ERROR THEN
			DBMS_OUTPUT.PUT_LINE('An error was encountered ' || chr(10) || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('----------------------');
			DBMS_OUTPUT.PUT_LINE('| ! Canceled Error ! |');
			DBMS_OUTPUT.PUT_LINE('----------------------');
END;
/		

--pending can go to any status, but other status cannot go back to pending.
--delivering cannot go to pending
--canceled cannot go to pending, delivering, delivered
--delivered cannot go to pending, delivering, canceled
 


