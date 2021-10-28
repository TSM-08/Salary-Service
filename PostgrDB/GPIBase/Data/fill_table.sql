
INSERT INTO gpibase.gpreqstate(req_sttcd, req_sttnm, req_sttds)
	VALUES (0 , 'LOADING', null);

INSERT INTO gpibase.gpreqstate(req_sttcd, req_sttnm, req_sttds)
	VALUES (1 , 'SUCCESS', null);

INSERT INTO gpibase.gpreqstate(req_sttcd, req_sttnm, req_sttds)
	VALUES (-1, 'CANCEL', null);

INSERT INTO gpibase.gpreqstate(req_sttcd, req_sttnm, req_sttds)
	VALUES (-2, 'FAILURE', null);



INSERT INTO gpibase.gpreqtype (req_typcd, req_typnm, req_typds)
	VALUES (0, 'Default', null);