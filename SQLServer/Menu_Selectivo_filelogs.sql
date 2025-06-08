/****************************************************************************************
*                                                                                       *
*   SCRIPT PARA VERIFICAR LA INFORMACIÓN Y AUTOGROWTH DE LOS ARCHIVOS DE BASES DE DATOS *
*                                                                                       *
*   Descripción:                                                                        *
*   Este script recopila información detallada sobre los archivos de datos (.mdf, .ndf) *
*   y de log (.ldf) de todas las bases de datos en la instancia de SQL Server.          *
*                                                                                       *
*   HAMMER	- 2025																        *
****************************************************************************************/
USE master;
GO
-- =======================================================================================
-- >> VARIABLES
-- =======================================================================================
DECLARE 
    @TargetDatabase        VARCHAR(128) = 'AppVentasMovistar',       -- Ejemplo: 'AppVentasMovistar', o NULL para todas las bases de datos.
    @TargetFilegroup       VARCHAR(128) = 'PRIMARY',                 -- Example: 'PRIMARY' Filegroup to filter in queries
    @TargetUsage           VARCHAR(25)  = 'log only',                -- Example: 'data only' or 'log only'
    @TargetFilenameLike    VARCHAR(1000) = 'I:\DataRiv5\%',          -- Example: 'I:\DataRiv5\%' For LIKE filtering on filename
    @TargetFilenameNotLike VARCHAR(1000) = 'P:\Data2_5\%',           -- Example: 'P:\Data2_5\%' For NOT LIKE filtering on filename
    @ShowGrowthFilesOnly   BIT = 0                                   -- 1 = Only files with growth, 0 = All
-- =======================================================================================
-- MENU DE SELECCION (set to 0 to skip or 1 to activate)
-- =======================================================================================
DECLARE
	@ALLDBFILES as bit = 1,
	@total_filegroup as bit = 1,
	@total_by_usage as bit = 1,
	@files_by_filegroup as bit =1,
	@files_by_usage as bit =  1,
	@files_by_filename as bit = 1

--DECLARE @ShowSystemDBs  BIT         = 0;    -- Ponga 1 para incluir 'master', 'model', 'msdb', 'tempdb'. Ponga 0 para excluirlas.



-- =======================================================================================
-- INICIO DE LA LÓGICA DEL SCRIPT (No es necesario modificar)
-- =======================================================================================
/*-------------------- Drop temp table if it exists --------------------*/
IF OBJECT_ID('tempdb..#info') IS NOT NULL
    DROP TABLE #info;
    
/*-------------------- Create temp table for database file info --------------------*/
CREATE TABLE #info (
    databasename VARCHAR(128),
    name         VARCHAR(128),
    fileid       INT,
    filename     VARCHAR(1000),
    filegroup    VARCHAR(128),
    sizeMB       DECIMAL(18,2),
    freeSpaceMB  DECIMAL(18,2),
    freeSpacePct DECIMAL(18,2),
    maxsizeMB    VARCHAR(25),
    growthMB     INT,
    growthPct    INT,
    usage        VARCHAR(25)
);

/*-------------------- Populate temp table for all databases --------------------*/
SET NOCOUNT ON; 
INSERT INTO #info
EXEC sp_MSforeachdb N'
USE [?];
SELECT 
    ''?'' AS databasename, 
    RTRIM(LTRIM(name)),  
    fileid, 
    filename,
    filegroup = filegroup_name(groupid),
    sizeMB = CONVERT(DECIMAL(18,2), size) / 128,
    FreeMB = CONVERT(DECIMAL(18,2), size) / 128.0 - CONVERT(DECIMAL(18,2), FILEPROPERTY(name, ''SpaceUsed'')) / 128.0, 
    FreePct = (CONVERT(DECIMAL(18,2), size) / 128.0 - CONVERT(DECIMAL(18,2), FILEPROPERTY(name, ''SpaceUsed'')) / 128.0) * 100 / (CONVERT(DECIMAL(18,2), size) / 128),
    maxsizeMB = (CASE maxsize WHEN -1 THEN N''Unlimited'' ELSE CONVERT(NVARCHAR(15), CONVERT(BIGINT, maxsize) * 8 / 1024) END),
    growthMB = (CASE status & 0x100000 WHEN 0x100000 THEN NULL ELSE CONVERT(BIGINT, growth) * 8 / 1024 END),
    growthPct = (CASE status & 0x100000 WHEN 0x100000 THEN growth ELSE NULL END),
    usage = (CASE status & 0x40 WHEN 0x40 THEN ''log only'' ELSE ''data only'' END)
FROM sysfiles
';
-- =======================================================================================
-- Filtered Queries (No es necesario modificar)
-- =======================================================================================
BEGIN
/*--------------------ALL FILES--------------------*/
BEGIN
IF @ALLDBFILES = 1
SELECT * FROM #info
WHERE 1=1
    AND (@ShowGrowthFilesOnly = 0 OR (ISNULL(growthMB,0) <> 0 OR ISNULL(growthPct,0) <> 0))
    AND (@TargetDatabase IS NULL OR databasename = @TargetDatabase)
    AND (@TargetFilegroup IS NULL OR filegroup = @TargetFilegroup)
    AND (@TargetUsage IS NULL OR usage = @TargetUsage)
    AND (@TargetFilenameLike IS NULL OR filename LIKE @TargetFilenameLike)
    AND (@TargetFilenameNotLike IS NULL OR filename NOT LIKE @TargetFilenameNotLike);
