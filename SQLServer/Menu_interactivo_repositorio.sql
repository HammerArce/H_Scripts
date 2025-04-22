----------HAMMER SANTAMARIA 11.04.2025-------------------
------------menu opciones repositorio
DECLARE @V_inst_ip_server AS VARCHAR(max);
DECLARE @all_repos as bit =			   1
DECLARE @instancia as bit =            0 -- set to 0 to skip first part
DECLARE @ips as bit =				   0 -- set to 0 to skip second part
DECLARE @server as bit =               0
------------------------------
SET @V_inst_ip_server = 'sqlusu';
--PRINT @V_inst_ip_server


IF @all_repos = 1
BEGIN
SELECT * FROM [DBA_Repository].[BaseLine].[Instances_HS_21_03];
END

IF @instancia = 1
BEGIN
SELECT * FROM [DBA_Repository].[BaseLine].[Instances_HS_21_03] where Instance like '%'+@V_inst_ip_server+'%';
END

IF @ips = 1
BEGIN
SELECT * FROM [DBA_Repository].[BaseLine].[Instances_HS_21_03] where IP like '%'+@V_inst_ip_server+'%';
END

IF @server = 1
BEGIN
SELECT * FROM [DBA_Repository].[BaseLine].[Instances_HS_21_03] where Server like '%'+@V_inst_ip_server+'%';
END
