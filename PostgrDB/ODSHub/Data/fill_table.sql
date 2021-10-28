INSERT INTO docflow.apchanel(chnl_id, chnl_code, chnl_name) 
VALUES (1, 'ISCARD', 'Card system');

INSERT INTO docflow.apchanel(chnl_id, chnl_code, chnl_name) 
VALUES (2, 'SWIFT', 'SWIFT system');


INSERT INTO docflow.pfiletype(ftype_code, ftype_desc, ftype_id, ftype_fmt)
SELECT 'INTERNAL', 'Internal format', 1, 'json'
UNION ALL
SELECT 'FILE1', 'Payment AVAL' , 2, 'json'
UNION ALL
SELECT 'FILE2', 'Payment SWIFT', 3, 'json';


insert into docflow.customer(clnt_code, clnt_name)
select 'CL01', 'Client N1';

INSERT INTO docflow.cproject(proj_code, proj_desc, clnt_id, ftype_id, chnl_id)
VALUES('SAL01', 'Salary Project' , 1, 2, 1);

INSERT INTO docflow.cproject(proj_code, proj_desc, clnt_id, ftype_id, chnl_id)
VALUES('SWIFT', 'Payment Project', 1, 3, 2);



INSERT INTO docflow.procstate(
       pstat_code, pstat_flag, pstat_final, pstat_desc)

SELECT 'REG', 1, '0'::bit, 'File is registered.'
union 
SELECT 'DCL', 1, '1'::bit, 'Declined. Not accepted to be processed'
union 
SELECT 'ERR', 7, '1'::bit, 'Rejected. Found critical errors during processing'
union 
SELECT 'TKN', 6, '0'::bit, 'Taken. Accepted to be processed'
union 
SELECT 'TKN.01', 2, '0'::bit, 'Taken again'
union 
SELECT 'DLQ', 2, '0'::bit, 'Posponed. In DLQ queue'
union 
SELECT 'PRC', 7, '1'::bit, 'Processed. No errors.'
union 
SELECT 'PRC.00', 7, '0'::bit, 'In progress'
union 
SELECT 'PRC.01', 3, '0'::bit, 'Processed with warnings'
union 
SELECT 'PRC.02', 3, '0'::bit, 'Processed with errors';


INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(3, 'PRC.00', 'PRC.00', 'ANY', 1, '0');
INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(3, 'PRC', 'PRC', 'ALL', 4, '1');
INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(3, 'PRC.01', 'PRC.01', 'ANY', 3, '1');
INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(2, 'ERR,PRC.02', 'PRC.02', 'ANY', 2, '1');
INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(1, 'ERR', 'ERR', 'ALL', 2, '1');
INSERT INTO docflow.syncrules
(sync_flag, pstat_from, pstat_to, sync_rule, sync_ordr, sync_final)
VALUES(1, 'PRC.02', 'PRC.02', 'ALL', 2, '1');


INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(0, 'NULL_TYPE', '');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(1, 'LONG_TYPE', 'int');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(2, 'STRING_TYPE', 'varchar');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(3, 'BOOL_TYPE', 'bit');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(4, 'BYTE_TYPE', 'smallint');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(5, 'FLOAT_TYPE', 'float');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(6, 'DOUBLE_TYPE', 'float');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(7, 'RATION_TYPE', 'float');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(8, 'BINARY_TYPE', 'binary');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(9, 'DATE_TYPE', 'datetime');
INSERT INTO docflow."datatype" (datp_id, datp_code, datp_desc)
VALUES(10, 'TIME_TYPE', 'datetime');


INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(1, 'DOCUMENT_ID', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(2, 'PROJECT_CODE', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(3, 'CUSTOMER_CODE', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(4, 'ENROLL_TYPE', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(5, 'CLIENT_OKPO', NULL, 1);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(6, 'TRANS_ACCOUNT', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(7, 'TOTAL_RECORDS', NULL, 1);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(8, 'RECORD_NUMBER', NULL, 1);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(9, 'CARD_ACCOUNT', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(10, 'FULL_NAME', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(11, 'FIRST_NAME', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(12, 'LAST_NAME', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(13, 'MIDDLE_NAME', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(14, 'EMPLOYEE_CODE', NULL, 2);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(15, 'EMPL_AMOUNT', NULL, 5);
INSERT INTO docflow.attrbase (attr_id, attr_code, attr_desc, datp_id)
VALUES(16, 'EMPL_COMMENT', NULL, 2);


INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(17, 'DOC_DATE', 9, 'Дата документа');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(18, 'DOC_NUMBER', 2, 'Номер документа');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(19, 'PAYM_ACCOUNT', 2, 'С какого счета осуществляется платеж');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(20, 'COMM_ACCOUNT', 2, 'С какого счета списывается комиссия');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(21, 'CLIENT_NAME', 2, 'Наименование плательщика');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(22, 'CLIENT_ADDR', 2, 'Адрес плательщика ');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(23, 'CCY_TO_BUY', 2, 'Трехбуквенный код валюты (например USD) которая покупается частично');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(24, 'CCY_TO_SEL', 2, 'Трехбуквенный код валюты (например EUR) которая продается USD');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(25, 'CONV_NUMBER', 2, 'Номер заявки на конвертацию');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(26, 'PRT_AMOUNT', 5, 'Частичная сумма');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(27, 'CCY_PAYMENT', 2, 'Трехбуквенный код валюты (например USD) платежа USD');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(28, 'CCY_COMMISS', 2, 'Трехбуквенный код валюты, всегда UAH, комиссии платежа UAH');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(29, 'PAYM_AMOUNT', 5, 'Cумма платежа 5550.00');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(30, 'BENF_ACCOUNT', 2, 'Cчет получателя AD2222222134');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(31, 'BENF_NAME', 2, 'Наименование получателя');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(32, 'BENF_ADDR', 2, 'Адрес получателя Adres s');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(33, 'BENF_BIC_CODE', 2, 'SWIFT/BIC банка получателя CRAITR1KTZ');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(34, 'BENF_BANK_NAME', 2, 'Название банка получателя');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(35, 'BENF_BANK_ACC', 2, 'Счет банка получателя в банке-корреспонденте AD2222222133');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(36, 'CORR_BIC_CODE', 2, 'SWIFT банка-корреспондента ICRAITR1KTE');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(37, 'CORR_BANK_NAME', 2, 'Название банка-корреспондента');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(38, 'PAYM_DETAILS', 2, 'Назначение платежа');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(39, 'OPER_CODE', 2, 'Код операции 8444');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(40, 'OPERATION', 2, 'Код субоперации 7614');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(41, 'BENF_COUNTRY', 2, 'Код страны получателя');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(42, 'SEND_COUNTRY', 2, 'Код страны отправителя');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(43, 'TOP_URGENT', 3, 'Самый срочный (True/False)');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(44, 'CHNL_COMMISS', 2, 'Варианты оплаты расходов за комиссию. Возможные значения: за счет плательщика (OUR), за счет бенефициара(BEN), за счет плательщика и бенефициара (SHA)');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(45, 'COVER', 3, 'True/False COVER (MT103+MT202) False');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(46, 'SEND_NRES', 3, 'True/False Флаг выставляется, если отправитель - не резидент False');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(47, 'BENF_NRES', 3, 'True/False Флаг выставляется, если получатель - не резидент False');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(48, 'FUIB_COMMISS', 3, 'Если True, то комиссионные ПУМБ за счет отправителя False');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(49, 'OTHR_COMMISS', 3, 'Если True, то комиссионные других банков за счет отправителя True');
INSERT INTO docflow.attrbase (attr_id, attr_code, datp_id, attr_desc)
VALUES(50, 'OUR_COMMISS', 3, 'True/False Гарантоване OUR False');


INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 1, 0, 'documentId', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 3, 0, 'emplCod', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 4, 0, 'enrollmentType', 'H', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 5, 0, 'clnOkpo', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 6, 0, 'transitAccount', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 7, 0, 'totalRecipients', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 8, 1, 'employee:recordNumber', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 9, 1, 'employee:acctCard', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 10, 1, 'employee:fio', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 14, 1, 'employee:idCode', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 15, 1, 'employee:amount', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(2, 16, 1, 'employee:comment', 'L', 'E', 'N');


INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 17, 0, 'DOC_DATE', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 1, 0, 'NUMBER', 'H', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 19, 0, 'PAY_ACC', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 20, 0, 'COM_ACC', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 5, 0, 'CLNT_OKPO', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 21, 0, 'CLNT_NAME', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 22, 0, 'CLNT_ADDR', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 23, 0, 'TO_BUY', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 24, 0, 'AGAINST', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 25, 0, 'CONV_NUMB', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 26, 0, 'PRT_AMOUNT', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 27, 0, 'CCY', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 28, 0, 'COM_CCY', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 29, 0, 'AMOUNT', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 30, 0, 'BENF_ACC', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 31, 0, 'BENF_NAME', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 32, 0, 'BENF_ADDR', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 33, 0, 'SWIFT', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 34, 0, 'BANK_NAME', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 35, 0, 'BANK_ACC', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 36, 0, 'CORR_SWIFT', 'L', 'E', 'Y');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 37, 0, 'CORR_NAME', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 38, 0, 'DETAILS', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 39, 0, 'OPCODE', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 40, 0, 'OPERATION', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 41, 0, 'BENF_CTRY', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 42, 0, 'COUNTRY', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 43, 0, 'TOPURGENT', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 45, 0, 'COVER', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 46, 0, 'PAY_NRES', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 47, 0, 'BENF_NRES', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 48, 0, 'FUIB_COMM', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 49, 0, 'OTHER_COMM', 'L', 'E', 'N');
INSERT INTO docflow.pfileattr (ftype_id, attr_id, pattr_ind, pattr_tag, pattr_flg, pattr_ent, pattr_req)
VALUES(3, 50, 0, 'OUR', 'L', 'E', 'N');
