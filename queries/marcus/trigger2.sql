-- Author: Marcus Lee Kai Yang
-- must create the 'is_number' function first

-- Trigger 2: This trigger will validate an address before it is inserted
CREATE OR REPLACE TRIGGER trg_validate_address
BEFORE INSERT OR UPDATE ON "Address"
FOR EACH ROW
DECLARE
  -- Define types
  TYPE countriesarray IS TABLE OF VARCHAR2(30);
  TYPE statesarray IS TABLE OF VARCHAR2(30);

  -- Define constants
  ALLOWED_COUNTRIES CONSTANT countriesarray := countriesarray ('malaysia');
  ALLOWED_STATES CONSTANT statesarray := statesarray (
    'johor', 
    'kedah', 
    'kelantan', 
    'malacca', 
    'negeri sembilan',
    'pahang',
    'penang',
    'perak',
    'perlis',
    'sabah',
    'sarawak',
    'selangor',
    'terengganu',
    'w.p. kuala lumpur',
    'w.p. labuan',
    'w.p. putrajaya'
  );

  -- Define error code
  ERR_CODE_COUNTRY_NOT_ALLOWED CONSTANT NUMBER := -20025;
  ERR_CODE_STATE_NOT_ALLOWED CONSTANT NUMBER := -20026;
  ERR_CODE_INVALID_POSTAL_CODE CONSTANT NUMBER := -20027;

  -- Define exceptions
  e_country_not_allowed EXCEPTION;
  e_state_not_allowed EXCEPTION;
  e_invalid_postal_code EXCEPTION;
  PRAGMA exception_init(e_country_not_allowed, ERR_CODE_COUNTRY_NOT_ALLOWED);
  PRAGMA exception_init(e_state_not_allowed, ERR_CODE_STATE_NOT_ALLOWED);
  PRAGMA exception_init(e_invalid_postal_code, ERR_CODE_INVALID_POSTAL_CODE);
BEGIN 
  IF LOWER(:NEW.country) NOT MEMBER OF ALLOWED_COUNTRIES THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_COUNTRY_NOT_ALLOWED, 'country ''' || :NEW.country || ''' is not allowed.');
  END IF;

  IF LOWER(:NEW.state) NOT MEMBER OF ALLOWED_STATES THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_STATE_NOT_ALLOWED, 'state ''' || :NEW.state || ''' is not allowed.');
  END IF;

  IF LENGTH(:NEW.postal_code) != 5 THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_STATE_NOT_ALLOWED, 'postal code ''' || :NEW.postal_code || ''' does not have 5 numbers.');
  END IF;

  IF is_number(:NEW.postal_code) != 'Y' THEN
    RAISE_APPLICATION_ERROR(ERR_CODE_STATE_NOT_ALLOWED, 'postal code ''' || :NEW.postal_code || ''' is not a number.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('[SUCCESS] Address is successfully created.');
END;
/