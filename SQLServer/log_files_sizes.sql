/*---------------- Verificar info de autogrowth en todas las BDs de una instancia ---------------*/
use master;
go
-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#info') IS NOT NULL
       DROP TABLE #info;
-- Create table to house database file information
CREATE TABLE #info (
     databasename VARCHAR(128)
     ,name VARCHAR(128)
    ,fileid INT
    ,filename VARCHAR(1000)
    ,filegroup VARCHAR(128)
    ,sizeMB decimal (18,2)
    ,freeSpaceMB decimal (18,2)
    ,freeSpacePct decimal (18,2)
    ,maxsizeMB VARCHAR(25)
    ,growthMB INT
    ,growthPct INT
    ,usage VARCHAR(25));
-- Get database file information for each database   
SET NOCOUNT ON; 
INSERT INTO #info
EXEC sp_MSforeachdb 'use [?] 
select ''?'', RTRIM(LTRIM(name)),  fileid, filename,
filegroup = filegroup_name(groupid),
''sizeMB'' = convert (decimal(18,2), size) / 128,
''FreeMB'' = convert (decimal (18,2), size) / 128.0 - convert (decimal (18,2), FILEPROPERTY(name, ''SpaceUsed'')) / 128.0, 
''FreePct'' = (convert (decimal (18,2), size) / 128.0 - convert (decimal (18,2), FILEPROPERTY(name, ''SpaceUsed'')) / 128.0) * 100 / (convert (decimal(18,2), size) / 128),
''maxsizeMB'' = (case maxsize when -1 then N''Unlimited''
else
convert(nvarchar(15), convert (bigint, maxsize) * 8 / 1024) end),
''growthMB'' = (case status & 0x100000 when 0x100000 then NULL
else convert (bigint, growth) * 8 / 1024 end),
''growthPct'' = (case status & 0x100000 when 0x100000 then growth
else NULL end),
''usage'' = (case status & 0x40 when 0x40 then ''log only'' else ''data only'' end)
from sysfiles
';
 
 
 
/*
SELECT @@servername servername, databasename, filegroup, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename ='AppVentasMovistar'
and filegroup = 'PRIMARY'
group by databasename, filegroup
*/
/*
SELECT @@servername servername, databasename, usage, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename ='AppVentasMovistar'
and usage= 'log only'
group by databasename, usage
*/
 
SELECT * FROM #info
WHERE 1=1
        --and (growthMB <> 0 or growthPct <> 0)
        --and databasename + ';' + ISNULL(filegroup, 'LOG') IN ('CM_TEL;PRIMARY')   
        --and filegroup = 'PRIMARY'
        --and databasename = 'CapacityManagerRepository' 
        --and filename LIKE ('I:\DataRiv5\%') 
        --and filename NOT LIKE ('P:\Data2_5\%') 
        --and usage = 'data only'
--DROP TABLE #info
 
/*
SELECT * FROM #info
WHERE    1=1
        --and (growthMB <> 0 or growthPct <> 0)
        --and databasename + ';' + ISNULL(filegroup, 'LOG') IN ('CM_TEL;PRIMARY')   
        --and filegroup = 'PRIMARY'
        --and databasename = 'CapacityManagerRepository' 
        --and filename LIKE ('I:\DataRiv5\%') 
        --and filename NOT LIKE ('P:\Data2_5\%') 
        --and usage = 'data only'
*/
--DROP TABLE #info
 
/*
ALTER DATABASE [smsws_db] MODIFY FILE (NAME = N'smsws_db_Indices5', SIZE = 16293 MB)
*/
/*
USE tempdb;
GO
DBCC SHRINKFILE (templog, 256);
GO
*/
/*
ALTER DATABASE [Recargas] ADD FILE ( NAME = N'Recargas4', FILENAME = N'F:\Data\Recargas4.ndf',  --CREAR UN NUEVO DATAFILE 
SIZE = 4GB , FILEGROWTH = 256MB ) TO FILEGROUP [PRIMARY]
GO
*/
/*
ALTER DATABASE [E2E_PagoNoAplicado_PROD] MODIFY FILE (NAME = N'E2E_PagoNoAplicado_PROD', FILEGROWTH = 64MB) -- QUITAR CRECIMIENTO  O DAR CRECIMIENTO A DATAFILES
*/
/*
ALTER DATABASE [Recargas] ADD LOG FILE ( NAME = N'provisional_log1', FILENAME = N'N:\Log\provisional_log1.ldf', 
SIZE = 512 MB , FILEGROWTH = 64 MB )
GO
*/
/*
ALTER DATABASE [PREPAGOS] MODIFY FILE ( NAME = N'PREPAGOS_log_Temp1', FILEGROWTH = 32)
GO
*/
/*
SELECT    name,
        DATABASEPROPERTYEX(name, 'RECOVERY') AS modo_recuperacion
FROM    master..sysdatabases ORDER BY modo_recuperacion, name
*/
/*
SELECT distinct(databasename), COUNT(filename)datafile, IIF(filegroup='PRIMARY', 'PRIMARY', 'LOG')filegroup FROM #info
WHERE    databasename not in ('master', 'model', 'msdb', 'tempdb')
group by databasename, filegroup
 
select * from sysdatabases //VIEJAS
select name, log_reuse_wait_desc, recovery_model_desc from sys.databases // NUEVAS
USE tempdb
GO
CHECKPOINT;
GO
 
DBCC FREESESSIONCACHE;
GO
 
DBCC FREEPROCCACHE;
GO
 
DBCC FREESYSTEMCACHE ('ALL');
GO
 
DBCC DROPCLEANBUFFERS;
GO
DBCC SHRINKFILE (temp9, 128);
DBCC SHRINKFILE (temp9, EMPTYFILE);
 
ALTER DATABASE HWI_Admin SET RECOVERY SIMPLE 
*/