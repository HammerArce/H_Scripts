-- Obtener la cantidad de memoria total de la máquina
DECLARE @TotalMemoryMB DECIMAL(10, 2);
SELECT 
    @TotalMemoryMB = (physical_memory_kb / 1024.0)
FROM 
    sys.dm_os_sys_info;

	--obtener memoria max seteada por la instancia
DECLARE @MaxintanceMemory DECIMAL;
 SELECT 
 @MaxintanceMemory = CAST(Value_in_use AS DECIMAL)
 FROM sys.configurations
 where name = 'max server memory (MB)';
	
--obtener el % de memoria asignado a la instancia
DECLARE @percentageAssigned DECIMAL(5, 2);
SET @percentageAssigned = ((@MaxintanceMemory / @TotalMemoryMB) * 100)


-- Obtener la cantidad de memoria asignada a la instancia de SQL Server
DECLARE @AssignedMemoryMB DECIMAL(10, 2);
SELECT 
    @AssignedMemoryMB = (COUNT(*) * 8 / 1024.0)
FROM 
    sys.dm_os_buffer_descriptors;

-- Calcular el porcentaje de memoria asignada con respecto a la memoria total
DECLARE @PercentageUsed DECIMAL(5, 2);
SET @PercentageUsed = ((@AssignedMemoryMB / @TotalMemoryMB) * 100);

-- Calcular la categoría de uso de memoria
DECLARE @MemoryCategory VARCHAR(10);
IF @PercentageUsed <= 60
    SET @MemoryCategory = 'Bajo';
ELSE IF @PercentageUsed BETWEEN 61 AND 70
    SET @MemoryCategory = 'Medio';
ELSE
    SET @MemoryCategory = 'Alto';

-- Mostrar el resultado en un solo conjunto de resultados
SELECT 
@@SERVERNAME Servername,
    @TotalMemoryMB AS [Server Memory (MB)],
	(SELECT value_in_use FROM sys.configurations WHERE name like '%max server memory%') AS 'Max Instancia Memory',
	@percentageAssigned AS [Porcentage Asignado], 
    @AssignedMemoryMB AS [Memoria Asignada utilizada (MB)], 
    @PercentageUsed AS [Porcentaje Asignado Ulizado],
       @MemoryCategory AS [Consumo];







-----------------------------------------------------
-------------------------- memory in use
select
(physical_memory_in_use_kb/1024)Phy_Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1024 )Locked_pages_used_Sqlserver_MB,
(virtual_address_space_committed_kb/1024 )Total_Memory_UsedBySQLServer_MB,
process_physical_memory_low,
process_virtual_memory_low
from sys. dm_os_process_memory

------------------------ View the value of max server memory (MB)
SELECT [value], [value_in_use]
FROM sys.configurations WHERE [name] = 'max server memory (MB)';


