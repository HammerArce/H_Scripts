-----------------Find a specific column in all tables
select * from INFORMATION_SCHEMA.COLUMNS 
where COLUMN_NAME like '%ColumnName%' 
order by TABLE_NAME;