DROP DATABASE IF EXISTS LaPicaditaJarocha;
CREATE DATABASE LaPicaditaJarocha;
USE LaPicaditaJarocha;

-- tabla razones sociales
CREATE TABLE RazonSocial (
    razon_social_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255) NOT NULL 
    , rfc VARCHAR(13) NOT NULL
    , curp VARCHAR(19)
);

/* carga de datos para razones sociales */
LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/razones_sociales.csv'
    INTO TABLE RazonSocial
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (nombre, rfc, curp);

-- tabla sucursales
CREATE TABLE Sucursal (
    sucursal_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255) NOT NULL
    , direccion VARCHAR(255)
    , numero_telefonico VARCHAR(10)
    , razon_social_id INT
    , CONSTRAINT sucursal_razon_social FOREIGN KEY (razon_social_id)
        REFERENCES RazonSocial(razon_social_id) ON DELETE CASCADE
);

/* carga de datos para sucursales */
LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/sucursales.csv'
INTO TABLE Sucursal
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nombre, direccion, numero_telefonico, razon_social_id)
SET numero_telefonico = NULLIF(numero_telefonico , '');

-- tabla mesas
CREATE TABLE Mesa (
    mesa_id INT AUTO_INCREMENT PRIMARY KEY
    , total_personas INT
    , sucursal_id INT
    , CONSTRAINT mesa_sucursal FOREIGN KEY (sucursal_id)
        REFERENCES Sucursal(sucursal_id) ON DELETE CASCADE    
);

-- tabla empresas
CREATE TABLE Empresa ( 
    empresa_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255)
    , fecha_hora_registro DATETIME DEFAULT CURRENT_TIMESTAMP
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

/* carga datos de empresas */
LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/empresas.csv'
INTO TABLE Empresa
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nombre);

-- tabla alianzas comerciales
CREATE TABLE AlianzaComercial (
    alianza_comercial_id INT AUTO_INCREMENT PRIMARY KEY
    , empresa_id INT
    , CONSTRAINT alianza_comercial_empresa FOREIGN KEY (empresa_id)
        REFERENCES Empresa(empresa_id) ON DELETE CASCADE
    , fecha_hora_inicio DATETIME
    , fecha_hora_fin DATETIME
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
    , monto_minimo_consumo DECIMAL(10, 2)
);

/* carga datos de las alianzas comerciales */
LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/alianzas_comerciales.csv'
INTO TABLE AlianzaComercial
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(empresa_id, fecha_hora_inicio, @monto_minimo_consumo)
SET monto_minimo_consumo = CAST(@monto_minimo_consumo AS DECIMAL(10, 2));

-- tabla roles
CREATE TABLE Rol (
    rol_id INT AUTO_INCREMENT PRIMARY KEY
    , rol VARCHAR(255)
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

/* carga datos de los roles */
INSERT INTO Rol (rol) VALUES
    ('Administrador')
    , ('Cajero')
    , ('Mesero')
    , ('Cocinero')
    , ('Garrotero');

-- tabla empleados
CREATE TABLE Empleado (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255)
    , nombre_usuario VARCHAR(10)
    , apellido_paterno VARCHAR(255)
    , apellido_materno VARCHAR(255)
    , contrasena VARCHAR(255)
    , curp VARCHAR(18)
    , rfc VARCHAR(13)
    , fecha_hora_registro DATETIME
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
    , sucursal_id INT
    , CONSTRAINT empleado_sucursal FOREIGN KEY (sucursal_id)
        REFERENCES Sucursal(sucursal_id) ON DELETE CASCADE
    , rol_id INT
    , CONSTRAINT empleado_rol FOREIGN KEY (rol_id)
        REFERENCES Rol(rol_id) ON DELETE CASCADE
);

-- tabla cajas
CREATE TABLE Caja (
    caja_id INT AUTO_INCREMENT PRIMARY KEY
    , estado ENUM('ACTIVA', 'INACTIVA', 'ELIMINADA') DEFAULT 'ACTIVA'
);

-- tabla intermedia empleado y caja
CREATE TABLE EmpleadoCaja (
    empleado_caja_id INT AUTO_INCREMENT PRIMARY KEY
    , fecha_hora_inicio DATETIME
    , fecha_hora_fin DATETIME
    , empleado_id INT
    , CONSTRAINT empleado_empleado_caja FOREIGN KEY (empleado_id)
        REFERENCES Empleado(empleado_id) ON DELETE CASCADE
    , caja_id INT
    , CONSTRAINT caja_empleado_caja FOREIGN KEY (caja_id)
        REFERENCES Caja(caja_id) ON DELETE CASCADE
);


