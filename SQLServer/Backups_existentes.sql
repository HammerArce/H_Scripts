SELECT
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    CAST(bs.backup_size / 1024 / 1024 AS DECIMAL(10, 2)) AS BackupSizeMB,
    CASE bs.[type]
        WHEN 'D' THEN 'Completo'
        WHEN 'I' THEN 'Diferencial'
        WHEN 'L' THEN 'Registro Transacción'
        WHEN 'F' THEN 'Archivo/Filegroup'
    END AS BackupType,
    bmf.physical_device_name
FROM
    msdb.dbo.backupset bs
INNER JOIN
    msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE
    bs.database_name = 'nombre de tu base de datos' -- Reemplaza con el nombre de tu base de datos
ORDER BY
    bs.backup_start_date DESC;
