-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 03-06-2025 a las 16:00:53
-- Versión del servidor: 8.0.30
-- Versión de PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dreamdress3d`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

CREATE TABLE `carrito` (
  `CarritoID` int NOT NULL,
  `ClienteID` int DEFAULT NULL,
  `Fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Estado` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito_item`
--

CREATE TABLE `carrito_item` (
  `ItemID` int NOT NULL,
  `CarritoID` int DEFAULT NULL,
  `CatalogoID` int DEFAULT NULL,
  `Cantidad` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogo`
--

CREATE TABLE `catalogo` (
  `CatalogoID` int NOT NULL,
  `ProductoID` int DEFAULT NULL,
  `Stock` int NOT NULL,
  `Disponible` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `catalogo`
--

INSERT INTO `catalogo` (`CatalogoID`, `ProductoID`, `Stock`, `Disponible`) VALUES
(1, 1, 5, 1),
(2, 2, 5, 1),
(3, 3, 4, 1),
(4, 4, 10, 1),
(5, 5, 15, 1),
(6, 6, 9, 1),
(7, 7, 12, 1),
(8, 8, 14, 1),
(9, 9, 15, 1),
(10, 10, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cita`
--

CREATE TABLE `cita` (
  `CitaID` int NOT NULL,
  `ClienteID` int DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `Estado` enum('Pendiente','Confirmada','Cancelada','Completada') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `Fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `ClienteID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`ClienteID`, `UsuarioID`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuota_pago`
--

CREATE TABLE `cuota_pago` (
  `CuotaID` int NOT NULL,
  `PagoID` int DEFAULT NULL,
  `Monto` decimal(10,2) NOT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `MetodoPagoID` int DEFAULT NULL,
  `TipoPagoID` int DEFAULT NULL,
  `Canal_pago` enum('Online','Tienda') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Online',
  `Notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `encargado_inventario`
--

CREATE TABLE `encargado_inventario` (
  `EncargadoID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Area_asignada` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `FacturaID` int NOT NULL,
  `ReciboID` int DEFAULT NULL,
  `NIT_cliente` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Nombre_razon_social` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Monto_total` decimal(10,2) DEFAULT NULL,
  `Estado` enum('Emitida','Anulada') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Emitida'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_accion`
--

CREATE TABLE `log_accion` (
  `LogID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Tabla_afectada` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ID_registro` int DEFAULT NULL,
  `Accion` enum('INSERT','UPDATE','DELETE') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Modulo_afectado` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Detalle` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `IP_acceso` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodo_pago`
--

CREATE TABLE `metodo_pago` (
  `MetodoPagoID` int NOT NULL,
  `Nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metodo_pago`
--

INSERT INTO `metodo_pago` (`MetodoPagoID`, `Nombre`, `Descripcion`) VALUES
(1, 'Efectivo', 'Pago en efectivo en tienda'),
(2, 'QR', 'Pago con un QR personalizado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago`
--

CREATE TABLE `pago` (
  `PagoID` int NOT NULL,
  `CarritoID` int DEFAULT NULL,
  `Monto_total` decimal(10,2) NOT NULL,
  `Monto_pagado` decimal(10,2) NOT NULL,
  `Estado_pago` enum('Pendiente','Parcial','Pagado') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Pendiente',
  `MetodoPagoID` int NOT NULL,
  `TipoPagoID` int NOT NULL,
  `Fecha_pago` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `PedidoID` int NOT NULL,
  `ReciboID` int DEFAULT NULL,
  `Estado` enum('Pendiente','En proceso','Listo','Cancelado') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Pendiente',
  `Fecha_pedido` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_entrega` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `ProductoID` int NOT NULL,
  `Nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `Precio` decimal(10,2) NOT NULL,
  `TipoID` int NOT NULL,
  `Imagen` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`ProductoID`, `Nombre`, `Descripcion`, `Precio`, `TipoID`, `Imagen`) VALUES
(1, 'VESTIDO DE NOVIA', 'Vestido de Novia, corte sirena, escote corazon, color Blanco, decorado brilloso, sin mangas, sin cola, talla \"M\".', 4300.00, 1, 'VDN01'),
(2, 'VESTIDO DE NOVIA', 'Vestido de Novia corte A, color Perla claro, decorado sencillo, con mangas, con cola, talla \"L\".', 3000.00, 1, 'VDN02'),
(3, 'VESTIDO DE NOVIA', 'Vestido de Novia, corte sirena, escote corazon, color Blanco, decorado brilloso, sin mangas, sin cola, talla \"L\".', 4500.00, 1, 'VDN03'),
(4, 'VESTIDO DE NOVIA', 'Vestido de Novia color Blanco, escote corazon, con mangas, sin cola, corte de falda princesa, talla \"XL\".', 5000.00, 1, 'VDN04'),
(5, 'VESTIDO DE FIESTA', 'Vestido de fiesta color Beige, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"XL\".', 2500.00, 2, 'VDF01'),
(6, 'VESTIDO DE FIESTA', 'Vestido de fiesta color Palo de Rosa, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"M\".', 1850.00, 2, 'VDF02'),
(7, 'VESTIDO DE FIESTA', 'Vestido de fiesta color palo de rosa, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"L\".', 2000.00, 2, 'VDF03'),
(8, 'BOUQUET', 'Bouquet de color perla claro y guindo hecho de porcelana ligera de tamaño mediano.', 200.00, 3, 'BP01'),
(9, 'CORONA', 'Corona color chapagne, hecho con piedras brillosas baroskie, tamaño pequeño.', 120.00, 4, 'CR01'),
(10, 'VELO', 'Velo color blanco, estilo catedral, con finas capas de tul brilloso, tamaño grande.', 650.00, 5, 'VL01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_extra`
--

CREATE TABLE `producto_extra` (
  `GeneralID` int NOT NULL,
  `Codigo` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ProductoID` int DEFAULT NULL,
  `Color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Material` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Tamano` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_extra`
--

INSERT INTO `producto_extra` (`GeneralID`, `Codigo`, `ProductoID`, `Color`, `Material`, `Tamano`) VALUES
(1, 'BP01', 8, 'Perla Claro y Guindo', 'Porcelana', 'Mediano'),
(2, 'CR01', 9, 'Champagne', 'Piedras Brillosas', 'Pequeño'),
(3, 'VL01', 10, 'Blanco', 'Tul Brilloso', 'Grande');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `propietario`
--

CREATE TABLE `propietario` (
  `PropietarioID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Nivel_administracion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibo`
--

CREATE TABLE `recibo` (
  `ReciboID` int NOT NULL,
  `PagoID` int DEFAULT NULL,
  `Numero_factura` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ClienteID` int DEFAULT NULL,
  `Detalles` text CHARACTER SET ascii COLLATE ascii_general_ci,
  `Estado` enum('Emitido','Anulado') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Emitido'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recuperacion`
--

CREATE TABLE `recuperacion` (
  `RecuperID` int NOT NULL,
  `correo` varchar(150) NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `creado_fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `usado` tinyint DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro`
--

CREATE TABLE `registro` (
  `RegistroID` int NOT NULL,
  `Nombres` varchar(200) NOT NULL,
  `Ap_paterno` varchar(200) NOT NULL,
  `Ap_materno` varchar(200) NOT NULL,
  `CI` int NOT NULL,
  `Fecha_nacimiento` date DEFAULT NULL,
  `Telefono` int NOT NULL,
  `Ciudad` enum('LA PAZ','EL ALTO','SANTA CRUZ','COCHABAMBA','TARIJA','PANDO','CHUQUISACA','BENI','ORURO','POTOSI') DEFAULT (_cp850'LA PAZ'),
  `Zona` varchar(100) NOT NULL,
  `Calle` varchar(100) DEFAULT NULL,
  `Nro_puerta` varchar(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `registro`
--

INSERT INTO `registro` (`RegistroID`, `Nombres`, `Ap_paterno`, `Ap_materno`, `CI`, `Fecha_nacimiento`, `Telefono`, `Ciudad`, `Zona`, `Calle`, `Nro_puerta`) VALUES
(1, 'Marcelo Josue', 'Escobar', 'Chipana', 13760247, '2005-08-08', 72053249, 'LA PAZ', 'Rosario', 'Isaac Tamayo', '749');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `RolID` int NOT NULL,
  `Rol_Nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` varchar(350) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `Nivel_acceso` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`RolID`, `Rol_Nombre`, `Descripcion`, `Nivel_acceso`) VALUES
(1, 'Super Admin', '', ''),
(2, 'Propietario', '', ''),
(3, 'Encargado del Inventario', '', ''),
(4, 'Vendedor', '', ''),
(5, 'Cliente', '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesion_usuario`
--

CREATE TABLE `sesion_usuario` (
  `SesionID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `IP_acceso` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Activa` tinyint(1) DEFAULT '1',
  `Fecha_inicio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_fin` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `superadmin`
--

CREATE TABLE `superadmin` (
  `SuperAdminID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Nivel_acceso` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_pago`
--

CREATE TABLE `tipo_pago` (
  `TipoPagoID` int NOT NULL,
  `Nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_pago`
--

INSERT INTO `tipo_pago` (`TipoPagoID`, `Nombre`, `Descripcion`) VALUES
(1, 'Contado', 'Pago completo al momento'),
(2, 'Crédito ', 'Pago a cuotas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_producto`
--

CREATE TABLE `tipo_producto` (
  `TipoID` int NOT NULL,
  `Nombre_tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_producto`
--

INSERT INTO `tipo_producto` (`TipoID`, `Nombre_tipo`, `Descripcion`) VALUES
(1, 'Vestido de Novia', 'Vestidos para ceremonias de boda'),
(2, 'Vestido de Fiesta', 'Vestidos elegantes para eventos sociales'),
(3, 'Bouquet', 'Accesorio para el vestido de novia'),
(4, 'Corona', 'Accesorio para el vestido de novia'),
(5, 'Velo', 'Accesorio para el vestido de novia');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `UsuarioID` int NOT NULL,
  `NombreUsuario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `correo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Contrasena` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Habilitado` tinyint(1) DEFAULT '1',
  `RolID` int DEFAULT '5',
  `RegistroID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`UsuarioID`, `NombreUsuario`, `correo`, `Contrasena`, `Habilitado`, `RolID`, `RegistroID`) VALUES
(1, 'Zeu5.', 'lpze.marcelojosue.escobar.ch@unifranz.edu.bo', '$2y$10$hFUIHATcl1CHEd.hhBLFiejZALpPzXeEgdbEO2e1BPJfliJ.QZzci', 1, 5, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `VendedorID` int NOT NULL,
  `UsuarioID` int DEFAULT NULL,
  `Zona_venta` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vestido`
--

CREATE TABLE `vestido` (
  `VestidoID` int NOT NULL,
  `Codigo` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ProductoID` int DEFAULT NULL,
  `Talla` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Tipo_escote` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Corte_falda` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Manga` tinyint(1) DEFAULT NULL,
  `Cola` tinyint(1) DEFAULT NULL,
  `Color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vestido`
--

INSERT INTO `vestido` (`VestidoID`, `Codigo`, `ProductoID`, `Talla`, `Tipo_escote`, `Corte_falda`, `Manga`, `Cola`, `Color`) VALUES
(1, 'VDN01', 1, 'M', 'Corazon', 'Sirena', 0, 0, 'Blanco'),
(2, 'VDN02', 2, 'L', 'Corazon', 'A', 1, 1, 'Perla claro'),
(3, 'VDN03', 3, 'L', 'Corazon', 'Sirena', 0, 0, 'Blanco'),
(4, 'VDN04', 4, 'XL', 'Corazon', 'Princesa', 1, 0, 'Blanco'),
(5, 'VDF01', 5, 'XL', 'Corazon', 'Princesa', 0, 0, 'Beige'),
(6, 'VDF02', 6, 'M', 'Corazon', 'Princesa', 0, 0, 'Palo de rosa'),
(7, 'VDF03', 7, 'L', 'Corazon', 'Princesa', 0, 0, 'Palo de rosa');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD PRIMARY KEY (`CarritoID`),
  ADD KEY `fk_carrito_cliente` (`ClienteID`);

--
-- Indices de la tabla `carrito_item`
--
ALTER TABLE `carrito_item`
  ADD PRIMARY KEY (`ItemID`),
  ADD KEY `fk_carrito_item_carrito` (`CarritoID`),
  ADD KEY `fk_carrito_item_catalogo` (`CatalogoID`);

--
-- Indices de la tabla `catalogo`
--
ALTER TABLE `catalogo`
  ADD PRIMARY KEY (`CatalogoID`),
  ADD UNIQUE KEY `ProductoID` (`ProductoID`);

--
-- Indices de la tabla `cita`
--
ALTER TABLE `cita`
  ADD PRIMARY KEY (`CitaID`),
  ADD KEY `fk_cita_cliente` (`ClienteID`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`ClienteID`),
  ADD UNIQUE KEY `ClienteID` (`ClienteID`),
  ADD UNIQUE KEY `UsuarioID` (`UsuarioID`);

--
-- Indices de la tabla `cuota_pago`
--
ALTER TABLE `cuota_pago`
  ADD PRIMARY KEY (`CuotaID`),
  ADD KEY `fk_cuota_pago_pago` (`PagoID`),
  ADD KEY `fk_cuota_pago_metodo` (`MetodoPagoID`),
  ADD KEY `fk_cuota_pago_tipo` (`TipoPagoID`);

--
-- Indices de la tabla `encargado_inventario`
--
ALTER TABLE `encargado_inventario`
  ADD PRIMARY KEY (`EncargadoID`),
  ADD UNIQUE KEY `UsuarioID` (`UsuarioID`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`FacturaID`),
  ADD UNIQUE KEY `ReciboID` (`ReciboID`);

--
-- Indices de la tabla `log_accion`
--
ALTER TABLE `log_accion`
  ADD PRIMARY KEY (`LogID`),
  ADD KEY `fk_log_usuario` (`UsuarioID`);

--
-- Indices de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  ADD PRIMARY KEY (`MetodoPagoID`),
  ADD UNIQUE KEY `Nombre` (`Nombre`);

--
-- Indices de la tabla `pago`
--
ALTER TABLE `pago`
  ADD PRIMARY KEY (`PagoID`),
  ADD KEY `fk_pago_carrito` (`CarritoID`),
  ADD KEY `fk_pago_metodo` (`MetodoPagoID`),
  ADD KEY `fk_pago_tipo` (`TipoPagoID`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`PedidoID`),
  ADD KEY `fk_pedido_recibo` (`ReciboID`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`ProductoID`),
  ADD KEY `fk_producto_tipo` (`TipoID`);

--
-- Indices de la tabla `producto_extra`
--
ALTER TABLE `producto_extra`
  ADD PRIMARY KEY (`GeneralID`),
  ADD UNIQUE KEY `Codigo` (`Codigo`),
  ADD UNIQUE KEY `ProductoID` (`ProductoID`);

--
-- Indices de la tabla `propietario`
--
ALTER TABLE `propietario`
  ADD PRIMARY KEY (`PropietarioID`),
  ADD UNIQUE KEY `UsuarioID` (`UsuarioID`);

--
-- Indices de la tabla `recibo`
--
ALTER TABLE `recibo`
  ADD PRIMARY KEY (`ReciboID`),
  ADD UNIQUE KEY `PagoID` (`PagoID`),
  ADD UNIQUE KEY `Numero_factura` (`Numero_factura`),
  ADD KEY `fk_recibo_cliente` (`ClienteID`);

--
-- Indices de la tabla `recuperacion`
--
ALTER TABLE `recuperacion`
  ADD PRIMARY KEY (`RecuperID`);

--
-- Indices de la tabla `registro`
--
ALTER TABLE `registro`
  ADD PRIMARY KEY (`RegistroID`),
  ADD UNIQUE KEY `CI` (`CI`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`RolID`),
  ADD UNIQUE KEY `Rol_Nombre` (`Rol_Nombre`);

--
-- Indices de la tabla `sesion_usuario`
--
ALTER TABLE `sesion_usuario`
  ADD PRIMARY KEY (`SesionID`),
  ADD KEY `fk_sesion_usuario` (`UsuarioID`);

--
-- Indices de la tabla `superadmin`
--
ALTER TABLE `superadmin`
  ADD PRIMARY KEY (`SuperAdminID`),
  ADD UNIQUE KEY `UsuarioID` (`UsuarioID`);

--
-- Indices de la tabla `tipo_pago`
--
ALTER TABLE `tipo_pago`
  ADD PRIMARY KEY (`TipoPagoID`),
  ADD UNIQUE KEY `Nombre` (`Nombre`);

--
-- Indices de la tabla `tipo_producto`
--
ALTER TABLE `tipo_producto`
  ADD PRIMARY KEY (`TipoID`),
  ADD UNIQUE KEY `Nombre_tipo` (`Nombre_tipo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`UsuarioID`),
  ADD UNIQUE KEY `NombreUsuario` (`NombreUsuario`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `fk_usuario_rol` (`RolID`),
  ADD KEY `fk_usuario_registro` (`RegistroID`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`VendedorID`),
  ADD UNIQUE KEY `UsuarioID` (`UsuarioID`);

--
-- Indices de la tabla `vestido`
--
ALTER TABLE `vestido`
  ADD PRIMARY KEY (`VestidoID`),
  ADD UNIQUE KEY `Codigo` (`Codigo`),
  ADD UNIQUE KEY `ProductoID` (`ProductoID`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `CarritoID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `carrito_item`
--
ALTER TABLE `carrito_item`
  MODIFY `ItemID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `catalogo`
--
ALTER TABLE `catalogo`
  MODIFY `CatalogoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `cita`
--
ALTER TABLE `cita`
  MODIFY `CitaID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `ClienteID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `cuota_pago`
--
ALTER TABLE `cuota_pago`
  MODIFY `CuotaID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `FacturaID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `log_accion`
--
ALTER TABLE `log_accion`
  MODIFY `LogID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  MODIFY `MetodoPagoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `pago`
--
ALTER TABLE `pago`
  MODIFY `PagoID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `PedidoID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `ProductoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `recibo`
--
ALTER TABLE `recibo`
  MODIFY `ReciboID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `recuperacion`
--
ALTER TABLE `recuperacion`
  MODIFY `RecuperID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `registro`
--
ALTER TABLE `registro`
  MODIFY `RegistroID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `RolID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `sesion_usuario`
--
ALTER TABLE `sesion_usuario`
  MODIFY `SesionID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipo_pago`
--
ALTER TABLE `tipo_pago`
  MODIFY `TipoPagoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_producto`
--
ALTER TABLE `tipo_producto`
  MODIFY `TipoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `UsuarioID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD CONSTRAINT `fk_carrito_to_cliente` FOREIGN KEY (`ClienteID`) REFERENCES `cliente` (`ClienteID`);

--
-- Filtros para la tabla `carrito_item`
--
ALTER TABLE `carrito_item`
  ADD CONSTRAINT `fk_carrito_item_carrito` FOREIGN KEY (`CarritoID`) REFERENCES `carrito` (`CarritoID`),
  ADD CONSTRAINT `fk_carrito_item_catalogo` FOREIGN KEY (`CatalogoID`) REFERENCES `catalogo` (`CatalogoID`);

--
-- Filtros para la tabla `catalogo`
--
ALTER TABLE `catalogo`
  ADD CONSTRAINT `fk_catalogo_producto` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`);

--
-- Filtros para la tabla `cita`
--
ALTER TABLE `cita`
  ADD CONSTRAINT `fk_cita_to_cliente` FOREIGN KEY (`ClienteID`) REFERENCES `cliente` (`ClienteID`);

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `cuota_pago`
--
ALTER TABLE `cuota_pago`
  ADD CONSTRAINT `fk_cuota_pago_metodo` FOREIGN KEY (`MetodoPagoID`) REFERENCES `metodo_pago` (`MetodoPagoID`),
  ADD CONSTRAINT `fk_cuota_pago_pago` FOREIGN KEY (`PagoID`) REFERENCES `pago` (`PagoID`),
  ADD CONSTRAINT `fk_cuota_pago_tipo` FOREIGN KEY (`TipoPagoID`) REFERENCES `tipo_pago` (`TipoPagoID`);

--
-- Filtros para la tabla `encargado_inventario`
--
ALTER TABLE `encargado_inventario`
  ADD CONSTRAINT `fk_encargado_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `fk_factura_recibo` FOREIGN KEY (`ReciboID`) REFERENCES `recibo` (`ReciboID`);

--
-- Filtros para la tabla `log_accion`
--
ALTER TABLE `log_accion`
  ADD CONSTRAINT `fk_log_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `pago`
--
ALTER TABLE `pago`
  ADD CONSTRAINT `fk_pago_carrito` FOREIGN KEY (`CarritoID`) REFERENCES `carrito` (`CarritoID`),
  ADD CONSTRAINT `fk_pago_metodo` FOREIGN KEY (`MetodoPagoID`) REFERENCES `metodo_pago` (`MetodoPagoID`),
  ADD CONSTRAINT `fk_pago_tipo` FOREIGN KEY (`TipoPagoID`) REFERENCES `tipo_pago` (`TipoPagoID`);

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `fk_pedido_recibo` FOREIGN KEY (`ReciboID`) REFERENCES `recibo` (`ReciboID`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_producto_tipo` FOREIGN KEY (`TipoID`) REFERENCES `tipo_producto` (`TipoID`);

--
-- Filtros para la tabla `producto_extra`
--
ALTER TABLE `producto_extra`
  ADD CONSTRAINT `fk_producto_extra_producto` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Filtros para la tabla `propietario`
--
ALTER TABLE `propietario`
  ADD CONSTRAINT `fk_owner_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `recibo`
--
ALTER TABLE `recibo`
  ADD CONSTRAINT `fk_recibo_pago` FOREIGN KEY (`PagoID`) REFERENCES `pago` (`PagoID`),
  ADD CONSTRAINT `fk_recibo_to_cliente` FOREIGN KEY (`ClienteID`) REFERENCES `cliente` (`ClienteID`);

--
-- Filtros para la tabla `sesion_usuario`
--
ALTER TABLE `sesion_usuario`
  ADD CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `superadmin`
--
ALTER TABLE `superadmin`
  ADD CONSTRAINT `fk_superadmin_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_registro` FOREIGN KEY (`RegistroID`) REFERENCES `registro` (`RegistroID`),
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`RolID`) REFERENCES `rol` (`RolID`);

--
-- Filtros para la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD CONSTRAINT `fk_vendedor_usuario` FOREIGN KEY (`UsuarioID`) REFERENCES `usuario` (`UsuarioID`);

--
-- Filtros para la tabla `vestido`
--
ALTER TABLE `vestido`
  ADD CONSTRAINT `fk_vestido_producto` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
