SELECT 
    sid, 
    serial#, 
    username, 
    status, 
    machine, 
    program, 
    last_call_et AS seconds_in_current_state,
    TO_CHAR(logon_time, 'YYYY-MM-DD HH24:MI:SS') AS logon_time
FROM 
    v$session
WHERE 
    username IS NOT NULL  -- Filters out Oracle background processes
ORDER BY 
    status, 
    last_call_et DESC;
