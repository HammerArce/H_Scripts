--------------------------Chismoso---------------------------------------
-------Connect to WBOGSQLGES
select * 
from [Monitoring].[OpenSessions]
where  svrname = 'MAVEME01\SQLINST01'
and dbname ='StrategieQA'
and loginname not in ('sa', 'NH\sqldatamart','')
and command = 'AWAITING COMMAND'
and command != 'UPDATE STATISTICS'
and command != 'UPDATE STATISTIC'
AND startdate BETWEEN '2025-02-16 00:00:00' AND '2025-04-02 19:00:00'
--and total > 0
--group by dbname

order by startdate  desc