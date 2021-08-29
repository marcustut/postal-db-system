--Author: Tang Xiao Zu

CREATE OR REPLACE TRIGGER TRG_UPDATE_TRACKING_STATUS 
AFTER UPDATE ON "Order"

DECLARE
    u_orderid "Order".order_id%TYPE;
    u_parcelid "Parcel".parcel_id%TYPE;
    u_trackingid "Tracking".tracking_id%TYPE;

BEGIN
	u_orderid := :NEW.order_id; 

    SELECT parcel_id INTO u_parcelid
    FROM "Parcel" Pa, "Order" O
    WHERE Pa.parcel_id = O.parcel_id AND O.order_id = u_orderid;

    SELECT tracking_id INTO u_trackingid
    FROM "Tracking" Tr, "Parcel" Pa
    WHERE Tr.parcel_id = Pa.parcel_id AND Tr.parcel_id = u_parcelid; 

    UPDATE "Tracking"
    SET status = 'canceled'
    WHERE tracking_id = u_trackingid; 

END;
/