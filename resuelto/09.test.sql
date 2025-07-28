USE Empleados;
GO

DECLARE @tiempoini DATETIME2(6) = SYSDATETIME();

IF OBJECT_ID('valores_esperados', 'U') IS NOT NULL DROP TABLE valores_esperados;
IF OBJECT_ID('valores_encontrados', 'U') IS NOT NULL DROP TABLE valores_encontrados;

CREATE TABLE valores_esperados
(
    tabla VARCHAR(30) NOT NULL PRIMARY KEY,
    regs INT NOT NULL,
    crc_md5 VARCHAR(100) NOT NULL
);

CREATE TABLE valores_encontrados
(
    tabla VARCHAR(30) NOT NULL PRIMARY KEY,
    regs INT NOT NULL,
    crc_md5 VARCHAR(100) NOT NULL
);

INSERT INTO valores_esperados
VALUES
    ('empleados', 300024, '4ec56ab5ba37218d187cf6ab09ce1aa1'),
    ('departamentos', 9, '26eb605e3ec58718f8d588f005b3d2aa'),
    ('dept_respo', 24, '8720e2f0853ac9096b689c14664f847e'),
    ('dept_emp', 331603, 'ccf6fe516f990bdaa49713fc478701b7'),
    ('puestos', 443308, 'bfa016c472df68e70a03facafa1bc0a8'),
    ('sueldos', 2844047, 'fd220654e95aea1b169624ffe3fca934');

SELECT tabla, regs AS registros_esperados, crc_md5 AS crc_esperado
FROM valores_esperados;

-- empleados - hash incremental
DECLARE @crc_emp VARCHAR(32) = '';
DECLARE @id_emp VARCHAR(MAX), @fecha_nacimiento VARCHAR(MAX), @nombre VARCHAR(MAX), @apellido VARCHAR(MAX), @genero VARCHAR(MAX), @fecha_alta VARCHAR(MAX);

DECLARE empleado_cursor CURSOR FOR
    SELECT
    CAST(id_emp AS VARCHAR(MAX)),
    CAST(fecha_nacimiento AS VARCHAR(MAX)),
    CAST(nombre AS VARCHAR(MAX)),
    CAST(apellido AS VARCHAR(MAX)),
    CAST(genero AS VARCHAR(MAX)),
    CAST(fecha_alta AS VARCHAR(MAX))
FROM empleados
ORDER BY id_emp;

OPEN empleado_cursor;
FETCH NEXT FROM empleado_cursor INTO @id_emp, @fecha_nacimiento, @nombre, @apellido, @genero, @fecha_alta;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_emp = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5', 
        ISNULL(@crc_emp, '') + '#' +
        ISNULL(@id_emp, '') + '#' +
        ISNULL(@fecha_nacimiento, '') + '#' +
        ISNULL(@nombre, '') + '#' +
        ISNULL(@apellido, '') + '#' +
        ISNULL(@genero, '') + '#' +
        ISNULL(@fecha_alta, '')
    ), 2));
    FETCH NEXT FROM empleado_cursor INTO @id_emp, @fecha_nacimiento, @nombre, @apellido, @genero, @fecha_alta;
END

CLOSE empleado_cursor;
DEALLOCATE empleado_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'empleados',
        (SELECT COUNT(*)
        FROM empleados),
        @crc_emp
);

-- departamentos - hash incremental
DECLARE @crc_dept VARCHAR(32) = '';
DECLARE @id_dept VARCHAR(MAX), @nombre_dept VARCHAR(MAX);

DECLARE dept_cursor CURSOR FOR
    SELECT
    CAST(id_dept AS VARCHAR(MAX)),
    CAST(nombre_dept AS VARCHAR(MAX))
FROM departamentos
ORDER BY id_dept;

OPEN dept_cursor;
FETCH NEXT FROM dept_cursor INTO @id_dept, @nombre_dept;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_dept = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5',
        ISNULL(@crc_dept, '') + '#' +
        ISNULL(@id_dept, '') + '#' +
        ISNULL(@nombre_dept, '')
    ), 2));
    FETCH NEXT FROM dept_cursor INTO @id_dept, @nombre_dept;
