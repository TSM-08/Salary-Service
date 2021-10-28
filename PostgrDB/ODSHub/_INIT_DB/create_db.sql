CREATE DATABASE odshub
    WITH 
    OWNER = mgrpoc
    ENCODING = 'UTF8'
--    LC_COLLATE = 'English_United States.1251'
--    LC_CTYPE = 'English_United States.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE odshub
    IS 'DB for Salary Module';