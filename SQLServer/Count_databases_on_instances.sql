SELECT 
    COUNT(*) AS UserDatabaseCount,
    @@VERSION AS SqlServerVersion
FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
  AND name NOT LIKE '%HWI_Admin%';

--For sql 2000
/*SELECT 
    COUNT(*) AS UserDatabaseCount,
    @@VERSION AS SqlServerVersion
FROM master..sysdatabases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
AND name NOT LIKE '%HWI_Admin%';*/
