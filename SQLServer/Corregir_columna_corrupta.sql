-------------corregir columna corrupta---------------
---Determinar si la columna es computed o persisted
SELECT COLUMN_NAME, DATA_TYPE, COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME), COLUMN_NAME, 'IsComputed') AS IsComputed,
       COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME), COLUMN_NAME, 'IsPersisted') AS IsPersisted
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CHURN_HISTORICO' AND COLUMN_NAME = 'PARQUE';

--Si es computed sacar la columna computada para crearse nuevamente
SELECT definition
FROM sys.computed_columns
WHERE object_id = OBJECT_ID('dbo.CHURN_HISTORICO') AND name = 'PARQUE';

--Se elimina la columna
ALTER TABLE dbo.CHURN_HISTORICO DROP COLUMN PARQUE;

--Se crea la columna con el resultado   SELECT definition FROM sys.computed_columns
ALTER TABLE dbo.CHURN_HISTORICO ADD PARQUE AS (case when ([PARQUE_TABLA] = 'A30') then 'CORRIENTE' when ([PARQUE_TABLA] = 'A60') then '30-60' when ([PARQUE_TABLA] = 'A90') then '60-90' when ([PARQUE_TABLA] = 'CH') then 'CHURN' when ([PARQUE_TABLA] = 'RD') then 'REACTIVADO' when ([PARQUE_TABLA] = 'NN') then 'NONATO' else [PARQUE_TABLA] end)