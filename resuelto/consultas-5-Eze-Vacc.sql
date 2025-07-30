-- ============================================================================
-- Trabajo Práctico - Punto 5: Consultas sobre empleados y departamentos
-- Parámetros asignados: id_emp = 35696 / id_dept = 'd006'
-- ============================================================================

USE Empleados;
GO

-- ============================================================================
-- a) Datos del empleado si alguna vez trabajó en el departamento asignado
-- ============================================================================

USE Empleados;
DECLARE @id_emp INT = 35696;
DECLARE @id_dept CHAR(4) = 'd006';
SELECT e.id_emp,
    e.fecha_nacimiento,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.genero,
    e.fecha_alta
FROM empleados e
    JOIN dept_emp d ON e.id_emp = d.id_emp
WHERE e.id_emp = @id_emp AND d.id_dept = @id_dept;

GO

-- ============================================================================
-- b) Datos del empleado si ya no trabaja actualmente en el departamento
-- ============================================================================
DECLARE @id_emp INT = 35696;
DECLARE @id_dept CHAR(4) = 'd006';
SELECT e.id_emp,
    e.fecha_nacimiento,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.genero,
    e.fecha_alta
FROM empleados e
    JOIN dept_emp d ON e.id_emp = d.id_emp
WHERE e.id_emp = @id_emp AND d.id_dept = @id_dept
    AND d.fecha_hasta < CAST(GETDATE() AS DATE);

GO

-- ============================================================================
-- c) Responsable actual del departamento asignado
-- ============================================================================
DECLARE @id_dept CHAR(4) = 'd006';
SELECT e.id_emp,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo
FROM dept_respo dr
    JOIN empleados e ON dr.id_emp = e.id_emp
WHERE dr.id_dept = @id_dept
    AND dr.fecha_hasta = '9999-01-01';

GO

-- ============================================================================
-- d) Departamento actual o último del empleado
-- ============================================================================
DECLARE @id_emp INT = 35696;
SELECT TOP 1
    e.id_emp,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    d.nombre_dept,
    de.fecha_hasta
FROM empleados e
    LEFT JOIN dept_emp de ON e.id_emp = de.id_emp
    LEFT JOIN departamentos d ON de.id_dept = d.id_dept
WHERE e.id_emp = @id_emp
ORDER BY de.fecha_hasta DESC;

GO

-- ============================================================================
-- e) Departamento actual o último + apellido del responsable actual
-- ============================================================================
DECLARE @id_emp INT = 35696;
SELECT TOP 1
    e.id_emp,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    d.nombre_dept,
    de.fecha_hasta,
    r.apellido AS responsable_apellido
FROM empleados e
    LEFT JOIN dept_emp de ON e.id_emp = de.id_emp
    LEFT JOIN departamentos d ON de.id_dept = d.id_dept
    LEFT JOIN dept_respo dr ON d.id_dept = dr.id_dept AND dr.fecha_hasta = '9999-01-01'
    LEFT JOIN empleados r ON r.id_emp = dr.id_emp
WHERE e.id_emp = @id_emp
ORDER BY de.fecha_hasta DESC;

GO

-- ============================================================================
-- f) Porcentaje de aumento (mayor sueldo vs menor sueldo)
-- ============================================================================
DECLARE @id_emp INT = 35696;
SELECT
    FORMAT(
        (CAST(MAX(sueldo) AS FLOAT) - MIN(sueldo)) * 100.0 / NULLIF(MIN(sueldo), 0),
        'N2'
    ) + '%' AS porcentaje_aumento
FROM sueldos
WHERE id_emp = @id_emp;
GO

-- ============================================================================
-- g) Empleados actuales del depto d006 con sueldo > 120000
-- y puesto que contenga "Engineer" o "Senior"
-- ============================================================================
SELECT DISTINCT e.id_emp, e.fecha_nacimiento, e.nombre, e.apellido, e.genero
FROM empleados e
    JOIN dept_emp de ON e.id_emp = de.id_emp
    JOIN sueldos s ON e.id_emp = s.id_emp
    JOIN puestos p ON e.id_emp = p.id_emp
    JOIN puesto_descr pd ON p.id_puesto = pd.id_puesto
