/*
EXEC sp_WhoIsActive;
Extraer de la columna program name el id del job
SQLAgent - TSQL JobStep (Job 0xE958B74525409A489D9918A2929C3749 : Step 1)
*/

SELECT * FROM msdb.dbo.sysjobs WHERE CONVERT(uniqueidentifier, job_id) = 0x5EC2FFCBE615E245BAB0D7942E6ED92E