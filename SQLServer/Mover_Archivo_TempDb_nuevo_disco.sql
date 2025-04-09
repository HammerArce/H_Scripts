/*Muchas veces nos encontramos ante la necesidad de mover, de relocalizar, el archivo MDF correspondiente a la TempDb, o su archivo de Log.

Como todos sabemos el tempdb crece en tamaño ante operaciones que requieren mucho uso de memoria en general.

Pues bien, dispuestos entonces a "mover" los archivos de la TempDb hacia un disco con mayor capacidad, seguramente intentaremos dettachar la base para luego mover el archivo y volver a attachar. Wrong. No es posible dettachar una base del sistema.

Cuál es entonces la forma correcta de hacerlo?, aquí les dejo los pasos a saber:*/

--1) Utilizar una nueva query en el Management Estudio y valiéndose de un Alter Database reubicar el archivo.

USE master;
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, FILENAME = '{nueva ruta}\tempdb.mdf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, FILENAME = '{nueva ruta}\templog.ldf');
GO

--(*) Donde dice "nueva ruta", escribir la nueva ruta de los archivos.


--2) Una vez que han ejecutado lo escrito en el punto 1), simplemente reinicien el servicio del sql server y listo, la TempDb se habrá "relocalizado" y sus problemas de espacio en disco habrán encontrado una solución. (no se olviden de borrar el viejo archivo tempdb)

--3) Vamos a comprobar que nuestra nueva localización sea la deseada escribiendo y ejecutando lo sigte:

SELECT name, physical_name
FROM sys.master_files
WHERE database_id = DB_ID('tempdb');


--Amigos, sencillo pero útil. Como siempre quedo a disposición de uds, saludos.