-- =========================================
-- MODIFY ONLY THIS LINE
-- Use % as wildcard (LIKE behavior)
-- Examples:
-- 'CBS1.IDX%'
-- 'CBS1.%LOG%'
-- 'CBS1.IDX_AR_LOG_TRX_DETAIL_CUT'
-- =========================================
DEFINE INDEX_FILTER = 'IVR2.BK%'

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

set pages 100
set linesize 250
set echo off
set timing on

prompt *** CONECTADO A BASE DE DATOS **

column FECHA format a20
column HOST_NAME format a18
column DIRECCION_IP format a15
column BASE_DATOS format a12
column VERSION format a12
column STATUS format a10
column START_UP format a20
column OPEN_MODE format a12

select to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') FECHA,
       upper(host_name) HOST_NAME,
       (select utl_inaddr.get_host_address from dual) DIRECCION_IP,
       upper(instance_name) BASE_DATOS,
       version,
       status,
       to_char(startup_time,'DD/MM/YYYY HH24:MI:SS') START_UP,
       (select open_mode from v$database) OPEN_MODE
from gv$instance
order by 4;

prompt
prompt *** NON PARTITIONED INDEXES UNUSABLE ***

column OWNER format a20
column INDEX_NAME format a35
column INDEX_TYPE format a20
column SCRIPT_REBUILD format a90
column MBytes format 999,999,999,999

SELECT i.owner,
       i.index_name,
       i.index_type,
       (SELECT SUM(bytes)/1048576
          FROM dba_segments s
         WHERE s.segment_name = i.index_name
           AND s.owner = i.owner) MBytes,
       'ALTER INDEX '||i.owner||'.'||i.index_name||' REBUILD ONLINE;' SCRIPT_REBUILD
FROM dba_indexes i
WHERE i.status NOT IN ('USABLE','VALID')
  AND i.partitioned = 'NO'
  AND UPPER(i.owner||'.'||i.index_name)
      LIKE UPPER('&INDEX_FILTER')
ORDER BY MBytes DESC
/

prompt
prompt *** PARTITIONED INDEXES UNUSABLE ***

SELECT ip.index_owner OWNER,
       ip.index_name,
       ip.partition_name,
       (SELECT SUM(bytes)/1048576
          FROM dba_segments s
         WHERE s.segment_name = ip.index_name
           AND s.owner = ip.index_owner) MBytes,
       'ALTER INDEX '||ip.index_owner||'.'||ip.index_name||
       ' REBUILD PARTITION '||ip.partition_name||';' SCRIPT_REBUILD
FROM dba_ind_partitions ip
WHERE ip.status NOT IN ('USABLE')
  AND UPPER(ip.index_owner||'.'||ip.index_name)
      LIKE UPPER('&INDEX_FILTER')
ORDER BY MBytes DESC
/

prompt
prompt *** FIN DEL REPORTE ***