-- tabla orden
CREATE TABLE Orden (
    orden_id INT AUTO_INCREMENT PRIMARY KEY
    , folio VARCHAR(5)
    , numero VARCHAR(5)
    , fecha_hora DATETIME
    , referencia_facturacion VARCHAR(13)
    , valida_para_factura TINYINT DEFAULT 1 -- 0 false, 1 true
    , tipo ENUM('LUGAR', 'DOMICILIO')
    , nombre_cliente VARCHAR(255)
    , mesa_id INT
    , CONSTRAINT mesa_orden FOREIGN KEY (mesa_id)
        REFERENCES Mesa(mesa_id) ON DELETE CASCADE
    , alianza_comercial_id INT
    , CONSTRAINT alianza_comercial_orden FOREIGN KEY (alianza_comercial_id)
        REFERENCES AlianzaComercial(alianza_comercial_id) ON DELETE CASCADE
    , caja_id INT
    , CONSTRAINT caja_orden FOREIGN KEY (caja_id)
        REFERENCES Caja(caja_id) ON DELETE CASCADE
    , empleado_id INT
    , CONSTRAINT empleado_orden FOREIGN KEY (empleado_id)
        REFERENCES Empleado(empleado_id) ON DELETE CASCADE

);

-- tabla metodo de pago
CREATE TABLE MetodoPago (
    metodo_pago_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255)
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

-- carga datos de los metodos de pago
INSERT INTO MetodoPago(nombre) VALUES 
    ('Efectivo')
    , ('Tarjeta de débito')
    , ('Tarjeta de crédito')
    , ('Monedero');

-- tabla detalle de pago
CREATE TABLE DetallePago (
    detalle_pago_id INT AUTO_INCREMENT PRIMARY KEY
    , monto DECIMAL(10, 2)
    , fecha_hora DATETIME 
    , orden_id INT
    , CONSTRAINT orden_detalle_pago FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
    , metodo_pago_id INT
    , CONSTRAINT metodo_pago_detalle_pago FOREIGN KEY (metodo_pago_id)
        REFERENCES MetodoPago(metodo_pago_id) ON DELETE CASCADE
);

-- tabla factura
CREATE TABLE Factura (
    factura_id INT AUTO_INCREMENT PRIMARY KEY
    , rfc_cliente VARCHAR(13)
    , nombre_cliente VARCHAR(255)
    , domicilio_fiscal VARCHAR(5)
    , regimen_fiscal VARCHAR(255)
    , uso_cfdi VARCHAR(255)
    , fecha_hora DATETIME
    , orden_id INT UNIQUE
    , CONSTRAINT orden_factura FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
);

-- tabla monedero
CREATE TABLE Monedero (
    monedero_id INT AUTO_INCREMENT PRIMARY KEY
    , numero_tarjeta VARCHAR(16)
    , nombres_titular VARCHAR(255)
    , apellido_paterno_titular VARCHAR(255)
    , apellido_materno_titular VARCHAR(255)
    , fecha_hora_registro DATETIME
);

-- tabla transaccion
CREATE TABLE Transaccion (
    transaccion_id INT AUTO_INCREMENT PRIMARY KEY
    , fecha_hora DATETIME
    , monto DECIMAL(10, 2)
    , descripcion VARCHAR(255)
    , monedero_id INT
    , CONSTRAINT monedero_transaccion FOREIGN KEY (monedero_id)
        REFERENCES Monedero(monedero_id) ON DELETE CASCADE
    , orden_id INT
    , CONSTRAINT orden_transaccion FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
);


-- tabla categoria
CREATE TABLE Categoria (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255)
    , estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

/* carga datos categoria */
LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/categorias.csv'
    INTO TABLE Categoria 
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS -- Ignorar encabezado
    (nombre);

-- tabla producto
CREATE TABLE Producto (
    producto_id INT AUTO_INCREMENT PRIMARY KEY
    , nombre VARCHAR(255)
    , precio DECIMAL(10, 2)
    , categoria_id INT
    , CONSTRAINT categoria_producto FOREIGN KEY (categoria_id)
        REFERENCES Categoria(categoria_id) ON DELETE CASCADE

);

LOAD DATA LOCAL INFILE '/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/picadita_csv/productos.csv'
    INTO TABLE Producto
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS -- Ignorar encabezado
    (nombre, @precio, @categoria_id)
    SET precio = CAST(@precio AS DECIMAL(10, 2))
    AND categoria_id = CAST(@categoria_id AS INT);

CREATE TABLE ContenidoPaquete (
    contenido_paquete_id INT AUTO_INCREMENT PRIMARY KEY
    , producto_id INT
    , CONSTRAINT producto_contenido_paquete FOREIGN KEY (producto_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE
    , paquete_id INT
    , CONSTRAINT paquete_contenido_paquete FOREIGN KEY (paquete_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE
);

-- Tabla DetalleOrden
CREATE TABLE DetalleOrden (
    detalle_orden_id INT AUTO_INCREMENT PRIMARY KEY
    , cantidad_producto INT
    , orden_id INT
    , CONSTRAINT orden_detalle_orden FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
    , producto_id INT
    , CONSTRAINT producto_detalle_orden FOREIGN KEY (producto_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE
);
