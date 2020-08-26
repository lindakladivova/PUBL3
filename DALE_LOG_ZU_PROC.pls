create or replace PROCEDURE DALE_LOG_ZU_PROC AS 
BEGIN

  INSERT INTO GEP_LOG_SESSION_ZU (log_time, status, machine, osuser, log_on_time,s_id) (select sysdate, status, machine, osuser, logon_time, sid from sys.V_$SESSIon where username='PUBL_EXPORT_KM');
  COMMIT;

END DALE_LOG_ZU_PROC;