END

BEGIN
IF @total_filegroup  = 1
SELECT @@servername servername, databasename, filegroup, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename =@TargetDatabase
and filegroup = @TargetFilegroup
group by databasename, filegroup
END
BEGIN
IF @total_by_usage  = 1
SELECT @@servername servername, databasename, usage, sum(sizeMB) as 'sizeMB', sum(freeSpaceMB) as 'freeSpaceMB',
(sum(freeSpaceMB)/sum(sizeMB))*100 as 'freeSpacePct' FROM #info
WHERE databasename =@DatabaseN
and usage= @Usagetype
group by databasename, usage
END
IF @files_by_filegroup  =1
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
BEGIN
IF @files_by_usage =  1
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
/*BEGIN
IF @files_by_filename = 1
END*/
END
-- =======================================================================================
-- RECETARIO DE COMANDOS ADMINISTRATIVOS COMUNES (PARA REFERENCIA)
-- Descomente y modifique la sección que necesite utilizar.
-- =======================================================================================

/*
-- ---------------------------------------------------------------------------------------
-- MODIFICAR ARCHIVOS (TAMAÑO, CRECIMIENTO, ETC.)
-- ---------------------------------------------------------------------------------------

-- Modificar el tamaño inicial de un archivo de datos
ALTER DATABASE [NombreDB] MODIFY FILE (NAME = N'NombreLogicoArchivo', SIZE = 2048MB);

-- Modificar el crecimiento de un archivo (a un valor fijo en MB)
ALTER DATABASE [NombreDB] MODIFY FILE (NAME = N'NombreLogicoArchivo', FILEGROWTH = 512MB);

-- Modificar el crecimiento de un archivo (a un porcentaje)
ALTER DATABASE [NombreDB] MODIFY FILE (NAME = N'NombreLogicoArchivo', FILEGROWTH = 10%);

-- Desactivar el autogrowth (NO RECOMENDADO para la mayoría de los casos)
ALTER DATABASE [NombreDB] MODIFY FILE (NAME = N'NombreLogicoArchivo', FILEGROWTH = 0);


-- ---------------------------------------------------------------------------------------
-- AÑADIR NUEVOS ARCHIVOS A LA BASE DE DATOS
-- ---------------------------------------------------------------------------------------

-- Añadir un nuevo archivo de datos a un filegroup existente
ALTER DATABASE [NombreDB]
ADD FILE (
    NAME = N'NombreLogicoNuevoArchivo',
    FILENAME = N'D:\Ruta\A\Mi\Archivo.ndf',
    SIZE = 4GB,
    FILEGROWTH = 512MB
) TO FILEGROUP [PRIMARY]; -- O el filegroup que corresponda

-- Añadir un nuevo archivo de log
ALTER DATABASE [NombreDB]
ADD LOG FILE (
    NAME = N'NombreLogicoNuevoLog',
    FILENAME = N'L:\Ruta\A\Mi\Log.ldf',
    SIZE = 1GB,
    FILEGROWTH = 256MB
);


-- ---------------------------------------------------------------------------------------
-- REDUCCIÓN DE ARCHIVOS (SHRINK)
-- ¡¡¡ USAR CON PRECAUCIÓN !!! Puede causar fragmentación severa en archivos de datos.
-- ---------------------------------------------------------------------------------------

-- Reducir un archivo de log a un tamaño específico (ej. 256MB)
-- Es seguro para archivos de LOG si el log_reuse_wait_desc es 'NOTHING'.
USE [NombreDB];
GO
DBCC SHRINKFILE (N'NombreLogicoLog', 256);
GO

-- Reducir un archivo de datos (vaciar el espacio libre al final del archivo)
USE [NombreDB];
GO
DBCC SHRINKFILE (N'NombreLogicoDatos', TRUNCATEONLY);
GO

-- Vaciar un archivo para poder eliminarlo (EMPTYFILE)
USE [NombreDB];
GO
DBCC SHRINKFILE (N'ArchivoAEliminar', EMPTYFILE);
GO
-- Después de vaciarlo, se puede eliminar
ALTER DATABASE [NombreDB] REMOVE FILE [ArchivoAEliminar];
GO


-- ---------------------------------------------------------------------------------------
-- GESTIÓN DE BASES DE DATOS Y CACHÉ
-- ---------------------------------------------------------------------------------------

-- Ver el modo de recuperación de todas las bases de datos
SELECT name, recovery_model_desc, log_reuse_wait_desc FROM sys.databases;

-- Cambiar el modo de recuperación de una base de datos
ALTER DATABASE [NombreDB] SET RECOVERY SIMPLE; -- O FULL, O BULK_LOGGED
GO

-- Limpiar la caché (solo para entornos de prueba o para solucionar problemas específicos)
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;       -- Limpia el buffer pool de datos.
GO
DBCC FREEPROCCACHE;          -- Limpia el caché de planes de ejecución.
GO

*/