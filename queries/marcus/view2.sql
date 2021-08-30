CREATE OR REPLACE VIEW branch_parcels AS
  SELECT
    A.state AS "State", 
    T.status AS "Status",
    EXTRACT(YEAR FROM T.created_at) AS "Year",
    COUNT(P.parcel_id) AS "Quantity"
  FROM 
    "Tracking" T, 
    "Parcel" P, 
    "Address" A
  WHERE T.parcel_id = P.parcel_id
    AND A.address_id = P.address_id
  GROUP BY A.state, T.status, EXTRACT(YEAR FROM T.created_at)
  ORDER BY A.state
  WITH READ ONLY CONSTRAINT branch_parcels_read_only;