END

CLOSE dept_cursor;
DEALLOCATE dept_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'departamentos',
        (SELECT COUNT(*)
        FROM departamentos),
        @crc_dept
);

-- dept_respo - hash incremental
DECLARE @crc_dept_respo VARCHAR(32) = '';
DECLARE @dr_id_dept VARCHAR(MAX), @dr_id_emp VARCHAR(MAX), @dr_fecha_desde VARCHAR(MAX), @dr_fecha_hasta VARCHAR(MAX);

DECLARE dept_respo_cursor CURSOR FOR
    SELECT
    CAST(id_dept AS VARCHAR(MAX)),
    CAST(id_emp AS VARCHAR(MAX)),
    CAST(fecha_desde AS VARCHAR(MAX)),
    CAST(fecha_hasta AS VARCHAR(MAX))
FROM dept_respo
ORDER BY id_dept, id_emp, fecha_desde, fecha_hasta;

OPEN dept_respo_cursor;
FETCH NEXT FROM dept_respo_cursor INTO @dr_id_dept, @dr_id_emp, @dr_fecha_desde, @dr_fecha_hasta;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_dept_respo = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5',
        ISNULL(@crc_dept_respo, '') + '#' +
        ISNULL(@dr_id_dept, '') + '#' +
        ISNULL(@dr_id_emp, '') + '#' +
        ISNULL(@dr_fecha_desde, '') + '#' +
        ISNULL(@dr_fecha_hasta, '')
    ), 2));
    FETCH NEXT FROM dept_respo_cursor INTO @dr_id_dept, @dr_id_emp, @dr_fecha_desde, @dr_fecha_hasta;
END

CLOSE dept_respo_cursor;
DEALLOCATE dept_respo_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'dept_respo',
        (SELECT COUNT(*)
        FROM dept_respo),
        @crc_dept_respo
);

-- dept_emp - hash incremental
DECLARE @crc_dept_emp VARCHAR(32) = '';
DECLARE @de_id_dept VARCHAR(MAX), @de_id_emp VARCHAR(MAX), @de_fecha_desde VARCHAR(MAX), @de_fecha_hasta VARCHAR(MAX);

DECLARE dept_emp_cursor CURSOR FOR
    SELECT
    CAST(id_dept AS VARCHAR(MAX)),
    CAST(id_emp AS VARCHAR(MAX)),
    CAST(fecha_desde AS VARCHAR(MAX)),
    CAST(fecha_hasta AS VARCHAR(MAX))
FROM dept_emp
ORDER BY id_dept, id_emp, fecha_desde, fecha_hasta;

OPEN dept_emp_cursor;
FETCH NEXT FROM dept_emp_cursor INTO @de_id_dept, @de_id_emp, @de_fecha_desde, @de_fecha_hasta;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_dept_emp = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5',
        ISNULL(@crc_dept_emp, '') + '#' +
        ISNULL(@de_id_dept, '') + '#' +
        ISNULL(@de_id_emp, '') + '#' +
        ISNULL(@de_fecha_desde, '') + '#' +
        ISNULL(@de_fecha_hasta, '')
    ), 2));
    FETCH NEXT FROM dept_emp_cursor INTO @de_id_dept, @de_id_emp, @de_fecha_desde, @de_fecha_hasta;
END

CLOSE dept_emp_cursor;
DEALLOCATE dept_emp_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'dept_emp',
        (SELECT COUNT(*)
        FROM dept_emp),
        @crc_dept_emp
);

-- puestos - hash incremental
DECLARE @crc_puestos VARCHAR(32) = '';
DECLARE @p_id_emp VARCHAR(MAX), @p_puesto VARCHAR(MAX), @p_fecha_desde VARCHAR(MAX), @p_fecha_hasta VARCHAR(MAX);

DECLARE puestos_cursor CURSOR FOR
    SELECT
    CAST(id_emp AS VARCHAR(MAX)),
    CAST(puesto AS VARCHAR(MAX)),
    CAST(fecha_desde AS VARCHAR(MAX)),
    CAST(fecha_hasta AS VARCHAR(MAX))
FROM puestos
ORDER BY id_emp, puesto, fecha_desde, fecha_hasta;

