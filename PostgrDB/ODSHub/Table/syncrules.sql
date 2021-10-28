-- Table: docflow.syncrules

-- DROP TABLE docflow.syncrules;

CREATE TABLE docflow.syncrules
(
    sync_flag integer NOT NULL,
    pstat_from character varying COLLATE pg_catalog."default" NOT NULL,
    pstat_to character varying COLLATE pg_catalog."default" NOT NULL,
    sync_rule character varying COLLATE pg_catalog."default" NOT NULL,
    sync_ordr integer NOT NULL,
    sync_final bit(1) NOT NULL
)

TABLESPACE pg_default;

ALTER TABLE docflow.syncrules
    OWNER to mgrpoc;

COMMENT ON COLUMN docflow.syncrules.sync_flag
    IS 'Sync flag (bitmask: 1 - Regfile, 2- Prcfile)';

COMMENT ON COLUMN docflow.syncrules.pstat_from
    IS 'State from';

COMMENT ON COLUMN docflow.syncrules.pstat_to
    IS 'State to';

COMMENT ON COLUMN docflow.syncrules.sync_rule
    IS 'Sync rule (ANY/ALL)';

COMMENT ON COLUMN docflow.syncrules.sync_ordr
    IS 'Sync order';

COMMENT ON COLUMN docflow.syncrules.sync_final
    IS 'Is final state';