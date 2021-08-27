CREATE OR REPLACE TRIGGER TRG_UPDATE_PARCEL_DATE
AFTER UPDATE OR order_id
ON "Parcel"
FOR EACH ROW

BEGIN 
UPDATE "Parcel" SET updated_at = sysdate WHERE parcel_id = :old.parcel_ID;

END;
/