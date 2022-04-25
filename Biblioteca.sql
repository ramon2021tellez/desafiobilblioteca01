
--Parte 1 - Creación del modelo conceptual, lógico y físico MODELO BIBLIOTECA.PDF 
--(01) modelo conceptual en pagina 1
--(02) modelo logico pagina 2 y 3 
--(03) modelo fisico pagina 4 R
--Parte 2 - Creando el modelo en la base de datos
\c ramonmiranda
--(01)Crear el modelo en una base de datos llamada 'bibliotecadata'
CREATE DATABASE bibliotecadata;
\c bibliotecadata
--creacion de tablas correspondientes
CREATE TABLE autor(
    id_autor SERIAL,
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    fecha_nac SMALLINT,
    fecha_def SMALLINT,
    PRIMARY KEY (id_autor)
);


CREATE TABLE libros(
    isbn BIGINT,
    titulo VARCHAR(40),
    paginas SMALLINT,
    limite_prestamo SMALLINT,
    existencia SMALLINT CHECK (existencia >= 0),
    PRIMARY KEY (isbn)
);

CREATE TABLE tipo_autor(
    isbn BIGINT,
    id_autor SMALLINT,
    tipo VARCHAR(10), 
    PRIMARY KEY (isbn,id_autor),
    FOREIGN KEY (isbn) REFERENCES libros,
    FOREIGN KEY (id_autor) REFERENCES autor
);

CREATE TABLE socios( 
    rut INT,
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    direccion VARCHAR(20) NOT NULL,
    telefono INT NOT NULL,
    prestamo BOOLEAN, 
    PRIMARY KEY (rut)
);


CREATE TABLE historial_prestamos(
    id_prestamo SERIAL,
    rut INT,
    isbn BIGINT,
    fecha_ini DATE,
    fecha_dev DATE,
    PRIMARY KEY (id_prestamo),
    FOREIGN KEY (rut) REFERENCES socios,
    FOREIGN KEY (isbn) REFERENCES libros
);


--(02) Se deben insertar los registros en las tablas correspondientes

INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) 
VALUES (11111111,'JUAN','SOTO','AVENIDA 1, SANTIAGO',911111111,FALSE);
INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) 
VALUES (22222222,'ANA', 'PEREZ',' PASAJE 2, SANTIAGO',922222222,FALSE);
INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) 
VALUES(33333333,'SANDRA', 'AGUILAR',' AVENIDA 2, SANTIAGO',933333333,FALSE);
INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) 
VALUES(44444444,'ESTEBAN', 'JEREZ',' AVENIDA 3, SANTIAGO',944444444,FALSE);
INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) 
VALUES(55555555,'SILVANA', 'MUNOZ',' PASAJE 3, SANTIAGO',955555555,FALSE);

SELECT * FROM socios;

INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def)
VALUES('ANDRES', 'ULLOA',1982,null);
INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def) 
VALUES('SERGIO', 'MARDONES', 1950,2012);
INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def) 
VALUES('JOSE', 'SALGADO', 1968,2020);
INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def) 
VALUES('ANA', 'SALGADO',1972,null);
INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def) 
VALUES('MARTIN', 'PORTA',1976,null);

INSERT INTO libros (isbn,titulo,paginas,limite_prestamo,existencia) 
VALUES(1111111111111, 'CUENTOS DE TERROR',344,7,1);
INSERT INTO libros (isbn,titulo,paginas,limite_prestamo,existencia) 
VALUES(2222222222222, 'POESIAS CONTEMPORANEAS',167,7,1);
INSERT INTO libros (isbn,titulo,paginas,limite_prestamo,existencia) 
VALUES(3333333333333, 'HISTORIA DE ASIA',511,14,1);
INSERT INTO libros (isbn,titulo,paginas,limite_prestamo,existencia) 
VALUES(4444444444444, 'MANUAL DE MECANICA',298,14,1);

INSERT INTO tipo_autor (isbn,id_autor,tipo) 
VALUES(1111111111111,3, 'PRINCIPAL'),
INSERT INTO tipo_autor (isbn,id_autor,tipo) 
VALUES(1111111111111,4, 'COAUTOR'),
INSERT INTO tipo_autor (isbn,id_autor,tipo) 
VALUES(2222222222222,1, 'PRINCIPAL'),
INSERT INTO tipo_autor (isbn,id_autor,tipo) 
VALUES(3333333333333,2, 'PRINCIPAL'),
INSERT INTO tipo_autor (isbn,id_autor,tipo) 
VALUES(4444444444444,5, 'PRINCIPAL');

INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(11111111,1111111111111,'2020-01-20','2020-01-27');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(55555555,2222222222222,'2020-01-20','2020-01-30');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(33333333,3333333333333,'2020-01-22','2020-01-30');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(44444444,4444444444444,'2020-01-23','2020-01-30');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(22222222,1111111111111,'2020-01-27','2020-02-04');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(11111111,4444444444444,'2020-01-31','2020-02-12');
INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) 
VALUES(33333333,2222222222222,'2020-01-31','2020-02-12');

--(03) Realizar las siguientes consultas:
--[a] Mostrar todos los libros que posean menos de 300 páginas.
SELECT titulo, paginas FROM libros WHERE paginas < 300;

--[b] Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT nombre, apellido, fecha_nac FROM autor WHERE fecha_nac > 1970;

--[c] ¿Cuál es el libro más solicitado?
SELECT titulo, COUNT(libros.isbn) AS demanda 
FROM libros 
INNER JOIN historial_prestamos ON libros.isbn = historial_prestamos.isbn 
GROUP BY titulo 
ORDER BY demanda DESC;

--[d] Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT 
    historial_prestamos.id_prestamo,
    historial_prestamos.rut,
    socios.nombre,
    socios.apellido,
    (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini) as dias_prestamo, 
    libros.limite_prestamo, 
    (libros.limite_prestamo - (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini)) AS dias_multa,
    ((libros.limite_prestamo - (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini))*100) AS multa_total
FROM (historial_prestamos INNER JOIN socios ON historial_prestamos.rut=socios.rut)
INNER JOIN libros ON historial_prestamos.isbn=libros.isbn
WHERE (fecha_dev - fecha_ini)>7
--AND (libro.limite_prestamo - (prestamo.fecha_dev - prestamo.fecha_ini))>0   --Descomentar en cuyo caso sólo se deseen obtener los valores de multa positivos.
;
--Comando reservado para base de datos con fines educativos
DROP TABLE historial_prestamos;
DROP TABLE socios;
DROP TABLE tipo_autor;
DROP TABLE libros;
DROP TABLE autor;