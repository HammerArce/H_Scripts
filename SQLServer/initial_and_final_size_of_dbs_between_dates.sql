  ---------------------initial size and final size of the instance, on a selected range of dates
SELECT instanceName, modifiedDate, sum(sizeMB)
  FROM [DBA_Repository].[Monitoring].[GrowthDatabases]
  where instanceName like '%SQLINSTOTROS%'
  and modifiedDate = '2020-07-01'
  group by instanceName, modifiedDate
  union all
SELECT instanceName, modifiedDate, sum(sizeMB)
  FROM [DBA_Repository].[Monitoring].[GrowthDatabases]
  where instanceName like '%SQLINSTOTROS%'
  and modifiedDate = '2020-11-30'
  group by instanceName, modifiedDate
 
 
-------------------initial size and final size of all dbs, on a selected range of dates
SELECT gd.instanceName, gd.databaseName, gd.modifiedDate, SUM(gd.sizeMB) sizeMbInicial, gd2.modifiedDate, SUM(gd2.sizeMB) sizeMbFinal
  FROM [DBA_Repository].[Monitoring].[GrowthDatabases] gd
  left join [DBA_Repository].[Monitoring].[GrowthDatabases] gd2
  on gd.instanceName = gd2.instanceName
  and gd.databaseName = gd2.databaseName
  where gd.instanceName like '%SQLINSTOTROS%'-- and databaseName = 'CORE_PF'
  AND  gd.modifiedDate = '2020-06-10'
  and gd2.modifiedDate = '2020-12-10'
  and gd.databaseName not in ('model', 'msdb', 'tempdb', 'master', 'HWI_Admin')
  group by gd.instanceName, gd.modifiedDate, gd.databaseName, gd2.modifiedDate, gd.sizeMB , gd2.sizeMB