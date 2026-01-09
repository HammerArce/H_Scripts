/*
-- Run this script first if you have blocked xp_cmdshell feature on advanced options
-- Enable advanced options
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  
-- Disable advanced options
EXEC sp_configure 'show advanced options', 0;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE; 
GO  
*/
DECLARE @drive VARCHAR(100),
		@freeSpace INT,
		@totalSpace INT,
		@percentFree DECIMAL(5,2),
		@letter CHAR(1)

DROP TABLE IF EXISTS #drives
DROP TABLE IF EXISTS #t
DROP TABLE IF EXISTS #total
DROP TABLE IF EXISTS #driveTypes
 
CREATE TABLE #driveTypes
(
	drive VARCHAR(100),
	freeSpace INT,
	totalSpace INT,
	percentFree DECIMAL(5,2),
	isMountPoint BIT
)	
 
DECLARE @sqlver sql_variant
 
DECLARE @sqlver2 varchar(20)
 
DECLARE @sqlver3 int
 
 
SELECT @sqlver = SERVERPROPERTY('productversion')
 
SELECT @sqlver2 = CAST(@sqlver AS varchar(20))
 
select @sqlver3 = SUBSTRING(@sqlver2,1,1)
 
 
-- 1 = 2008; 8 = 2000; and 9 = 2005; 1 is short for 10, 11, 12...
 
BEGIN
 
--select @sqlver3 only uncomment to see state of version
 
IF @sqlver3 = 1 GOTO SERVER2008
 
IF @sqlver3 = 9 GOTO SERVER2000
 
IF @sqlver3 = 8 GOTO SERVER2000
 
GOTO THEEND
 
END
 
 
SERVER2008:
 
declare @svrName varchar(255)
 
declare @sql varchar(400)
 
--by default it will take the current server name, we can the set the server name as well
 
set @svrName = @@SERVERNAME
 
set @sql = 'powershell.exe -c "Get-WmiObject -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'
 
--creating a temporary table
 
CREATE TABLE #output
 
(line varchar(255))
 
--inserting disk name, total space and free space value in to temporary table
 
insert #output
 
EXEC xp_cmdshell @sql
 
DECLARE Drive CURSOR FOR
--script to retrieve the values in GB from PS Script output
select	rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as drive,
		round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,(CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0) as 'freespace',
		round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float),0) as 'totalspace',
		((round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,(CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0)) / (round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float),0)) * 100) as percentfree
from	#output
where	line like '[A-Z][:]%'
--and ((round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
-- (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0)) / (round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
--(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0)) * 100) < 5
order by drive
 
OPEN Drive	
FETCH NEXT FROM Drive INTO @drive, @freeSpace, @totalSpace, @percentFree
 
