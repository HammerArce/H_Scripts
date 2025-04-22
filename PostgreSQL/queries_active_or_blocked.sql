--How to check which queries are active or blocked in PostgreSQL?
--You can use the pg_stat_activity view in PostgreSQL to check which queries are currently active or blocked. This view provides information about each running query, including the query text, start time, state, and many other details. To check the active queries, you can run the following query:

SELECT * FROM pg_stat_activity WHERE state != 'idle';
--This query will return all rows from the pg_stat_activity view where the state column is not ‘idle’, indicating that the query is currently running. To check the blocked queries, you can run the following query:

SELECT * FROM pg_stat_activity WHERE state = 'blocked';
--This query will return all rows from the pg_stat_activity view where the state column is ‘blocked’, indicating that the query is currently blocked by another query. You can also use pg_locks and pg_stat_activity to show the blocking and blocked processes.

SELECT blocked_locks.pid     AS blocked_pid,
       blocked_activity.usename  AS blocked_user,
       blocking_locks.pid     AS blocking_pid,
       blocking_activity.usename AS blocking_user,
       blocked_activity.query    AS blocked_statement,
       blocking_activity.query   AS current_statement_in_blocking_process
FROM  pg_catalog.pg_locks         blocked_locks
JOIN  pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
JOIN  pg_catalog.pg_locks         blocking_locks 
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
JOIN  pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid;
--This query will show the process that is holding the lock, the process that is waiting for the lock, the query that is being executed by the waiting process, and the query that is being executed by the process holding the lock.

--https://minervadb.xyz/how-to-check-which-queries-are-active-or-blocked-in-postgresql/#:~:text=Internals%2C%20PostgreSQL%20Performance-,How%20to%20check%20which%20queries%20are%20active%20or%20blocked%20in,state%2C%20and%20many%20other%20details.