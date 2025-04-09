SELECT TOP 10
    s.name AS SchemaName,          -- Schema name
    t.name AS TableName,           -- Table name
    t.create_date AS CreationDate, -- Creation timestamp
    SUM(ps.reserved_page_count) * 8 AS TotalSpaceKB, -- Total reserved space in Kilobytes
    CAST(SUM(ps.reserved_page_count) * 8.0 / 1024 AS DECIMAL(18, 2)) AS TotalSpaceMB  -- Total reserved space in Megabytes
FROM
    sys.tables AS t
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id -- Join to get schema name
INNER JOIN
    sys.dm_db_partition_stats AS ps ON t.object_id = ps.object_id -- Join to get partition stats (size)
WHERE
    t.is_ms_shipped = 0 -- Optional: Exclude Microsoft-shipped objects (system tables etc.)
    AND ps.index_id IN (0, 1) -- Consider only Heap (0) or Clustered Index (1) space for "table size"
                               -- Remove this line to include size of ALL non-clustered indexes too
GROUP BY
    s.name,         -- Group by Schema
    t.name,         -- Group by Table Name
    t.create_date   -- Group by Creation Date (necessary because it's in SELECT/ORDER BY)
ORDER BY
    --t.create_date ASC; -- Order by creation date ascending (oldest first)
	create_date ASC, TotalSpaceMB DESC;