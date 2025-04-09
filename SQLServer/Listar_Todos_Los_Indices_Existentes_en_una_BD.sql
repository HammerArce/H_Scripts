-- Usando el Enterprise Manager.., sólo podremos obtener la visión de una tabla y un índice al mismo tiempo

-- Usando el SP_Helpindex..., que sólo nos permite listar todos los índices de a una tabla por vez..

-- Utilizando la tabla sysindixes, con lo cual tendremos que escribir complejas sentencias para lograr algo útil.

--Pero no desesperen, aquí les traigo la solución. Espero les sea de utilidad, Saludos.
---------------------------------------------------------------------------------------------------------------------
-- Detalle: Este script lista todos los índices de una Base de Datos --
-- Gustavo Herrera para Sql Server Tips - http://gherrerasqlserver.blogspot.com/ --
---------------------------------------------------------------------------------------------------------------------

drop table #spindtab
set nocount on
declare @objname nvarchar(776), -- si quiero puedo ingresar el nombre de la tabla por parámetro
@objid int,
@indid smallint,
@groupid smallint,
@indname sysname,
@groupname sysname,
@status int,
@keys nvarchar(2126),
@dbname sysname,
@usrname sysname

-- Chequear para asegurarse que el nombre de la tabla entrado por parámetro pertenezca a la base de datos --
select @dbname = parsename(@objname,3)

if @dbname is not null and @dbname <> db_name()
begin
raiserror(15250,-1,-1)

end


-- Creación Tabla Temporal
create table #spindtab
(
usr_name sysname null,
table_name sysname null,
index_name sysname collate database_default null,
stats int null,
groupname sysname collate database_default null ,
index_keys nvarchar(2126) collate database_default null -- see @keys above for length descr
)


-- Se Guarda en un Curso el Id, Nombre de de la Tabla y Owner
declare ms_crs_tab cursor local static for
select
sysobjects.id,
sysobjects.name,
sysusers.name
from sysobjects
inner join sysusers
on sysobjects.uid = sysusers.uid
where type = 'U'

open ms_crs_tab
fetch ms_crs_tab
into @objid, @objname, @usrname

while @@fetch_status >= 0
Begin

-- Se consulta la tabla de índices.
declare ms_crs_ind cursor local static for
select
indid,
groupid,
name,
status
from sysindexes
where id = @objid and
indid between 1 and 254 and
(status & 64)=0
order by indid
open ms_crs_ind
fetch ms_crs_ind into
@indid,
@groupid,
@indname,
@status

-- Ahora se chequea cada índice, comprendiendo el tipo y el campo que utiliza, guardando la info
-- en una tabla temporal que será impresa al final

while @@fetch_status >= 0
begin
-- Primer vamos a entender cuales son las columnas involucradas
declare
@i int,
@thiskey nvarchar(131)

select @keys = index_col(@usrname + '.' + @objname, @indid, 1), @i = 2
if (indexkey_property(@objid, @indid, 1, 'isdescending') = 1)
select @keys = @keys + '(-)'

select @thiskey = index_col(@usrname + '.' + @objname, @indid, @i)
if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
select @thiskey = @thiskey + '(-)'

while (@thiskey is not null )
begin
select @keys = @keys + ', ' + @thiskey, @i = @i + 1
select @thiskey = index_col(@usrname + '.' + @objname, @indid, @i)
if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
select @thiskey = @thiskey + '(-)'
end

select @groupname = groupname from sysfilegroups where groupid = @groupid

-- Insertar una columna para el índice relevado
insert into #spindtab values (@usrname, @objname, @indname, @status, @groupname, @keys)

-- Vamos por el próximo índice
fetch ms_crs_ind into @indid, @groupid, @indname, @status
end
deallocate ms_crs_ind

-- Vamos a buscar otra tabla
fetch ms_crs_tab into @objid, @objname, @usrname
end
deallocate ms_crs_tab

-- SET UP SOME CONSTANT VALUES FOR OUTPUT QUERY
declare @empty varchar(1) select @empty = ''
declare @des1 varchar(35),
@des2 varchar(35),
@des4 varchar(35),
@des32 varchar(35),
@des64 varchar(35),
@des2048 varchar(35),
@des4096 varchar(35),
@des8388608 varchar(35),
@des16777216 varchar(35)
select @des1 = name from master.dbo.spt_values where type = 'I' and number = 1
select @des2 = name from master.dbo.spt_values where type = 'I' and number = 2
select @des4 = name from master.dbo.spt_values where type = 'I' and number = 4
select @des32 = name from master.dbo.spt_values where type = 'I' and number = 32
select @des64 = name from master.dbo.spt_values where type = 'I' and number = 64
select @des2048 = name from master.dbo.spt_values where type = 'I' and number = 2048
select @des4096 = name from master.dbo.spt_values where type = 'I' and number = 4096
select @des8388608 = name from master.dbo.spt_values where type = 'I' and number = 8388608
select @des16777216 = name from master.dbo.spt_values where type = 'I' and number = 16777216

-- DISPLAY THE RESULTS
select
'usr_name'=usr_name,
'table_name'=table_name,
'index_name' = index_name,
'index_description' = convert(varchar(210), --bits 16 off, 1, 2, 16777216 on, located on group
case when (stats & 16)<>0 then 'clustered' else 'nonclustered' end
+ case when (stats & 1)<>0 then ', '+@des1 else @empty end
+ case when (stats & 2)<>0 then ', '+@des2 else @empty end
+ case when (stats & 4)<>0 then ', '+@des4 else @empty end
+ case when (stats & 64)<>0 then ', '+@des64 else case when (stats & 32)<>0 then ', '+@des32 else @empty end end
+ case when (stats & 2048)<>0 then ', '+@des2048 else @empty end
+ case when (stats & 4096)<>0 then ', '+@des4096 else @empty end
+ case when (stats & 8388608)<>0 then ', '+@des8388608 else @empty end
+ case when (stats & 16777216)<>0 then ', '+@des16777216 else @empty end
+ ' located on ' + groupname),
'index_keys' = index_keys
from #spindtab
order by table_name, index_name

GO

drop table #spindtab