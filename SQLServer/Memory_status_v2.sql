SELECT 
 cpu_count,
 CAST(physical_memory_kb / 1024.0 AS DECIMAL(10, 2)) AS 'Total_RAM_of_OS(MB)',
 CAST(committed_target_kb / 1024.0 AS DECIMAL(10, 2)) AS 'Total_RAM_visible_to_SQLServer(MB)',
 CAST(committed_kb / 1024.0 AS DECIMAL(10, 2)) AS 'Total_RAM_used_by_SQLServer(MB)',
 CAST(
 (SELECT SUM(CASE WHEN is_modified = 1 THEN 1 ELSE 0 END) * 8 / 1024.0
 FROM sys.dm_os_buffer_descriptors
 WHERE database_id <> 32767) AS DECIMAL(10, 2)
 ) AS 'Total_dirty_buffers_of_SQLServer(MB)',
 CAST(
 (SELECT SUM(CASE WHEN is_modified = 1 THEN 0 ELSE 1 END) * 8 / 1024.0
 FROM sys.dm_os_buffer_descriptors
 WHERE database_id <> 32767) AS DECIMAL(10, 2)
 ) AS 'Total_clean_buffers_of_SQLServer(MB)',
 sqlserver_start_time,
 DATEDIFF(MINUTE, sqlserver_start_time, GETDATE()) AS serverUptime_min,
 virtual_machine_type,
 virtual_machine_type_desc,
 socket_count,
 cores_per_socket
FROM sys.dm_os_sys_info;
