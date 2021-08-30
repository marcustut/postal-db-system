CREATE OR REPLACE VIEW insurance_claim AS
  SELECT
    TO_CHAR(PM.updated_at, 'Month') AS "Month",
    EXTRACT(YEAR FROM PM.updated_at) AS "Year",
    SUM(PM.amount * I.rate / 100) AS "Loss"
  FROM
    "Order" O, "Insurance" I, "Payment" PM
  WHERE O.insurance_id = I.insurance_id
    AND O.payment_id = PM.payment_id
    AND O.insurance_claim = 'Y'
  GROUP BY TO_CHAR(PM.updated_at, 'Month'), EXTRACT(YEAR FROM PM.updated_at)
  WITH READ ONLY CONSTRAINT insurance_claim_read_only;

-- SELECT IC."Month", IC."Loss"
-- FROM insurance_claim IC
-- WHERE IC."Year" = 2020;