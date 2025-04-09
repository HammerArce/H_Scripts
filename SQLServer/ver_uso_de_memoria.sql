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