WHERE de.id_dept = 'd006'
    AND de.fecha_hasta = '9999-01-01'
    AND s.fecha_hasta = '9999-01-01'
    AND (
      pd.descripcion_en LIKE '%Engineer%' OR
    pd.descripcion_en LIKE '%Senior%'
  )
    AND s.sueldo > 120000;
GO

-- ============================================================================
--  h) Agregar el nuevo departamento: d010 - Inteligencia Artificial
-- ============================================================================
IF NOT EXISTS (SELECT 1
FROM departamentos
WHERE id_dept = 'd010')
BEGIN
    INSERT INTO departamentos
        (id_dept, nombre_dept)
    VALUES
        ('d010', 'Inteligencia Artificial');
END;
GO

-- ============================================================================
--  i.1) Asignar empleados de g) al nuevo departamento d010
-- desde el 01/01/2023 (evitar duplicados)
-- ============================================================================
INSERT INTO dept_emp
    (id_emp, id_dept, fecha_desde, fecha_hasta)
SELECT DISTINCT e.id_emp, 'd010', '2023-01-01', '9999-01-01'
FROM empleados e
    JOIN dept_emp de ON e.id_emp = de.id_emp
    JOIN sueldos s ON e.id_emp = s.id_emp
    JOIN puestos p ON e.id_emp = p.id_emp
    JOIN puesto_descr pd ON p.id_puesto = pd.id_puesto
WHERE de.id_dept = 'd006'
    AND de.fecha_hasta = '9999-01-01'
    AND s.fecha_hasta = '9999-01-01'
    AND (
      pd.descripcion_en LIKE '%Engineer%' OR
    pd.descripcion_en LIKE '%Senior%'
  )
    AND s.sueldo > 120000
    AND NOT EXISTS (
      SELECT 1
    FROM dept_emp d2
    WHERE d2.id_emp = e.id_emp AND d2.id_dept = 'd010' AND d2.fecha_desde = '2023-01-01'
  );
GO

-- ============================================================================
--  i.2) Otorgar aumento del 15% desde 01/01/2023 a esos empleados
-- evitando sueldos duplicados
-- ============================================================================
INSERT INTO sueldos
    (id_emp, sueldo, fecha_desde, fecha_hasta)
SELECT s.id_emp,
    CAST(s.sueldo * 1.15 AS INT),
    '2023-01-01',
    '9999-01-01'
FROM sueldos s
    JOIN dept_emp de ON s.id_emp = de.id_emp
    JOIN puestos p ON s.id_emp = p.id_emp
    JOIN puesto_descr pd ON p.id_puesto = pd.id_puesto
WHERE de.id_dept = 'd006'
    AND de.fecha_hasta = '9999-01-01'
    AND s.fecha_hasta = '9999-01-01'
    AND (
      pd.descripcion_en LIKE '%Engineer%' OR
    pd.descripcion_en LIKE '%Senior%'
  )
    AND s.sueldo > 120000
    AND NOT EXISTS (
      SELECT 1
    FROM sueldos s2
    WHERE s2.id_emp = s.id_emp AND s2.fecha_desde = '2023-01-01'
  );
GO

-- ============================================================================
-- j) Cantidad de empleados y sueldo promedio por departamento actual
-- ============================================================================
SELECT d.nombre_dept,
    COUNT(DISTINCT de.id_emp) AS cantidad_empleados,
    AVG(s.sueldo * 1.0) AS sueldo_promedio
FROM dept_emp de
    JOIN departamentos d ON de.id_dept = d.id_dept
    JOIN sueldos s ON de.id_emp = s.id_emp
WHERE de.fecha_hasta = '9999-01-01'
    AND s.fecha_hasta = '9999-01-01'
GROUP BY d.nombre_dept;

GO
