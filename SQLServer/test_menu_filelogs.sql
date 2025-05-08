/*
Hammer  Santamaria
2025
Menu Log sizes
*/
--Declare
DECLARE @DatabaseN VARCHAR(max);
DECLARE @FilegroupN VARCHAR(max);
DECLARE @Usagetype VARCHAR(max);
DECLARE @FilenameN VARCHAR(max);
DECLARE @SizeN INTEGER;
-------------------SELECTION MENU------------------------------
DECLARE @total_filegroup as bit =1
DECLARE @total_by_usage as bit =0 -- set to 0 to skip first part
DECLARE @files_by_filegroup as bit =0 -- set to 0 to skip second part
DECLARE @files_by_usage as bit =  0
DECLARE @files_by_filename as bit = 0
----------Modifications
DECLARE @growth_file as bit =  0
DECLARE @Create_file as bit = 0
-----------Parameters----------------
SET @DatabaseN = 'sqlusu';
SET @FilegroupN = '';
SET @Usagetype = 'log only';
SET @FilenameN = '';
SET @SizeN = 500;
--*************************************************
--PRINT @V_inst_ip_server
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
--***************************************************

IF @total_filegroup = 1
BEGIN
SELECT @@servername servername, databasename, filegroup, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename =@DatabaseN
and filegroup = @FilegroupN
group by databasename, filegroup
END

IF @total_by_usage = 1
BEGIN
SELECT @@servername servername, databasename, usage, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename =@DatabaseN
and usage= @Usagetype
group by databasename, usage
END

IF @files_by_filegroup = 1
BEGIN
SELECT * FROM #info
WHERE    1=1
        --and (growthMB <> 0 or growthPct <> 0)
        --and databasename + ';' + ISNULL(filegroup, 'LOG') IN ('CM_TEL;PRIMARY')   
        and filegroup = @FilegroupN
        and databasename = @DatabaseN
        --and filename LIKE ('I:\DataRiv5\%') 
        --and filename NOT LIKE ('P:\Data2_5\%') 
        --and usage = 'data only'
END

IF @files_by_usage = 1
BEGIN
SELECT * FROM #info
WHERE    1=1
        --and (growthMB <> 0 or growthPct <> 0)
        --and databasename + ';' + ISNULL(filegroup, 'LOG') IN ('CM_TEL;PRIMARY')   
        --and filegroup = @FilegroupN
        and databasename = @DatabaseN
        --and filename LIKE ('I:\DataRiv5\%') 
        --and filename NOT LIKE ('P:\Data2_5\%') 
        and usage = @Usagetype 
END

IF @growth_file = 1
BEGIN
ALTER DATABASE [@DatabaseN] MODIFY FILE (NAME = [@FilenameN], SIZE = [@SizeN] MB)
END

IF @Create_file = 1
BEGIN
/*
ALTER DATABASE [@DatabaseN] ADD FILE ( NAME = N'Recargas4', FILENAME = N'F:\Data\Recargas4.ndf',  --CREAR UN NUEVO DATAFILE 
SIZE = 4GB , FILEGROWTH = 256MB ) TO FILEGROUP [PRIMARY]*/
print ('¡Modificar parametros de forma manual!')
END
