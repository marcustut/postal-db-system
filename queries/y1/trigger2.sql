CREATE OR REPLACE TRIGGER TRG_VALIDATE_EXPDATE
BEFORE UPDATE 
ON "Card"
FOR EACH ROW

DECLARE
c_exp_month  "Card".exp_month%type;
c_exp_year "Card".exp_year%type;
t_month "Card".exp_month%type;
t_year "Card".exp_year%type;

BEGIN
c_exp_month := :new.exp_month;
c_exp_year := :new.exp_year;
SELECT EXTRACT(MONTH FROM CURRENT_DATE) INTO t_month FROM "Card";
SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO t_year FROM "Card";



IF (c_exp_year < t_year) THEN
    RAISE_APPLICATION_ERROR (-200056,'Card had expired, try a new one.', true);
ELSIF (c_exp_year = t_year) THEN 
    IF (c_exp_month = t_month) THEN
        RAISE_APPLICATION_ERROR (-200057,'Card will be expired in this month, try a new one.',true);
    ELSIF (c_exp_month < t_month) THEN
        RAISE_APPLICATION_ERROR (-200056,'Card had expired, try a new one.', true);
    END IF;
END IF;
END;
/
