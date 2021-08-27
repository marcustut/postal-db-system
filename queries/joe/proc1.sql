CREATE OR REPLACE PROCEDURE PRC_UPDATE_STATUS(track_id IN NUMBER, track_status IN VARCHAR2)IS
	E_STATUS_NOT_EXISTS EXCEPTION;
	E_STATUS_DELIVERING_ERROR EXCEPTION;
	E_STATUS_DELIVERED_ERROR EXCEPTION;
	E_STATUS_CANCELED_ERROR EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_STATUS_NOT_EXISTS, -20061);
	PRAGMA EXCEPTION_INIT(E_STATUS_DELIVERING_ERROR, -20062);
	PRAGMA EXCEPTION_INIT(E_STATUS_DELIVERED_ERROR, -20063);
	PRAGMA EXCEPTION_INIT(E_STATUS_CANCELED_ERROR, -20064);
	c_status "Tracking".status%TYPE;
	
BEGIN 
	--get tracking id from Tracking table--
	SELECT status INTO c_status
	FROM "Tracking"
	WHERE tracking_id = track_id; 

	--check if the status is the same or not--
	IF track_status = c_status THEN
		RAISE_APPLICATION_ERROR(-20061, '[FAILED]Status Update');
	END IF;
	
	IF (c_status = 'delivering' AND track_status = 'pending') THEN
		RAISE_APPLICATION_ERROR(-20062, '[FAILED]Status delivering in ' || track_id || ' cannot update to pending!');
	ELSIF (c_status = 'canceled' AND track_status IN('pending','delivering','delivered')) THEN
		RAISE_APPLICATION_ERROR(-20064, '[FAILED]Status canceled in ' || track_id || ' cannot update to any other status!');
	ELSIF (c_status = 'delivered' AND track_status IN('pending', 'delivering', 'canceled')) THEN
		RAISE_APPLICATION_ERROR(-20063, '[FAILED]No updating in ' || track_id || ' allowed for delivered!');
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
 

	