OPEN puestos_cursor;
FETCH NEXT FROM puestos_cursor INTO @p_id_emp, @p_puesto, @p_fecha_desde, @p_fecha_hasta;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_puestos = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5',
        ISNULL(@crc_puestos, '') + '#' +
        ISNULL(@p_id_emp, '') + '#' +
        ISNULL(@p_puesto, '') + '#' +
        ISNULL(@p_fecha_desde, '') + '#' +
        ISNULL(@p_fecha_hasta, '')
    ), 2));
    FETCH NEXT FROM puestos_cursor INTO @p_id_emp, @p_puesto, @p_fecha_desde, @p_fecha_hasta;
END

CLOSE puestos_cursor;
DEALLOCATE puestos_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'puestos',
        (SELECT COUNT(*)
        FROM puestos),
        @crc_puestos
);

-- sueldos - hash incremental
DECLARE @crc_sueldos VARCHAR(32) = '';
DECLARE @s_id_emp VARCHAR(MAX), @s_sueldo VARCHAR(MAX), @s_fecha_desde VARCHAR(MAX), @s_fecha_hasta VARCHAR(MAX);

DECLARE sueldos_cursor CURSOR FOR
    SELECT
    CAST(id_emp AS VARCHAR(MAX)),
    CAST(sueldo AS VARCHAR(MAX)),
    CAST(fecha_desde AS VARCHAR(MAX)),
    CAST(fecha_hasta AS VARCHAR(MAX))
FROM sueldos
ORDER BY id_emp, fecha_desde, fecha_hasta;

OPEN sueldos_cursor;
FETCH NEXT FROM sueldos_cursor INTO @s_id_emp, @s_sueldo, @s_fecha_desde, @s_fecha_hasta;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @crc_sueldos = LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5',
        ISNULL(@crc_sueldos, '') + '#' +
        ISNULL(@s_id_emp, '') + '#' +
        ISNULL(@s_sueldo, '') + '#' +
        ISNULL(@s_fecha_desde, '') + '#' +
        ISNULL(@s_fecha_hasta, '')
    ), 2));
    FETCH NEXT FROM sueldos_cursor INTO @s_id_emp, @s_sueldo, @s_fecha_desde, @s_fecha_hasta;
END

CLOSE sueldos_cursor;
DEALLOCATE sueldos_cursor;

INSERT INTO valores_encontrados
VALUES
    (
        'sueldos',
        (SELECT COUNT(*)
        FROM sueldos),
        @crc_sueldos
);

-- Resultados
SELECT
    e.tabla,
    CASE WHEN e.regs = f.regs THEN 'OK' ELSE 'No OK' END AS coinciden_registros,
    CASE WHEN e.crc_md5 = f.crc_md5 THEN 'OK' ELSE 'No OK' END AS coinciden_crc
FROM
    valores_esperados e
    INNER JOIN valores_encontrados f ON e.tabla = f.tabla;

DECLARE @crc_fail INT = (SELECT COUNT(*)
FROM valores_esperados e INNER JOIN valores_encontrados f ON e.tabla = f.tabla
WHERE f.crc_md5 != e.crc_md5);
DECLARE @count_fail INT = (SELECT COUNT(*)
FROM valores_esperados e INNER JOIN valores_encontrados f ON e.tabla = f.tabla
WHERE f.regs != e.regs);

DROP TABLE valores_esperados, valores_encontrados;

    SELECT 'Servidor' AS Resumen, CAST(SERVERPROPERTY('MachineName') AS VARCHAR(100)) AS Resultado
UNION ALL
    SELECT 'CRC', CASE WHEN @crc_fail = 0 THEN 'OK' ELSE 'Error' END
UNION ALL
    SELECT 'Cantidad', CASE WHEN @count_fail = 0 THEN 'OK' ELSE 'Error' END
UNION ALL
    SELECT 'Tiempo', CAST(DATEDIFF(MILLISECOND, @tiempoini, SYSDATETIME()) AS VARCHAR(50))
UNION ALL
    SELECT 'UUID' AS Resumen, CAST(NEWID() AS VARCHAR(36)) AS Resultado
