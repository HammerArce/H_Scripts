-- Asegúrate de estar conectado a la base de datos correcta antes de ejecutar este script.
-- USE TuBaseDeDatos; -- Descomenta y reemplaza 'TuBaseDeDatos' si es necesario.

SELECT
    s.name AS Esquema,                      -- Nombre del esquema de la tabla
    t.name AS NombreTabla,                  -- Nombre de la tabla
    SUM(p.rows) AS NumeroRegistros,         -- Suma de las filas de todas las particiones de la tabla
    CAST(SUM(a.total_pages) * 8 / 1024.0 AS DECIMAL(18, 2)) AS TamanoTotalMB -- Tamaño total reservado (datos + índices) en MB
    -- Alternativa: Tamaño usado (puede ser menor que el reservado)
    -- CAST(SUM(a.used_pages) * 8 / 1024.0 AS DECIMAL(18, 2)) AS TamanoUsadoMB
FROM
    sys.tables t                        -- Vista del sistema para tablas
INNER JOIN
    sys.schemas s ON t.schema_id = s.schema_id -- Une con esquemas para obtener el nombre del esquema
INNER JOIN
    sys.indexes i ON t.object_id = i.object_id -- Une con índices (necesario para enlazar con particiones)
INNER JOIN
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id -- Une con particiones para obtener el conteo de filas
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id -- Une con unidades de alocación para obtener el tamaño en páginas (8KB cada página)
WHERE
    t.type_desc = 'USER_TABLE'          -- Filtra solo para tablas de usuario (excluye tablas del sistema)
    AND t.is_ms_shipped = 0             -- Otra forma de asegurar que no son tablas del sistema
    AND i.object_id > 255               -- Excluye objetos internos del sistema con IDs bajos
GROUP BY
    t.object_id,                        -- Agrupa por el ID único de la tabla
    s.name,                             -- Agrupa por nombre de esquema
    t.name                              -- Agrupa por nombre de tabla
ORDER BY
    TamanoTotalMB DESC,                 -- Ordena primero por tamaño total en MB (descendente)
    NumeroRegistros DESC;               -- Luego ordena por número de registros (descendente)

    