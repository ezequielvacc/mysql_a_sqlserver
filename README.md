# 🚀 Trabajo Práctico 1

![version](https://img.shields.io/badge/version-1.0.0-blue)
![status](https://img.shields.io/badge/status-completo-brightgreen)
![license](https://img.shields.io/badge/license-MIT-yellow)

---

> [!NOTE]
> Este repositorio contiene la resolución de los puntos 1 al 5 del archivo PDF titulado **Trabajo Práctico 1**.  
> Asegurate de seguir los pasos correctamente antes de ejecutar el archivo SQL.

---


> [!IMPORTANT]
> El script `1-create.sql` busca archivos en `C:\datos\`.  
> Si no está correctamente ubicada, el script fallará al ejecutarse.

---
## 🛠️ Pasos para ejecutar correctamente

### ✅ 1. Clonar o descargar el repositorio
1. Ir al repositorio: https://github.com/ezequielvacc/mysql_a_sqlserver
2. Hacer clic en el botón verde “Code” y luego elegir “Download ZIP”.
3. Extraer el ZIP en el Escritorio.

O
si tiene git instalado 
```bash
git clone https://github.com/ezequielvacc/mysql_a_sqlserver.git
```
> [!TIP]
> Podés mover la carpeta `datos` al disco `C:` manualmente o utilizando comandos desde la terminal (CMD).
> Comando para CMD 
```bash
@echo off
setlocal

REM Ruta origen: carpeta datos dentro de la carpeta clonada o descomprimida en el escritorio
set "ORIGEN=%USERPROFILE%\Desktop\mysql_a_sqlserver\datos"
set "DESTINO=C:\datos"

REM Verifica si la carpeta origen existe
if exist "%ORIGEN%" (
    echo Moviendo carpeta 'datos' a C:\...
    move "%ORIGEN%" "%DESTINO%"
    echo Carpeta movida correctamente a %DESTINO%
) else (
    echo La carpeta origen no fue encontrada: %ORIGEN%
)

pause
```
---
> Manual
**Instrucciones para preparar los archivos CSV:**

1. Abrir la carpeta `mysql_a_sqlserver-main` (o nombre similar).
2. Dentro estará la carpeta `datos`.
3. Mover la carpeta `datos` al disco C: directamente.
   - Para ello: arrastrar con el mouse la carpeta desde el Explorador de archivos hasta `Este equipo > Disco local (C:)`.
4. Confirmar si el destino final es `C:\datos`.



---

---
## 📝 Descripción

Este documento detalla paso a paso el contenido y la finalidad de cada sección del archivo 1-create.sql, en el contexto del Trabajo Práctico de migración de una base de datos de MySQL a SQL Server.

1. Creación de la base de datos

CREATE DATABASE Empleados;
USE Empleados;

Razón de uso: Se crea la base de datos solicitada en el enunciado y se establece como contexto de trabajo para las siguientes operaciones.

2. Tabla empleados

Define la información básica de cada empleado (ID, nombre, apellido, fecha de nacimiento, género, alta).

Razón de uso: Se implementa la tabla de empleados según el modelo relacional definido en el PDF, adaptando el tipo ENUM de MySQL a CHECK en SQL Server.

3. Tabla departamentos

Contiene los departamentos de la empresa, con clave primaria id_dept.

Razón de uso: Se crea esta tabla para cumplir con la estructura relacional descripta en el trabajo práctico.

4. Tabla dept_emp

Registra el historial de asignación de empleados a departamentos.

Razón de uso: Esta tabla está definida en el modelo entregado y permite llevar un registro de las fechas en que un empleado trabajó en un departamento.

5. Tabla dept_respo

Almacena los responsables de cada departamento en distintos periodos.

Razón de uso: Se incluye como parte del modelo definido en el PDF para vincular empleados como responsables temporales de departamentos.

6. Tabla puestos

Guarda el historial de cargos ocupados por cada empleado.

Razón de uso: Se implementa de acuerdo con el modelo provisto, que contempla el seguimiento de los cargos ocupados por cada empleado.

7. Tabla sueldos

Contiene el historial de sueldos para cada empleado.

Razón de uso: Se incluye según el modelo relacional del trabajo, para almacenar sueldos asociados a fechas de vigencia.

8. Carga manual de departamentos (Archivo 01)

Se insertan manualmente los 9 departamentos iniciales.

Razón de uso: El archivo de datos 01 del enunciado contiene los departamentos y debe ser cargado primero según el orden establecido.

9 al 15. Carga de datos con BULK INSERT

Se utilizan comandos BULK INSERT para cargar los archivos CSV desde disco:

BULK INSERT empleados FROM 'C:\datos\datos_emp.csv' WITH (...)

Razón de uso: Según el enunciado, se deben cargar archivos numerados del 01 al 08 en orden, y contienen grandes volúmenes de datos. Se usa BULK INSERT para procesar directamente archivos CSV, debido a que el uso de múltiples INSERT INTO no es práctico para más de 300.000 registros. Se ajustan los parámetros de formato (FIELDTERMINATOR, ROWTERMINATOR, CODEPAGE) para respetar la estructura y codificación de los archivos provistos.

16. Verificación de integridad con MD5

Se crean las tablas valores_esperados y valores_encontrados para realizar una verificación de integridad, similar al archivo original 09.test.sql de MySQL.

Se cargan los valores esperados (cantidad de registros y hash MD5) manualmente.

Luego, para cada tabla (empleados, departamentos, dept_respo, etc.), se calculan:

la cantidad de registros reales,

un hash MD5 incremental sobre las filas, ordenadas según claves relevantes.

Razón de uso: El punto 3 del trabajo práctico exige una validación poscarga que incluya control de cantidad de registros y control CRC/MD5. En SQL Server no existe la función MD5 directamente, por eso se usó HASHBYTES('MD5', ...) con CONVERT y cursores para replicar el cálculo incremental implementado con CONCAT_WS y variables acumuladoras en MySQL.

El hash incremental es necesario porque el orden y los datos completos de cada fila afectan el resultado, replicando el comportamiento del script 09.test.sql que utilizaba variables @crc := MD5(...) en una tabla temporal tchecksum.

Finalmente, se comparan los valores encontrados con los esperados, y se genera un resumen con tiempo de ejecución y UUID mediante NEWID() como reemplazo de @@server_uuid de MySQL.

17. Tabla puesto_descr

Se normalizan los valores de la columna puesto.

Razón de uso: En el punto 4a del trabajo se pide crear una tabla adicional con los puestos originales, sus traducciones al español y un identificador.

18. Inserción de descripciones de puesto

Razón de uso: En el mismo punto 4a se indica que deben cargarse las traducciones al español correspondientes a los puestos detectados.

19. Tabla puestos_normalizada

Se crea una nueva versión de la tabla puestos que utiliza el ID de puesto_descr.

Razón de uso: Corresponde al punto 4b del enunciado, que solicita reemplazar los nombres por el identificador definido en puesto_descr.

20. Migración de datos normalizados

Se migran los datos desde la antigua tabla puestos a la nueva tabla normalizada.

Razón de uso: Se realiza para cumplir el requerimiento de utilizar identificadores en vez de texto en la tabla puestos.

21. Eliminación de tabla antigua y renombrado

DROP TABLE puestos;
EXEC sp_rename 'puestos_normalizada', 'puestos';

Razón de uso: Se solicita que la nueva tabla normalizada reemplace a la original conservando el mismo nombre.

---

