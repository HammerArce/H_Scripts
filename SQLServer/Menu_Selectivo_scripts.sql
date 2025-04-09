------------ver estado de las ops
DECLARE @V_ORDEN_PEDIDO_ID AS NUMERIC(10);
Declare @valoresMetodo as bit =        1 -- set to 0 to skip first part
Declare @ErroresAgrupados as bit =     1 -- set to 0 to skip second part
DECLARE @logs as bit =                 1
DECLARE @ver_responsablepago as bit =  1
DECLARE @ver_ordenpedido as bit =      1
DECLARE @ver_solicitudtitular as bit = 1
DECLARE @ver_solicitudempresa as bit = 1
DECLARE @ver_pagoenlinea as bit =      0
DECLARE @estado_proyecto as bit =      1
------------------------------
SET @V_ORDEN_PEDIDO_ID = 2277952;
--PRINT @V_ORDEN_PEDIDO_ID
DECLARE @proy_id AS NUMERIC(5,0);
SET @proy_id = (select PROYECTO_ID FROM dbo.CEH_ORDEN_PEDIDO where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID)


IF @valoresMetodo = 1
BEGIN
SELECT * from [DYNAMICS].[CEH_VALORES_METODO] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID order by FECHA_REGISTRO DESC;
END

IF @ErroresAgrupados = 1
BEGIN
SELECT ORDEN_PEDIDO_ID, OBSERVACIONES from CEH_LOG_DYNAMICS where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID
	group by ORDEN_PEDIDO_ID, OBSERVACIONES
	order by ORDEN_PEDIDO_ID;
END

IF @logs = 1
BEGIN
--SELECT top 10 * from [dbo].[CEH_LOG_DYNAMICS] order by FECHA_CREACION DESC;
SELECT * from [dbo].[CEH_LOG_DYNAMICS] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID order by FECHA_CREACION DESC;
END

IF @ver_responsablepago = 1
BEGIN
SELECT 'responsable pago' As title, * from [dbo].[CEH_ORDEN_RESPONSABLE_PAGO] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID;
END

IF @ver_ordenpedido = 1
BEGIN
SELECT DESCRIPCION_TIPO_PERSONA from dbo.CEB_TIPO_PERSONA;
SELECT 'orden pedido' As title, * from [dbo].[CEH_ORDEN_PEDIDO] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID;
END

IF @ver_solicitudtitular = 1
BEGIN
SELECT 'solicitud titular' As title, * from [dbo].[CEH_SOLICITUD_TITULAR] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID;
END

IF @ver_solicitudempresa = 1
BEGIN
SELECT 'solicitud empresa' As title, * from [dbo].[CEH_SOLICITUD_EMPRESA] where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID;
END

IF @ver_pagoenlinea = 1
BEGIN
SELECT * FROM CEH_PAGO_EN_LINEA where ORDEN_PEDIDO_ID = @V_ORDEN_PEDIDO_ID;
END

IF @estado_proyecto = 1
BEGIN
SELECT * from dbo.CEB_PROYECTO where PROYECTO_ID = @proy_id;
END