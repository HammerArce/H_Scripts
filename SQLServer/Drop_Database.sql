USE master;
GO
--declare and config variables
DECLARE @DatabaseName VARCHAR(50) = ''; --Database name

DECLARE @CloseConnections VARCHAR(200)
	= 'ALTER DATABASE ' + @DatabaseName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE'

DECLARE @DropDatabase VARCHAR(200) = 'DROP DATABASE '+ @DatabaseName

-----------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
BEGIN
EXEC (@CloseConnections)
EXEC (@DropDatabase)
END
