SELECT

session_id,status,

command,sql_handle,database_id

,(SELECT text FROM sys.dm_exec_sql_text(sql_handle)) AS query_text

FROM sys.dm_exec_requests r

WHERE session_id >= 51








--For more detail about was has been running, try:

select

s.session_id, s.login_name, s.host_name, s.status,

s.program_name, s.cpu_time, s.last_request_start_time,

(SELECT text FROM sys.dm_exec_sql_text(c.most_recent_sql_handle)) AS query_text

from sys.dm_exec_sessions s, sys.dm_exec_connections c

where s.session_id = c.session_id and

s.session_id > 50

order by s.last_request_start_time desc

