--Author: Wong Wai Yi

SET TERMOUT OFF 
SET LINESIZE 120
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET TERMOUT ON
SET VERIFY OFF


CREATE OR REPLACE VIEW insurance_claim_view as 
    select insurance_id, COUNT(insurance_id) as i_claim
    FROM "Order"
    WHERE insurance_claim= 'Y' AND EXTRACT(YEAR FROM created_at) = 2019
    GROUP BY insurance_id;
CREATE OR REPLACE PROCEDURE RPT_INSURANCE(IN_YEAR IN number) IS 
i_ins_percent number;
i_total_percent number:=0;
i_total_type number:=0; 
i_total_claim number:=0;


CURSOR INSURANCE_ORDER_CURSOR IS 
    SELECT I.insurance_id AS "i_ins_id", I.type AS "i_ins_type", I.price AS "i_ins_price", V.i_claim as "i_claim_no", COUNT(I.type) AS "i_type_no", COUNT(I.type)/(
        SELECT COUNT(insurance_id) FROM "Order" WHERE EXTRACT(YEAR FROM created_at) = IN_YEAR
    ) * 100 AS i_ins_percent
    FROM "Insurance" I, "Order" O, insurance_claim_view V
    WHERE I.insurance_id = O.insurance_id AND EXTRACT(YEAR FROM O.created_at) = IN_YEAR AND I.insurance_id = V.insurance_id
    GROUP BY I.insurance_id, I.type, I.price, V.i_claim
    ORDER BY I.insurance_id;
ins_rec INSURANCE_ORDER_CURSOR%ROWTYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('DATE',10,' ')||':'||SYSDATE);
    DBMS_OUTPUT.PUT_LINE(RPAD('DAY',10,' ')||':'||TO_CHAR(SYSDATE,'DAY'));
    DBMS_OUTPUT.PUT_LINE(chr(10));
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    DBMS_OUTPUT.PUT_LINE('|Insurance Rate for '||IN_YEAR||' year|');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');

DBMS_OUTPUT.PUT_LINE(
        RPAD('Insurance ID',15)||
        RPAD('Insurance Type',20)||
        RPAD('Insurance Price (RM)',20)||
        RPAD('Quantity Sold',20)||
        RPAD('Percentage',15)||
        RPAD('Quantity Claim',20)
        );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('-',14,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',14,'-')||' '||
        RPAD('-',20,'-')
    );
    OPEN INSURANCE_ORDER_CURSOR;
    LOOP
    FETCH INSURANCE_ORDER_CURSOR INTO ins_rec;
    EXIT WHEN INSURANCE_ORDER_CURSOR%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(
        RPAD(ins_rec."i_ins_id",15)||
        RPAD(ins_rec."i_ins_type",20)||
        RPAD(ins_rec."i_ins_price",20)||
        RPAD(ins_rec."i_type_no",20)||
        RPAD(TRIM(TO_CHAR(ins_rec.i_ins_percent,'90D9')),4,' ')||'%'||
        RPAD(' ',10,' ')||
        RPAD(ins_rec."i_claim_no",20)
        );

    
    DBMS_OUTPUT.PUT_LINE(
        RPAD('-',14,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',19,'-')||' '||
        RPAD('-',14,'-')||' '||
        RPAD('-',20,'-')
    );
    i_total_type:=i_total_type + ins_rec."i_type_no";
    i_total_claim:=i_total_claim + ins_rec."i_claim_no";
    i_total_percent:=i_total_percent + ins_rec.i_ins_percent;
    END LOOP;
    CLOSE INSURANCE_ORDER_CURSOR;

    DBMS_OUTPUT.PUT_LINE(
        RPAD(' ',50,'-')|| 'Total:' ||
        RPAD(i_total_type,20,' ')||
        RPAD(TRIM(TO_CHAR(i_total_percent,'990')),3,' ')||'%'||
        RPAD(' ',12,' ')||
        RPAD(i_total_claim,10,' ')
        );
    END;
    /


--EXEC RPT_INSURANCE(2021);