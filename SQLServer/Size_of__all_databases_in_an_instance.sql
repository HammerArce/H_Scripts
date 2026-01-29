/****************************************************************************************
*   SCRIPT PARA VER LOS PESOS DE LAS BASES DE DATOS                                     *
*                                                                                       *
*   Descripción:                                                                        *
*   Este script Muestra los pesos de las bases de datos en megas, gigas y teras         *
*                                                                                       *
*   HAMMER	- 2026																        *
****************************************************************************************/

-- Database and size in MegaBytes
SELECT
    @@SERVERNAME AS INTANCE,
    d.name AS DatabaseName,
    CAST(SUM(CAST(mf.size AS BIGINT)) * 8 / 1024.0 AS DECIMAL(18,2)) AS TotalSize_MegaBytes
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb')
GROUP BY d.name
ORDER BY TotalSize_MegaBytes DESC;


-- Database and size in GigaBytes
SELECT 
    @@SERVERNAME AS INTANCE,
    d.name AS DatabaseName,
    CAST(SUM(CAST(mf.size AS BIGINT)) * 8 / 1024.0/ 1024.0 AS DECIMAL(18,2)) AS TotalSize_GigaBytes
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb')
GROUP BY d.name
ORDER BY TotalSize_GigaBytes DESC;


-- Database and size in TeraBytes
SELECT 
    @@SERVERNAME AS INTANCE,
    d.name AS DatabaseName,
    CAST(SUM(CAST(mf.size AS BIGINT)) * 8 / 1024.0/ 1024.0 / 1024.0 AS DECIMAL(18,2)) AS TotalSize_TeraBytes
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb')
GROUP BY d.name
ORDER BY TotalSize_TeraBytes DESC;
