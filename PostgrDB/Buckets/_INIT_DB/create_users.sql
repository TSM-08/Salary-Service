CREATE ROLE mgrpoc WITH
	LOGIN
	SUPERUSER
	CREATEDB
	CREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'mgr';
COMMENT ON ROLE mgrpoc IS 'POC Owner ';