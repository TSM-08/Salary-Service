CREATE SCHEMA gpibase
    AUTHORIZATION gpuser;

COMMENT ON SCHEMA gpibase
    IS 'Database to support Swift API';

CREATE EXTENSION dblink;