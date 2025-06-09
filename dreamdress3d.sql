-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 09-06-2025 a las 01:12:55
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

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_cantidad_item_carrito` (IN `p_item_id` INT, IN `p_nueva_cantidad` INT, IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    DECLARE v_catalogo_id INT;
    DECLARE v_stock_actual INT;
    DECLARE v_cantidad_actual INT;

    -- Validar existencia del item en carrito
    IF NOT EXISTS (SELECT 1 FROM carrito_item WHERE ItemID = p_item_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ítem no existe en el carrito';
    END IF;

    -- Obtener catalogoID y cantidad actual
    SELECT CatalogoID, Cantidad INTO v_catalogo_id, v_cantidad_actual FROM carrito_item WHERE ItemID = p_item_id;

    -- Obtener stock actual
    SELECT Stock INTO v_stock_actual FROM catalogo WHERE CatalogoID = v_catalogo_id;

    -- Calcular diferencia para stock
    IF p_nueva_cantidad > v_cantidad_actual THEN
        IF v_stock_actual < (p_nueva_cantidad - v_cantidad_actual) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay stock suficiente para aumentar la cantidad';
        END IF;
        -- Descontar diferencia de stock
        UPDATE catalogo SET Stock = Stock - (p_nueva_cantidad - v_cantidad_actual) WHERE CatalogoID = v_catalogo_id;
    ELSEIF p_nueva_cantidad < v_cantidad_actual THEN
        -- Devolver stock sobrante
        UPDATE catalogo SET Stock = Stock + (v_cantidad_actual - p_nueva_cantidad) WHERE CatalogoID = v_catalogo_id;
    END IF;

    -- Actualizar cantidad en carrito
    UPDATE carrito_item SET Cantidad = p_nueva_cantidad WHERE ItemID = p_item_id;

    -- Log de la actualización
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        NULL,
        'carrito_item',
        p_item_id,
        'UPDATE',
        'actualizar_cantidad_item_carrito',
        p_detalle,
        p_ip_acceso
    );

    SELECT 'ok' AS status, 'Cantidad actualizada correctamente' AS mensaje, p_item_id AS ItemID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_item_carrito_logico` (IN `p_item_id` INT, IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    DECLARE v_catalogo_id INT;
    DECLARE v_cantidad INT;

    -- Validar existencia del ítem
    IF NOT EXISTS (SELECT 1 FROM carrito_item WHERE ItemID = p_item_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ítem no existe en el carrito';
    END IF;

    -- Obtener CatalogoID y Cantidad actual del ítem
    SELECT CatalogoID, Cantidad INTO v_catalogo_id, v_cantidad FROM carrito_item WHERE ItemID = p_item_id;

    -- Actualizar stock en catálogo (devolver stock)
    UPDATE catalogo SET Stock = Stock + v_cantidad WHERE CatalogoID = v_catalogo_id;

    -- Baja lógica: eliminar ítem del carrito (puede ser DELETE o actualizar estado si tienes campo)
    DELETE FROM carrito_item WHERE ItemID = p_item_id;

    -- Log
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        NULL,
        'carrito_item',
        p_item_id,
        'DELETE',
        'eliminar_item_carrito_logico',
        p_detalle,
        p_ip_acceso
    );

    SELECT 'ok' AS status, 'Ítem eliminado correctamente del carrito' AS mensaje, p_item_id AS ItemID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_carritos_por_cliente` (IN `p_cliente_id` INT)   BEGIN
    SELECT 
        CarritoID,
        ClienteID,
        Fecha_creacion,
        Estado
    FROM carrito
    WHERE ClienteID = p_cliente_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_items_por_carrito` (IN `p_carrito_id` INT)   BEGIN
    SELECT 
        carrito_item.ItemID AS ItemID,
        carrito_item.CarritoID AS CarritoID,
        carrito_item.CatalogoID AS CatalogoID,
        producto.ProductoID AS ProductoID,
        producto.Nombre AS NombreProducto,
        producto.Descripcion AS DescripcionProducto,
        producto.Precio AS PrecioProducto,
        tipo_producto.Nombre_tipo AS NombreTipoProducto,
        catalogo.Stock AS StockDisponible,
        carrito_item.Cantidad AS CantidadItem
    FROM carrito_item
    INNER JOIN catalogo ON carrito_item.CatalogoID = catalogo.CatalogoID
    INNER JOIN producto ON catalogo.ProductoID = producto.ProductoID
    INNER JOIN tipo_producto ON producto.TipoID = tipo_producto.TipoID
    WHERE carrito_item.CarritoID = p_carrito_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_producto` (IN `p_ProductoID` INT, IN `p_Nombre` VARCHAR(100), IN `p_Descripcion` TEXT, IN `p_Precio` DECIMAL(10,2), IN `p_TipoID` INT, IN `p_Imagen` TEXT, IN `p_UsuarioID` INT, IN `p_Modulo_afectado` VARCHAR(50), IN `p_IP_acceso` VARCHAR(100), IN `p_Detalle` TEXT)   BEGIN
    -- Actualizar el producto
    UPDATE producto
    SET Nombre = p_Nombre,
        Descripcion = p_Descripcion,
        Precio = p_Precio,
        TipoID = p_TipoID,
        Imagen = p_Imagen
    WHERE ProductoID = p_ProductoID;

    -- Registrar la acción en log_accion
    INSERT INTO log_accion (
        UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso
    )
    VALUES (
        p_UsuarioID, 'producto', p_ProductoID, 'UPDATE', p_Modulo_afectado, p_Detalle, p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_catalogo` (IN `p_CatalogoID` INT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Baja lógica
    UPDATE catalogo
    SET Disponible = 0
    WHERE CatalogoID = p_CatalogoID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'catalogo',
        p_CatalogoID,
        'UPDATE',
        'baja_logica_catalogo',
        CONCAT('Se realizó baja lógica en el catálogo con ID ', p_CatalogoID),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_cliente` (IN `p_ClienteID` INT, IN `p_UsuarioAdminID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_UsuarioID INT;

    -- 1. Obtener el UsuarioID asociado al ClienteID
    SELECT UsuarioID 
    INTO v_UsuarioID 
    FROM cliente 
    WHERE ClienteID = p_ClienteID;

    -- 2. Marcar el usuario como deshabilitado (Habilitado = 0)
    UPDATE usuario
    SET Habilitado = 0
    WHERE UsuarioID = v_UsuarioID;

    -- 3. Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioAdminID,
        'usuario',
        v_UsuarioID,
        'UPDATE',
        'baja_logica_cliente',
        CONCAT('Se dio de baja lógica al usuario con UsuarioID ', v_UsuarioID, ' asociado al ClienteID ', p_ClienteID),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_producto` (IN `p_ProductoID` INT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Baja lógica
    UPDATE producto
    SET Activo = 0
    WHERE ProductoID = p_ProductoID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    )
    VALUES (
        p_UsuarioID,
        'producto',
        p_ProductoID,
        'UPDATE',
        'baja_logica_producto',
        CONCAT('Se realizó baja lógica del producto con ProductoID ', p_ProductoID),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_producto_extra` (IN `p_GeneralID` INT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Baja lógica
    UPDATE producto_extra
    SET Habilitado = 0
    WHERE GeneralID = p_GeneralID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'producto_extra',
        p_GeneralID,
        'UPDATE',
        'baja_logica_producto_extra',
        CONCAT('Se realizó baja lógica de producto_extra con GeneralID ', p_GeneralID),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_rol` (IN `p_RolID` INT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Baja lógica
    UPDATE rol
    SET Habilitado = 0
    WHERE RolID = p_RolID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'rol',
        p_RolID,
        'UPDATE',
        'baja_logica_rol',
        CONCAT('Se realizó baja lógica del rol con RolID ', p_RolID),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_logica_vestido` (IN `p_VestidoID` INT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    UPDATE vestido
    SET Habilitado = 0
    WHERE VestidoID = p_VestidoID;

    INSERT INTO log_accion (
        UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, Fecha, IP_acceso
    ) VALUES (
        p_UsuarioID, 'vestido', p_VestidoID, 'UPDATE', 'baja_logica_vestido', 'Vestido dado de baja lógica', NOW(), p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baja_usuario` (IN `p_usuario_id` INT, IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Validar que el usuario exista y esté habilitado
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE UsuarioID = p_usuario_id AND Habilitado = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o ya está dado de baja';
    END IF;

    -- Baja lógica
    UPDATE usuario SET Habilitado = 0 WHERE UsuarioID = p_usuario_id;

    -- Log
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (p_usuario_id, 'usuario', p_usuario_id, 'UPDATE', 'baja_logica', p_detalle, p_ip_acceso);

    -- Mensaje de éxito
    SELECT 'ok' AS status, 'Usuario dado de baja lógicamente' AS mensaje, p_usuario_id AS UsuarioID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_catalogo` (IN `p_CatalogoID` INT, IN `p_Stock` INT, IN `p_Disponible` TINYINT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Actualización de los datos del catálogo
    UPDATE catalogo
    SET Stock = p_Stock,
        Disponible = p_Disponible
    WHERE CatalogoID = p_CatalogoID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'catalogo',
        p_CatalogoID,
        'UPDATE',
        'editar_catalogo',
        CONCAT('Se editó el catálogo con ID ', p_CatalogoID, ' (Stock: ', p_Stock, ', Disponible: ', p_Disponible, ')'),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_cliente` (IN `p_ClienteID` INT, IN `p_NombreUsuario` VARCHAR(50), IN `p_Correo` VARCHAR(100), IN `p_Nombres` VARCHAR(200), IN `p_Ap_paterno` VARCHAR(200), IN `p_Ap_materno` VARCHAR(200), IN `p_Telefono` INT, IN `p_Ciudad` ENUM('LA PAZ','EL ALTO','SANTA CRUZ','COCHABAMBA','TARIJA','PANDO','CHUQUISACA','BENI','ORURO','POTOSI'), IN `p_Zona` VARCHAR(100), IN `p_Calle` VARCHAR(100), IN `p_Nro_puerta` VARCHAR(6), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_UsuarioID INT;
    DECLARE v_RegistroID INT;

    -- 1. Obtener UsuarioID
    SELECT UsuarioID INTO v_UsuarioID FROM cliente WHERE ClienteID = p_ClienteID;

    -- 2. Obtener RegistroID
    SELECT RegistroID INTO v_RegistroID FROM usuario WHERE UsuarioID = v_UsuarioID;

    -- 3. Actualizar usuario
    UPDATE usuario 
    SET NombreUsuario = p_NombreUsuario, 
        correo = p_Correo
    WHERE UsuarioID = v_UsuarioID;

    -- 4. Actualizar registro
    UPDATE registro
    SET Nombres = p_Nombres,
        Ap_paterno = p_Ap_paterno,
        Ap_materno = p_Ap_materno,
        Telefono = p_Telefono,
        Ciudad = p_Ciudad,
        Zona = p_Zona,
        Calle = p_Calle,
        Nro_puerta = p_Nro_puerta
    WHERE RegistroID = v_RegistroID;

    -- 5. Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'cliente',
        p_ClienteID,
        'UPDATE',
        'editar_cliente',
        CONCAT('Se editó cliente (ClienteID: ', p_ClienteID, 
            ', UsuarioID: ', v_UsuarioID, 
            ', RegistroID: ', v_RegistroID, 
            ', NombreUsuario: ', p_NombreUsuario, 
            ', Correo: ', p_Correo, 
            ', Nombres: ', p_Nombres, 
            ', Apellidos: ', p_Ap_paterno, ' ', p_Ap_materno, 
            ', Teléfono: ', p_Telefono, 
            ', Ciudad: ', p_Ciudad, 
            ', Zona: ', p_Zona, 
            ', Calle: ', p_Calle, 
            ', Nro_puerta: ', p_Nro_puerta, 
        ')'),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_producto_extra` (IN `p_GeneralID` INT, IN `p_Codigo` VARCHAR(300), IN `p_Color` VARCHAR(50), IN `p_Material` VARCHAR(100), IN `p_Tamano` VARCHAR(50), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Actualización de producto_extra
    UPDATE producto_extra
    SET 
        Codigo   = p_Codigo,
        Color    = p_Color,
        Material = p_Material,
        Tamano   = p_Tamano
    WHERE GeneralID = p_GeneralID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'producto_extra',
        p_GeneralID,
        'UPDATE',
        'editar_producto_extra',
        CONCAT('Se editó producto_extra con GeneralID ', p_GeneralID, 
               '. Nuevos valores - Codigo: ', p_Codigo, 
               ', Color: ', p_Color, 
               ', Material: ', p_Material, 
               ', Tamano: ', p_Tamano),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_registro` (IN `p_registro_id` INT, IN `p_nombres` VARCHAR(200), IN `p_ap_paterno` VARCHAR(200), IN `p_ap_materno` VARCHAR(200), IN `p_ci` INT, IN `p_fecha_nacimiento` DATE, IN `p_telefono` INT, IN `p_ciudad` ENUM('LA PAZ','EL ALTO','SANTA CRUZ','COCHABAMBA','TARIJA','PANDO','CHUQUISACA','BENI','ORURO','POTOSI'), IN `p_zona` VARCHAR(100), IN `p_calle` VARCHAR(100), IN `p_nro_puerta` VARCHAR(6), IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Validar que el registro exista
    IF NOT EXISTS (SELECT 1 FROM registro WHERE RegistroID = p_registro_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro no existe';
    END IF;

    -- Validar que el CI no esté duplicado en otro registro
    IF EXISTS (SELECT 1 FROM registro WHERE CI = p_ci AND RegistroID <> p_registro_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El CI ya está en uso por otro registro';
    END IF;

    -- Actualizar datos en tabla registro
    UPDATE registro
    SET Nombres = p_nombres,
        Ap_paterno = p_ap_paterno,
        Ap_materno = p_ap_materno,
        CI = p_ci,
        Fecha_nacimiento = p_fecha_nacimiento,
        Telefono = p_telefono,
        Ciudad = p_ciudad,
        Zona = p_zona,
        Calle = p_calle,
        Nro_puerta = p_nro_puerta
    WHERE RegistroID = p_registro_id;

    -- Registrar log de la acción
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        NULL,               -- UsuarioID: NULL, porque es solo registro personal. Puedes enlazarlo si lo tienes.
        'registro',
        p_registro_id,
        'UPDATE',
        'edicion',
        p_detalle,
        p_ip_acceso
    );

    -- Mensaje de éxito
    SELECT 'ok' AS status, 'Datos personales editados exitosamente' AS mensaje, p_registro_id AS RegistroID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_rol` (IN `p_RolID` INT, IN `p_Rol_Nombre` VARCHAR(50), IN `p_Descripcion` VARCHAR(350), IN `p_Nivel_acceso` VARCHAR(10), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Actualización del rol
    UPDATE rol
    SET 
        Rol_Nombre   = p_Rol_Nombre,
        Descripcion  = p_Descripcion,
        Nivel_acceso = p_Nivel_acceso
    WHERE RolID = p_RolID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'rol',
        p_RolID,
        'UPDATE',
        'editar_rol',
        CONCAT('Se editó el rol con RolID ', p_RolID, 
            '. Nuevos valores - Rol_Nombre: ', p_Rol_Nombre, 
            ', Descripcion: ', p_Descripcion, 
            ', Nivel_acceso: ', p_Nivel_acceso),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_usuario` (IN `p_usuario_id` INT, IN `p_nombre_usuario` VARCHAR(50), IN `p_correo` VARCHAR(100), IN `p_contrasena` VARCHAR(255), IN `p_habilitado` TINYINT, IN `p_rol_id` INT, IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Validar que el usuario exista
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE UsuarioID = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    -- Validar que el nuevo nombre de usuario y correo no estén duplicados (excluyendo el mismo usuario)
    IF EXISTS (SELECT 1 FROM usuario WHERE NombreUsuario = p_nombre_usuario AND UsuarioID <> p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario ya está en uso por otro usuario';
    END IF;

    IF EXISTS (SELECT 1 FROM usuario WHERE correo = p_correo AND UsuarioID <> p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo ya está en uso por otro usuario';
    END IF;

    -- Actualizar datos en tabla usuario
    UPDATE usuario
    SET NombreUsuario = p_nombre_usuario,
        correo = p_correo,
        Contrasena = p_contrasena,
        Habilitado = p_habilitado,
        RolID = p_rol_id
    WHERE UsuarioID = p_usuario_id;

    -- Registrar log de la acción
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        p_usuario_id,
        'usuario',
        p_usuario_id,
        'UPDATE',
        'edicion',
        p_detalle,
        p_ip_acceso
    );

    -- Mensaje de éxito
    SELECT 'ok' AS status, 'Usuario editado exitosamente' AS mensaje, p_usuario_id AS UsuarioID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_vestido` (IN `p_VestidoID` INT, IN `p_Codigo` VARCHAR(300), IN `p_Talla` VARCHAR(10), IN `p_Tipo_escote` VARCHAR(50), IN `p_Corte_falda` VARCHAR(50), IN `p_Manga` TINYINT, IN `p_Cola` TINYINT, IN `p_Color` VARCHAR(50), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    -- Actualización de vestido
    UPDATE vestido
    SET
        Codigo = p_Codigo,
        Talla = p_Talla,
        Tipo_escote = p_Tipo_escote,
        Corte_falda = p_Corte_falda,
        Manga = p_Manga,
        Cola = p_Cola,
        Color = p_Color
    WHERE VestidoID = p_VestidoID;

    -- Registro en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'vestido',
        p_VestidoID,
        'UPDATE',
        'editar_vestido',
        CONCAT(
            'Se editó el vestido con VestidoID ', p_VestidoID,
            '. Nuevos valores - Codigo: ', p_Codigo,
            ', Talla: ', p_Talla,
            ', Tipo_escote: ', p_Tipo_escote,
            ', Corte_falda: ', p_Corte_falda,
            ', Manga: ', p_Manga,
            ', Cola: ', p_Cola,
            ', Color: ', p_Color
        ),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_carrito` (IN `p_cliente_id` INT, IN `p_estado` VARCHAR(20), IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Insertar carrito
    INSERT INTO carrito (ClienteID, Fecha_creacion, Estado)
    VALUES (p_cliente_id, NOW(), p_estado);

    SET @carrito_id = LAST_INSERT_ID();

    -- Log de la acción
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        NULL,               -- Si tienes UsuarioID relacionado puedes pasarlo, aquí va NULL (puedes buscarlo por ClienteID si lo necesitas)
        'carrito',
        @carrito_id,
        'INSERT',
        'insertar_carrito',
        p_detalle,
        p_ip_acceso
    );

    -- Retorna datos del nuevo carrito
    SELECT 'ok' AS status, 'Carrito creado exitosamente' AS mensaje, @carrito_id AS CarritoID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_carrito_item` (IN `p_carrito_id` INT, IN `p_catalogo_id` INT, IN `p_cantidad` INT, IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Validar que el carrito exista y esté activo
    IF NOT EXISTS (SELECT 1 FROM carrito WHERE CarritoID = p_carrito_id AND Estado = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El carrito no existe o está inactivo';
    END IF;

    -- Validar que el producto exista en catálogo y esté disponible
    IF NOT EXISTS (SELECT 1 FROM catalogo WHERE CatalogoID = p_catalogo_id AND Disponible = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe o no está disponible';
    END IF;

    -- Validar stock suficiente
    IF (SELECT Stock FROM catalogo WHERE CatalogoID = p_catalogo_id) < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente stock para este producto';
    END IF;

    -- Insertar ítem en el carrito
    INSERT INTO carrito_item (CarritoID, CatalogoID, Cantidad)
    VALUES (p_carrito_id, p_catalogo_id, p_cantidad);

    SET @item_id = LAST_INSERT_ID();

    -- Actualizar stock en catálogo
    UPDATE catalogo SET Stock = Stock - p_cantidad WHERE CatalogoID = p_catalogo_id;

    -- Registrar en log
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (
        NULL,
        'carrito_item',
        @item_id,
        'INSERT',
        'insertar_carrito_item',
        p_detalle,
        p_ip_acceso
    );

    SELECT 'ok' AS status, 'Producto agregado al carrito' AS mensaje, @item_id AS ItemID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_catalogo` (IN `p_ProductoID` INT, IN `p_Stock` INT, IN `p_Disponible` TINYINT, IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_CatalogoID INT;

    -- Insertar nuevo registro en catalogo
    INSERT INTO catalogo (ProductoID, Stock, Disponible)
    VALUES (p_ProductoID, p_Stock, p_Disponible);

    -- Obtener el ID del nuevo catálogo insertado
    SET v_CatalogoID = LAST_INSERT_ID();

    -- Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'catalogo',
        v_CatalogoID,
        'INSERT',
        'insertar_catalogo',
        CONCAT(
            'Se insertó un nuevo catálogo (CatalogoID: ', v_CatalogoID, 
            ', ProductoID: ', p_ProductoID, 
            ', Stock: ', p_Stock, 
            ', Disponible: ', p_Disponible, ')'
        ),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_producto` (IN `p_Nombre` VARCHAR(100), IN `p_Descripcion` TEXT, IN `p_Precio` DECIMAL(10,2), IN `p_TipoID` INT, IN `p_Imagen` TEXT, IN `p_UsuarioID` INT, IN `p_Modulo_afectado` VARCHAR(50), IN `p_IP_acceso` VARCHAR(100), IN `p_Detalle` TEXT)   BEGIN
    -- Insertar el producto
    INSERT INTO producto (Nombre, Descripcion, Precio, TipoID, Imagen)
    VALUES (p_Nombre, p_Descripcion, p_Precio, p_TipoID, p_Imagen);

    -- Obtener el ID del producto insertado
    SET @last_id = LAST_INSERT_ID();

    -- Registrar la acción en log_accion
    INSERT INTO log_accion (
        UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso
    )
    VALUES (
        p_UsuarioID, 'producto', @last_id, 'INSERT', p_Modulo_afectado, p_Detalle, p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_producto_extra` (IN `p_Codigo` VARCHAR(300), IN `p_ProductoID` INT, IN `p_Color` VARCHAR(50), IN `p_Material` VARCHAR(100), IN `p_Tamano` VARCHAR(50), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_GeneralID INT;

    -- Insertar producto_extra
    INSERT INTO producto_extra (Codigo, ProductoID, Color, Material, Tamano, Habilitado)
    VALUES (p_Codigo, p_ProductoID, p_Color, p_Material, p_Tamano, 1);

    -- Obtener el GeneralID recién insertado
    SET v_GeneralID = LAST_INSERT_ID();

    -- Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'producto_extra',
        v_GeneralID,
        'INSERT',
        'insertar_producto_extra',
        CONCAT(
            'Se insertó un producto_extra (GeneralID: ', v_GeneralID, 
            ', Codigo: ', p_Codigo, 
            ', ProductoID: ', p_ProductoID, 
            ', Color: ', p_Color, 
            ', Material: ', p_Material, 
            ', Tamano: ', p_Tamano, ')'
        ),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_rol` (IN `p_Rol_Nombre` VARCHAR(50), IN `p_Descripcion` VARCHAR(350), IN `p_Nivel_acceso` VARCHAR(10), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_RolID INT;

    -- Insertar nuevo rol
    INSERT INTO rol (Rol_Nombre, Descripcion, Nivel_acceso)
    VALUES (p_Rol_Nombre, p_Descripcion, p_Nivel_acceso);

    -- Obtener el ID recién insertado
    SET v_RolID = LAST_INSERT_ID();

    -- Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'rol',
        v_RolID,
        'INSERT',
        'insertar_rol',
        CONCAT(
            'Se insertó un nuevo rol (RolID: ', v_RolID, 
            ', Rol_Nombre: ', p_Rol_Nombre, 
            ', Descripcion: ', p_Descripcion, 
            ', Nivel_acceso: ', p_Nivel_acceso, ')'
        ),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_vestido` (IN `p_Codigo` VARCHAR(300), IN `p_ProductoID` INT, IN `p_Talla` VARCHAR(10), IN `p_Tipo_escote` VARCHAR(50), IN `p_Corte_falda` VARCHAR(50), IN `p_Manga` TINYINT, IN `p_Cola` TINYINT, IN `p_Color` VARCHAR(50), IN `p_UsuarioID` INT, IN `p_IP_acceso` VARCHAR(100))   BEGIN
    DECLARE v_VestidoID INT;

    -- Insertar nuevo vestido
    INSERT INTO vestido 
        (Codigo, ProductoID, Talla, Tipo_escote, Corte_falda, Manga, Cola, Color)
    VALUES
        (p_Codigo, p_ProductoID, p_Talla, p_Tipo_escote, p_Corte_falda, p_Manga, p_Cola, p_Color);

    -- Obtener el ID recién insertado
    SET v_VestidoID = LAST_INSERT_ID();

    -- Registrar en log_accion
    INSERT INTO log_accion (
        UsuarioID,
        Tabla_afectada,
        ID_registro,
        Accion,
        Modulo_afectado,
        Detalle,
        IP_acceso
    ) VALUES (
        p_UsuarioID,
        'vestido',
        v_VestidoID,
        'INSERT',
        'insertar_vestido',
        CONCAT(
            'Se insertó un nuevo vestido (VestidoID: ', v_VestidoID, 
            ', Codigo: ', p_Codigo, 
            ', ProductoID: ', p_ProductoID, 
            ', Talla: ', p_Talla, 
            ', Tipo_escote: ', p_Tipo_escote, 
            ', Corte_falda: ', p_Corte_falda, 
            ', Manga: ', p_Manga, 
            ', Cola: ', p_Cola, 
            ', Color: ', p_Color, ')'
        ),
        p_IP_acceso
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_catalogo` ()   BEGIN
    SELECT 
        c.CatalogoID,
        c.ProductoID,
        p.Nombre,
        p.Descripcion,
        p.Precio,
        p.Imagen,
        c.Stock,
        c.Disponible
    FROM catalogo c
    INNER JOIN producto p ON c.ProductoID = p.ProductoID
    WHERE c.Disponible = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_clientes` (IN `p_nombreUsuario` VARCHAR(50), IN `p_correo` VARCHAR(100), IN `p_habilitado` TINYINT)   BEGIN
    SELECT 
        c.ClienteID,
        u.UsuarioID,
        u.NombreUsuario,
        u.correo,
        u.Habilitado,
        r.Nombres,
        r.Ap_paterno,
        r.Ap_materno,
        r.CI,
        r.Telefono,
        r.Ciudad,
        r.Zona,
        r.Calle,
        r.Nro_puerta
    FROM cliente c
    INNER JOIN usuario u ON c.UsuarioID = u.UsuarioID
    INNER JOIN registro r ON u.RegistroID = r.RegistroID
    WHERE
        (p_nombreUsuario IS NULL OR u.NombreUsuario LIKE CONCAT('%', p_nombreUsuario, '%'))
        AND (p_correo IS NULL OR u.correo LIKE CONCAT('%', p_correo, '%'))
        AND (p_habilitado IS NULL OR u.Habilitado = p_habilitado);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_productos` ()   BEGIN
    SELECT 
        p.ProductoID, 
        p.Nombre, 
        p.Descripcion, 
        p.Precio, 
        p.TipoID, 
        t.Nombre_tipo, 
        p.Imagen,
        c.CatalogoID,
        c.Stock,
        c.Disponible
    FROM producto p
    LEFT JOIN tipo_producto t ON p.TipoID = t.TipoID
    LEFT JOIN catalogo c ON p.ProductoID = c.ProductoID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_producto_extra` ()   BEGIN
    SELECT 
        GeneralID,
        Codigo,
        ProductoID,
        Color,
        Material,
        Tamano
    FROM producto_extra
    WHERE Habilitado = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_roles` ()   BEGIN
    SELECT 
        RolID,
        Rol_Nombre,
        Descripcion,
        Nivel_acceso
    FROM rol;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_usuarios` ()   BEGIN
    SELECT 
        u.UsuarioID, 
        u.NombreUsuario, 
        u.correo, 
        u.Habilitado, 
        u.RolID, 
        r.Nombres, 
        r.Ap_paterno, 
        r.Ap_materno, 
        r.CI, 
        r.Telefono, 
        u.RegistroID
    FROM usuario u
    INNER JOIN registro r ON u.RegistroID = r.RegistroID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuario` (IN `p_usuario_o_correo` VARCHAR(100))   BEGIN
    SELECT *
    FROM usuario
    WHERE (NombreUsuario = p_usuario_o_correo OR correo = p_usuario_o_correo)
      AND Habilitado = 1
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_recuperar_contrasena` (IN `p_usuario_id` INT, IN `p_nuevo_hash` VARCHAR(255), IN `p_detalle` TEXT, IN `p_ip_acceso` VARCHAR(100))   BEGIN
    -- Validar que el usuario exista y esté habilitado
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE UsuarioID = p_usuario_id AND Habilitado = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o está dado de baja';
    END IF;

    -- Cambiar contraseña
    UPDATE usuario SET Contrasena = p_nuevo_hash WHERE UsuarioID = p_usuario_id;

    -- Log
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (p_usuario_id, 'usuario', p_usuario_id, 'UPDATE', 'recuperacion', p_detalle, p_ip_acceso);

    -- Mensaje de éxito
    SELECT 'ok' AS status, 'Contraseña actualizada correctamente' AS mensaje, p_usuario_id AS UsuarioID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_usuario` (IN `p_nombre_usuario` VARCHAR(50), IN `p_correo` VARCHAR(100), IN `p_contrasena` VARCHAR(255), IN `p_nombres` VARCHAR(200), IN `p_ap_paterno` VARCHAR(200), IN `p_ap_materno` VARCHAR(200), IN `p_ci` INT, IN `p_fecha_nacimiento` DATE, IN `p_telefono` INT, IN `p_ciudad` ENUM('LA PAZ','EL ALTO','SANTA CRUZ','COCHABAMBA','TARIJA','PANDO','CHUQUISACA','BENI','ORURO','POTOSI'), IN `p_zona` VARCHAR(100), IN `p_calle` VARCHAR(100), IN `p_nro_puerta` VARCHAR(6), IN `p_ip_acceso` VARCHAR(100), IN `p_detalle` TEXT)   BEGIN
    -- 1. Validar que no exista usuario ni correo
    IF EXISTS (SELECT 1 FROM usuario WHERE NombreUsuario = p_nombre_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario ya está registrado';
    END IF;
    IF EXISTS (SELECT 1 FROM usuario WHERE correo = p_correo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo ya está registrado';
    END IF;

    -- 2. Validar que el CI no esté duplicado en registro
    IF EXISTS (SELECT 1 FROM registro WHERE CI = p_ci) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El CI ya está registrado';
    END IF;

    -- 3. Insertar en registro (datos personales)
    INSERT INTO registro (Nombres, Ap_paterno, Ap_materno, CI, Fecha_nacimiento, Telefono, Ciudad, Zona, Calle, Nro_puerta)
    VALUES (p_nombres, p_ap_paterno, p_ap_materno, p_ci, p_fecha_nacimiento, p_telefono, p_ciudad, p_zona, p_calle, p_nro_puerta);

    SET @registro_id = LAST_INSERT_ID();

    -- 4. Insertar en usuario (datos de acceso, por defecto Habilitado=1 y RolID=5)
    INSERT INTO usuario (NombreUsuario, correo, Contrasena, Habilitado, RolID, RegistroID)
    VALUES (p_nombre_usuario, p_correo, p_contrasena, 1, 5, @registro_id);

    SET @usuario_id = LAST_INSERT_ID();

    -- 5. Insertar en cliente (relacionar UsuarioID)
    INSERT INTO cliente (UsuarioID) VALUES (@usuario_id);

    -- 6. Loguear la acción en log_accion
    INSERT INTO log_accion (UsuarioID, Tabla_afectada, ID_registro, Accion, Modulo_afectado, Detalle, IP_acceso)
    VALUES (@usuario_id, 'usuario', @usuario_id, 'INSERT', 'registro', p_detalle, p_ip_acceso);

    -- 7. Mensaje de éxito
    SELECT 'ok' AS status, 'Usuario registrado exitosamente' AS mensaje, @usuario_id AS UsuarioID;
END$$

DELIMITER ;

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

--
-- Volcado de datos para la tabla `carrito`
--

INSERT INTO `carrito` (`CarritoID`, `ClienteID`, `Fecha_creacion`, `Estado`) VALUES
(1, 1, '2025-06-03 23:58:24', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito_item`
--

CREATE TABLE `carrito_item` (
  `ItemID` int NOT NULL,
  `CarritoID` int DEFAULT NULL,
  `CatalogoID` int DEFAULT NULL,
  `Cantidad` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogo`
--

CREATE TABLE `catalogo` (
  `CatalogoID` int NOT NULL,
  `ProductoID` int DEFAULT NULL,
  `Stock` int NOT NULL,
  `Disponible` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `catalogo`
--

INSERT INTO `catalogo` (`CatalogoID`, `ProductoID`, `Stock`, `Disponible`) VALUES
(1, 1, 5, 1),
(2, 2, 5, 1),
(3, 3, 50, 0),
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
(1, 1),
(2, 2),
(3, 3);

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

--
-- Volcado de datos para la tabla `log_accion`
--

INSERT INTO `log_accion` (`LogID`, `UsuarioID`, `Tabla_afectada`, `ID_registro`, `Accion`, `Modulo_afectado`, `Detalle`, `Fecha`, `IP_acceso`) VALUES
(1, 3, 'usuario', 3, 'INSERT', 'registro', 'Prueba de registro por SP', '2025-06-03 23:01:49', '127.0.0.1'),
(2, 1, 'usuario', 1, 'UPDATE', 'edicion', 'Modificación test', '2025-06-03 23:16:20', '127.0.0.1'),
(3, NULL, 'carrito', 1, 'INSERT', 'insertar_carrito', 'Carrito creado desde SP', '2025-06-03 23:58:24', '127.0.0.1'),
(4, NULL, 'carrito_item', 1, 'INSERT', 'insertar_carrito_item', 'Agregado desde SP', '2025-06-03 23:59:51', '127.0.0.1'),
(5, NULL, 'carrito_item', 1, 'UPDATE', 'actualizar_cantidad_item_carrito', 'Aumento cantidad en SP', '2025-06-04 00:06:00', '127.0.0.1'),
(6, NULL, 'carrito_item', 1, 'DELETE', 'eliminar_item_carrito_logico', 'Eliminación desde SP', '2025-06-04 00:06:50', '127.0.0.1');

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
  `Imagen` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `Activo` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`ProductoID`, `Nombre`, `Descripcion`, `Precio`, `TipoID`, `Imagen`, `Activo`) VALUES
(1, 'VESTIDO DE NOVIA', 'Vestido de Novia, corte sirena, escote corazon, color Blanco, decorado brilloso, sin mangas, sin cola, talla \"M\".', 4300.00, 1, 'VDN01', 1),
(2, 'VESTIDO DE NOVIA', 'Vestido de Novia corte A, color Perla claro, decorado sencillo, con mangas, con cola, talla \"L\".', 3000.00, 1, 'VDN02', 1),
(3, 'VESTIDO DE NOVIA', 'Vestido de Novia, corte sirena, escote corazon, color Blanco, decorado brilloso, sin mangas, sin cola, talla \"L\".', 4500.00, 1, 'VDN03', 1),
(4, 'VESTIDO DE NOVIA', 'Vestido de Novia color Blanco, escote corazon, con mangas, sin cola, corte de falda princesa, talla \"XL\".', 5000.00, 1, 'VDN04', 1),
(5, 'VESTIDO DE FIESTA', 'Vestido de fiesta color Beige, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"XL\".', 2500.00, 2, 'VDF01', 1),
(6, 'VESTIDO DE FIESTA', 'Vestido de fiesta color Palo de Rosa, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"M\".', 1850.00, 2, 'VDF02', 1),
(7, 'VESTIDO DE FIESTA', 'Vestido de fiesta color palo de rosa, escote corazon, sin mangas, sin cola, corte de falda princesa, talla \"L\".', 2000.00, 2, 'VDF03', 1),
(8, 'BOUQUET', 'Bouquet de color perla claro y guindo hecho de porcelana ligera de tamaño mediano.', 200.00, 3, 'BP01', 1),
(9, 'CORONA', 'Corona color chapagne, hecho con piedras brillosas baroskie, tamaño pequeño.', 120.00, 4, 'CR01', 1),
(10, 'VELO', 'Velo color blanco, estilo catedral, con finas capas de tul brilloso, tamaño grande.', 650.00, 5, 'VL01', 1);

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
  `Tamano` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_extra`
--

INSERT INTO `producto_extra` (`GeneralID`, `Codigo`, `ProductoID`, `Color`, `Material`, `Tamano`, `Habilitado`) VALUES
(1, 'BP01', 8, 'Perla Claro y Guindo', 'Porcelana', 'Mediano', 1),
(2, 'CR01', 9, 'Champagne', 'Piedras Brillosas', 'Pequeño', 1),
(3, 'VL01', 10, 'Blanco', 'Tul Brilloso', 'Grande', 1),
(4, 'PRX01-EDIT', 1, 'Azul', 'Plástico', 'Grande', 0);

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
  `Detalles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `Estado` enum('Emitido','Anulado') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Emitido'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recuperacion`
--

CREATE TABLE `recuperacion` (
  `RecuperID` int NOT NULL,
  `correo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `codigo` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `creado_fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `usado` tinyint DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro`
--

CREATE TABLE `registro` (
  `RegistroID` int NOT NULL,
  `Nombres` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Ap_paterno` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Ap_materno` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `CI` int NOT NULL,
  `Fecha_nacimiento` date DEFAULT NULL,
  `Telefono` int NOT NULL,
  `Ciudad` enum('LA PAZ','EL ALTO','SANTA CRUZ','COCHABAMBA','TARIJA','PANDO','CHUQUISACA','BENI','ORURO','POTOSI') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT (_cp850'LA PAZ'),
  `Zona` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Calle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Nro_puerta` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `registro`
--

INSERT INTO `registro` (`RegistroID`, `Nombres`, `Ap_paterno`, `Ap_materno`, `CI`, `Fecha_nacimiento`, `Telefono`, `Ciudad`, `Zona`, `Calle`, `Nro_puerta`) VALUES
(1, 'NuevoNombre', 'NuevoApellidoP', 'NuevoApellidoM', 13760247, '2005-08-08', 76543210, 'LA PAZ', 'Sopocachi', 'Av. Ecuador', '123'),
(2, 'Vicente Oscar', 'Claros', 'Mamani', 6078641, '1994-09-27', 75229226, 'LA PAZ', 'sopocachi', 'capitan ravelo', '345'),
(3, 'Juan', 'Perez', 'Gomez', 12345678, '2000-01-01', 77777777, 'LA PAZ', 'Miraflores', 'Av. Ejemplo', '123');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `RolID` int NOT NULL,
  `Rol_Nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Descripcion` varchar(350) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Nivel_acceso` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`RolID`, `Rol_Nombre`, `Descripcion`, `Nivel_acceso`, `Habilitado`) VALUES
(1, 'Super Admin', '', '', 1),
(2, 'Propietario', 'Descripción actualizada para Propietario', '2', 0),
(3, 'Encargado del Inventario', '', '', 1),
(4, 'Vendedor', '', '', 1),
(5, 'Cliente', '', '', 1);

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

--
-- Volcado de datos para la tabla `sesion_usuario`
--

INSERT INTO `sesion_usuario` (`SesionID`, `UsuarioID`, `Token`, `IP_acceso`, `Activa`, `Fecha_inicio`, `Fecha_fin`) VALUES
(1, 2, 'c0f733d0118825f5b200e9631d97156ba97f712327bf77820435a488161bf43e', '::1', 1, '2025-06-04 10:19:16', NULL),
(2, 2, 'fad4b7ff2ab32da6971c95b262dee41207fd06d639a7723112ae06c18dafafa1', '::1', 1, '2025-06-04 10:28:36', NULL),
(3, 2, '4b33eff48a1b355c8ed31687a191e734063cefb87a1c5d53e4e6efe34d7f397d', '::1', 1, '2025-06-04 10:30:34', NULL),
(4, 2, '0a438398d9ca192cd9e6abf79f39d1fd628f8bd9cc0860260d217b67fcda4e39', '::1', 1, '2025-06-04 12:18:57', NULL),
(5, 2, 'f21ecd7b6db7d7115af33c25ce8a7e09c461446477dbc0a9058f8317b3ba4504', '::1', 1, '2025-06-04 12:39:27', NULL),
(6, 2, '1205af581affa9f1b60e1bdb415c4382821134d09cca9298f233053eede94bb0', '::1', 1, '2025-06-04 13:52:47', NULL),
(7, 2, '95aaa1d9f53f102ee99ad3d9f2d8d8fe56d441eca3c24af68d4804e8cd0ad180', '::1', 1, '2025-06-04 16:16:37', NULL);

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
(1, 'NuevoUsuario', 'nuevoemail@example.com', '$2y$10$pruebahashdecontraseña', 0, 5, 1),
(2, 'Banvinhard2', 'proometeous.banvinhard@gmail.com', '$2y$10$TCGOym.T46Pcis2raPPLVup5dRVn6C31YCXmWYDNRA/CvWARp6/.O', 1, 5, 2),
(3, 'usuario_prueba', 'prueba@email.com', '$2y$10$1234567890123456789012pruebadehashseguro', 1, 5, 3);

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
  `Color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vestido`
--

INSERT INTO `vestido` (`VestidoID`, `Codigo`, `ProductoID`, `Talla`, `Tipo_escote`, `Corte_falda`, `Manga`, `Cola`, `Color`, `Habilitado`) VALUES
(1, 'VDN01', 1, 'M', 'Corazon', 'Sirena', 0, 0, 'Blanco', 1),
(2, 'VDN02', 2, 'L', 'Corazon', 'A', 1, 1, 'Perla claro', 1),
(3, 'VDN03', 3, 'L', 'Corazon', 'Sirena', 0, 0, 'Blanco', 1),
(4, 'VDN04_EDIT', 4, 'L', 'Barco', 'Imperio', 0, 1, 'Champagne', 1),
(5, 'VDF01', 5, 'XL', 'Corazon', 'Princesa', 0, 0, 'Beige', 1),
(6, 'VDF02', 6, 'M', 'Corazon', 'Princesa', 0, 0, 'Palo de rosa', 1),
(7, 'VDF03', 7, 'L', 'Corazon', 'Princesa', 0, 0, 'Palo de rosa', 1);

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
  MODIFY `CarritoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `carrito_item`
--
ALTER TABLE `carrito_item`
  MODIFY `ItemID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `catalogo`
--
ALTER TABLE `catalogo`
  MODIFY `CatalogoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `cita`
--
ALTER TABLE `cita`
  MODIFY `CitaID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `ClienteID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  MODIFY `LogID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
-- AUTO_INCREMENT de la tabla `producto_extra`
--
ALTER TABLE `producto_extra`
  MODIFY `GeneralID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `RegistroID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `RolID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `sesion_usuario`
--
ALTER TABLE `sesion_usuario`
  MODIFY `SesionID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `UsuarioID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `vestido`
--
ALTER TABLE `vestido`
  MODIFY `VestidoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
