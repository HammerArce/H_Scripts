 ----------------------------------------------------------------------
-- Detalle: Estudia La Historia de Ejecución de un Job A Partir de una Fecha
-- Tip: Utiliza la tablas msdb SysJobHistory/SysJobs    
--seteen el run_date para limitar la fecha para la cual quieren la data.
-----------------------------------------------------------------------


 use msdb
 select
 step_id,
 message,
 run_date,
 case
   len(run_duration) when  6 then left(convert(varchar(6), run_duration),2)+':'+substring(convert(varchar(6), run_duration),3,2)+':'+right(convert(varchar(6),run_duration),2)
                     when  5 then '0'+left(convert(varchar(5), run_duration),1)+':'+substring(convert(varchar(5), run_duration),2,2)+':'+right(convert(varchar(6),run_duration),2)   
                     when  4 then '00'+':'+left(convert(varchar(4),run_duration),2)+':'+right(convert(varchar(4),run_duration),2)
                     when  3 then '00:0'+left(convert(varchar(3),run_duration),1)+':'+right(convert(varchar(4),run_duration),2)     
        end       
         as 'run_duration',
 case run_status when 0 then 'failed'
                  when  1 then 'succeded'
                  when 2 then 'retry'
                  when 3 then 'canceled'
                 end as 'run_status'
 from
 SysJobHistory as a
 --
 left join SysJobs  as b
 on a.job_id = b.job_id
 --
where
b.name = 'DBA - Indexes Optimize - Arcalltv - Miercoles 6 AM' and
run_date > 20130902
order by run_date