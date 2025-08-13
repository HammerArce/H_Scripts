-----------------revisar estado de conexiones
select login_name,
	COUNT(session_id) AS session_count
FROM sys.dm_exec_sessions
GROUP BY login_name;

-----------------2do metodo
-----------------Cambiar 'yourdatabase'
SELECT
  r.session_id,
  s.login_name,
  s.host_name,
  s.program_name,
  c.client_net_address,
  r.status,
  r.command,
  DB_NAME(r.database_id) AS database_name,
  r.blocking_session_id,
  r.wait_type,
  r.wait_time,
  r.last_wait_type,
  r.cpu_time,
  r.total_elapsed_time,
  SUBSTRING(t.text,
            (r.statement_start_offset/2) + 1,
            ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END
              - r.statement_start_offset)/2) + 1) AS current_statement
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
LEFT JOIN sys.dm_exec_connections AS c ON r.session_id = c.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.database_id = DB_ID('YourDatabase')
ORDER BY r.total_elapsed_time DESC;
