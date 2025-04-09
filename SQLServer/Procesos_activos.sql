--https://gherrerasqlserver.blogspot.com/2011/05/activity-monitor-no-no-mejor-vista-del.html
-- Sys.sysprocesses --
select
spid,
blocked, -- solo valor si está bloqueada
waittime, -- 0 = process its not waiting -
lastwaittype, -- Description of last waiting
dbid, -- Data base id used by the process
cpu, -- Cumulative cpu time for the process
physical_io, -- Cumulative disk reads and writes
memusage, -- Number of page in the cache allocated by the process
Login_time, -- Time in which a process begin to log
last_batch, -- Time in wich a last process has ocurred
open_tran, -- Number of open transactions for the process
status, -- "dormant" -- is being resetting the session --
-- "running" -- is running one or more batches --
-- "background" -- running background process such as rollback process --
-- "pending" -- waiting for thread to continue
-- "runnable" -- the task is in the runnable queue --
-- "suspended" -- waiting for an event to complete --
sid, -- user identificator
hostname, -- name of the workstation
cmd, -- command that is being executed --
nt_username -- user name for the process
from sys.sysprocesses


-- En caso de quere5 "asesinar" un proceso --
--KILL SPID;