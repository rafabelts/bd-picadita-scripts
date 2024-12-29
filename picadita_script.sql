

    -- Tabla roles empleados
CREATE TABLE Rol (
    rol_id INT AUTO_INCREMENT PRIMARY KEY,
    rol VARCHAR(255),
    estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

-- Se agregan los roles de empleado
INSERT INTO Rol (rol) VALUES
    ('Administrador'),
    ('Cajero'),
    ('Mesero'),
    ('Cocinero'),
    ('Garrotero');

-- Tabla empleados
CREATE TABLE Empleado (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    nombre_usuario VARCHAR(10),
    apellido_paterno VARCHAR(255),
    apellido_materno VARCHAR(255),
    contrasena VARCHAR(255),
    curp VARCHAR(18),
    rfc VARCHAR(13),
    fecha_hora_registro DATETIME,
    estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO',
    sucursal_id INT,
    CONSTRAINT empleado_sucursal FOREIGN KEY (sucursal_id)
        REFERENCES Sucursal(sucursal_id) ON DELETE CASCADE,
    rol_id INT,
    CONSTRAINT empleado_rol FOREIGN KEY (rol_id)
        REFERENCES Rol(rol_id) ON DELETE CASCADE
);

-- Tabla cajas
CREATE TABLE Caja (
    caja_id INT AUTO_INCREMENT PRIMARY KEY,
    estado ENUM('ACTIVA', 'INACTIVA', 'ELIMINADA') DEFAULT 'ACTIVA'
);

-- Tabla EmpleadoCaja
CREATE TABLE EmpleadoCaja (
    empleado_caja_id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora_inicio DATETIME,
    fecha_hora_fin DATETIME,
    empleado_id INT,
    CONSTRAINT empleado_empleado_caja FOREIGN KEY (empleado_id)
        REFERENCES Empleado(empleado_id) ON DELETE CASCADE,
    caja_id INT,
    CONSTRAINT caja_empleado_caja FOREIGN KEY (caja_id)
        REFERENCES Caja(caja_id) ON DELETE CASCADE
);

-- Tabla Orden
CREATE TABLE Orden (
    orden_id INT AUTO_INCREMENT PRIMARY KEY,
    folio VARCHAR(5),
    numero VARCHAR(5),
    fecha_hora DATETIME,
    referencia_facturacion VARCHAR(13),
    valida_para_factura TINYINT, -- 0 false, 1 true
    tipo ENUM('LUGAR', 'DOMICILIO'),
    nombre_cliente VARCHAR(255),
    mesa_id INT,
    CONSTRAINT mesa_orden FOREIGN KEY (mesa_id)
        REFERENCES Mesa(mesa_id) ON DELETE CASCADE,
    alianza_comercial_id INT,
    CONSTRAINT alianza_comercial_orden FOREIGN KEY (alianza_comercial_id)
        REFERENCES AlianzaComercial(alianza_comercial_id) ON DELETE CASCADE,
    caja_id INT,
    CONSTRAINT caja_orden FOREIGN KEY (caja_id)
        REFERENCES Caja(caja_id) ON DELETE CASCADE,
    empleado_id INT,
    CONSTRAINT empleado_orden FOREIGN KEY (empleado_id)
        REFERENCES Empleado(empleado_id) ON DELETE CASCADE
);

-- Tabla metodo pago
CREATE TABLE MetodoPago (
    metodo_pago_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

-- Se agregan los metodos de pago
INSERT INTO MetodoPago(nombre) VALUES 
    ('Efectivo'),
    ('Tarjeta de débito'),
    ('Tarjeta de crédito'),
    ('Monedero');

-- Tabla detalle pago
CREATE TABLE DetallePago (
    detalle_pago_id INT AUTO_INCREMENT PRIMARY KEY,
    monto DECIMAL(10, 2), 
    fecha_hora DATETIME, 
    orden_id INT,
    CONSTRAINT orden_detalle_pago FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE,
    metodo_pago_id INT,
    CONSTRAINT metodo_pago_detalle_pago FOREIGN KEY (metodo_pago_id)
        REFERENCES MetodoPago(metodo_pago_id) ON DELETE CASCADE
);

-- Tabla Factura
CREATE TABLE Factura (
    factura_id INT AUTO_INCREMENT PRIMARY KEY,
    rfc_cliente VARCHAR(13),
    nombre_cliente VARCHAR(255),
    domicilio_fiscal VARCHAR(5),
    regimen_fiscal VARCHAR(255),
    uso_cfdi VARCHAR(255),
    fecha_hora DATETIME,
    orden_id INT UNIQUE,
    CONSTRAINT orden_factura FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
);

-- Tabla Monedero
CREATE TABLE Monedero (
    monedero_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_tarjeta VARCHAR(16),
    nombres_titular VARCHAR(255),
    apellido_paterno_titular VARCHAR(255),
    apellido_materno_titular VARCHAR(255),
    fecha_hora_registro DATETIME
);

-- Tabla Transaccion
CREATE TABLE Transaccion (
    transaccion_id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora DATETIME,
    monto DECIMAL(10, 2),
    descripcion VARCHAR(255),
    monedero_id INT,
    CONSTRAINT monedero_transaccion FOREIGN KEY (monedero_id)
        REFERENCES Monedero(monedero_id) ON DELETE CASCADE,
    orden_id INT,
    CONSTRAINT orden_transaccion FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE
);

-- Tabla Categoria
CREATE TABLE Categoria (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    estado ENUM('ACTIVO', 'INACTIVO', 'ELIMINADO') DEFAULT 'ACTIVO'
);

-- Carga de datos categorias
LOAD DATA LOCAL INFILE "/data_csv/categorias.csv"
    INTO TABLE Categoria 
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS -- Ignorar encabezado
    (nombre);

-- Tabla Producto
CREATE TABLE Producto (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    precio DECIMAL(10, 2),
    categoria_id INT,
    CONSTRAINT categoria_producto FOREIGN KEY (categoria_id)
        REFERENCES Categoria(categoria_id) ON DELETE CASCADE
);

-- Carga de datos productos
LOAD DATA LOCAL INFILE "/Users/rafabelts/development/picaditajarocha/picadita-bd-scripts/data_csv/productos.csv"
    INTO TABLE Producto 
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS -- Ignorar encabezado
    (nombre, precio, categoria_id);

-- Tabla ContenidoPaquete
CREATE TABLE ContenidoPaquete (
    contenido_paquete_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT,
    CONSTRAINT producto_contenido_paquete FOREIGN KEY (producto_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE,
    paquete_id INT,
    CONSTRAINT paquete_contenido_paquete FOREIGN KEY (paquete_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE
);

-- Tabla DetalleOrden
CREATE TABLE DetalleOrden (
    detalle_orden_id INT AUTO_INCREMENT PRIMARY KEY,
    cantidad_producto INT,
    orden_id INT,
    CONSTRAINT orden_detalle_orden FOREIGN KEY (orden_id)
        REFERENCES Orden(orden_id) ON DELETE CASCADE,
    producto_id INT,
    CONSTRAINT producto_detalle_orden FOREIGN KEY (producto_id)
        REFERENCES Producto(producto_id) ON DELETE CASCADE
);