WHILE(@@FETCH_STATUS = 0)
BEGIN
	IF(LEN(@drive) > 3)
	BEGIN
		INSERT INTO #driveTypes(drive, freeSpace, totalSpace, percentFree, isMountPoint)
		(SELECT @drive, @freeSpace, @totalSpace, @percentFree, 1)
	END
	ELSE BEGIN
		INSERT INTO #driveTypes(drive, freeSpace, totalSpace, percentFree, isMountPoint)
		(SELECT @drive, @freeSpace, @totalSpace, @percentFree, 0)
	END
	IF((SELECT COUNT(*) FROM #driveTypes WHERE SUBSTRING(drive,1,1) = SUBSTRING(@drive,1,1)) > 1)
	BEGIN
		SET @letter = SUBSTRING(@drive,1,1)
		DELETE FROM #driveTypes WHERE LEN(drive) = 3 AND SUBSTRING(drive,1,1) = @letter 
	END	 
	FETCH NEXT FROM Drive INTO @drive, @freeSpace, @totalSpace, @percentFree
END
 
CLOSE Drive
DEALLOCATE Drive
 
SELECT @@SERVERNAME Server, * FROM #driveTypes ORDER BY drive
 
--script to drop the temporary table
 
drop table #output
 
GOTO THEEND
 
 
SERVER2000:
 
SET NOCOUNT ON;
 
 
DECLARE @v_cmd nvarchar(255)
 
		,@v_drive char(99)
 
		,@v_sql nvarchar(255)
 
		,@i int
 
SELECT @v_cmd = 'fsutil volume diskfree %d%'
 
SET @i = 1
 
 
CREATE TABLE #drives(iddrive smallint ,drive char(99))
 
CREATE TABLE #t(drive char(99),shellCmd nvarchar(500));
 
CREATE TABLE #total(drive char(99),freespace decimal(9,2), totalspace decimal(9,2));
 
 
-- Use mountvol command to
 
INSERT #drives (drive)
 
EXEC master..xp_cmdshell 'mountvol'
 
DELETE #drives WHERE drive not like '%:\%' or drive is null
 
 
WHILE (@i <= (SELECT count(drive) FROM #drives))
 
BEGIN
 
UPDATE #drives
 
SET iddrive=@i
 
WHERE drive = (SELECT TOP 1 drive FROM #drives WHERE iddrive IS NULL)
 
 
SELECT @v_sql = REPLACE(@v_cmd,'%d%',LTRIM(RTRIM(drive))) from #drives where iddrive=@i
 
 
INSERT #t(shellCmd)
 
EXEC master..xp_cmdshell @v_sql
 
 
UPDATE #t
 
SET #t.drive = d.drive
 
FROM #drives d
 
WHERE #t.drive IS NULL and iddrive=@i
 
 
SET @i = @i + 1
 
END
 
 
INSERT INTO #total
 
SELECT bb.drive
 
,CAST(CAST(REPLACE(REPLACE(SUBSTRING(shellCmd,CHARINDEX(':',shellCmd)+1,LEN(shellCmd)),SPACE(1),SPACE(0))
 
,char(13),SPACE(0)) AS NUMERIC(32,2))/1024/1024 AS DECIMAL(9,2)) as freespace
 
,tt.titi as total
 
FROM #t bb
 
JOIN (SELECT drive
 
,CAST(CAST(REPLACE(REPLACE(SUBSTRING(shellCmd,CHARINDEX(':',shellCmd)+1,LEN(shellCmd)),SPACE(1),SPACE(0))
 
,char(13),SPACE(0)) AS NUMERIC(32,2))/1024/1024 AS DECIMAL(9,2)) as titi
 
FROM #t
 
WHERE drive IS NOT NULL
 
AND shellCmd NOT LIKE '%free bytes%') tt
 
ON bb.drive = tt.drive
 
WHERE bb.drive IS NOT NULL
 
AND bb.shellCmd NOT LIKE '%avail free bytes%'
 
AND bb.shellCmd LIKE '%free bytes%';
 
-- SET FreespaceTimestamp = (GETDATE())
 
DECLARE Drive CURSOR FOR
SELECT	RTRIM(LTRIM(drive)) as drive,
		freespace,
		totalspace,
		CAST((freespace/totalspace * 100) AS DECIMAL(5,2)) as [percent free]
FROM	#total
--WHERE (freespace/totalspace * 100) < 5
ORDER BY drive
 
OPEN Drive	
FETCH NEXT FROM Drive INTO @drive, @freeSpace, @totalSpace, @percentFree
 
WHILE(@@FETCH_STATUS = 0)
BEGIN
	IF(LEN(@drive) > 3)
	BEGIN
		INSERT INTO #driveTypes(drive, freeSpace, totalSpace, percentFree, isMountPoint)
		(SELECT @drive, @freeSpace, @totalSpace, @percentFree, 1)
	END
	ELSE BEGIN
		INSERT INTO #driveTypes(drive, freeSpace, totalSpace, percentFree, isMountPoint)
		(SELECT @drive, @freeSpace, @totalSpace, @percentFree, 0)
	END
	IF((SELECT COUNT(*) FROM #driveTypes WHERE SUBSTRING(drive,1,1) = SUBSTRING(@drive,1,1)) > 1)
	BEGIN
		SET @letter = SUBSTRING(@drive,1,1)
		DELETE FROM #driveTypes WHERE LEN(drive) = 3 AND SUBSTRING(drive,1,1) = @letter 
	END	 
	FETCH NEXT FROM Drive INTO @drive, @freeSpace, @totalSpace, @percentFree
END
 
CLOSE Drive
DEALLOCATE Drive
 
--SELECT	RTRIM(LTRIM(drive)) as drive, freespace, totalspace, CAST((freespace/totalspace * 100) AS DECIMAL(5,2)) as [percent free] FROM	#total
--SELECT sum(freeSpace)freeSpace FROM #driveTypes 
SELECT * FROM #driveTypes ORDER BY drive		
 

THEEND:
