<?php
// app/Models/ProductoModel.php

require_once(__DIR__ . '/../../config/database.php');

/**
 * Crear un producto (llama al SP correspondiente)
 */
function crearProducto($nombre, $descripcion, $precio, $tipoID, $imagen, $usuarioID, $modulo_afectado, $ip_acceso, $detalle) {
    $db = Database::connect();
    $sql = "CALL sp_crear_producto(:nombre, :descripcion, :precio, :tipoID, :imagen, :usuarioID, :modulo_afectado, :ip_acceso, :detalle)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':nombre', $nombre);
    $stmt->bindParam(':descripcion', $descripcion);
    $stmt->bindParam(':precio', $precio);
    $stmt->bindParam(':tipoID', $tipoID);
    $stmt->bindParam(':imagen', $imagen);
    $stmt->bindParam(':usuarioID', $usuarioID);
    $stmt->bindParam(':modulo_afectado', $modulo_afectado);
    $stmt->bindParam(':ip_acceso', $ip_acceso);
    $stmt->bindParam(':detalle', $detalle);

    if ($stmt->execute()) {
        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
        return $resultado ?: ['status' => 'ok', 'mensaje' => 'Producto creado correctamente'];
    } else {
        return ['status' => 'error', 'mensaje' => 'Error al crear producto'];
    }
}

/**
 * Editar producto (llama al SP correspondiente)
 */
function editarProducto($productoID, $nombre, $descripcion, $precio, $tipoID, $imagen, $usuarioID, $modulo_afectado, $ip_acceso, $detalle) {
    $db = Database::connect();
    $sql = "CALL sp_editar_producto(:productoID, :nombre, :descripcion, :precio, :tipoID, :imagen, :usuarioID, :modulo_afectado, :ip_acceso, :detalle)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':productoID', $productoID);
    $stmt->bindParam(':nombre', $nombre);
    $stmt->bindParam(':descripcion', $descripcion);
    $stmt->bindParam(':precio', $precio);
    $stmt->bindParam(':tipoID', $tipoID);
    $stmt->bindParam(':imagen', $imagen);
    $stmt->bindParam(':usuarioID', $usuarioID);
    $stmt->bindParam(':modulo_afectado', $modulo_afectado);
    $stmt->bindParam(':ip_acceso', $ip_acceso);
    $stmt->bindParam(':detalle', $detalle);

    if ($stmt->execute()) {
        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
        return $resultado ?: ['status' => 'ok', 'mensaje' => 'Producto actualizado correctamente'];
    } else {
        return ['status' => 'error', 'mensaje' => 'Error al editar producto'];
    }
}

/**
 * Baja lógica (desactivar producto)
 */
function bajaLogicaProducto($productoID, $usuarioID, $modulo_afectado, $ip_acceso, $detalle) {
    $db = Database::connect();
    $sql = "CALL sp_baja_producto(:productoID, :usuarioID, :modulo_afectado, :ip_acceso, :detalle)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':productoID', $productoID);
    $stmt->bindParam(':usuarioID', $usuarioID);
    $stmt->bindParam(':modulo_afectado', $modulo_afectado);
    $stmt->bindParam(':ip_acceso', $ip_acceso);
    $stmt->bindParam(':detalle', $detalle);

    if ($stmt->execute()) {
        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
        return $resultado ?: ['status' => 'ok', 'mensaje' => 'Producto dado de baja correctamente'];
    } else {
        return ['status' => 'error', 'mensaje' => 'Error al dar de baja el producto'];
    }
}

/**
 * Buscar producto por ID (SELECT directo)
 */
function obtenerProductoPorID($productoID) {
    $db = Database::connect();
    $sql = "SELECT * FROM producto WHERE ProductoID = :productoID";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':productoID', $productoID, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

/**
 * Listar productos activos (SELECT directo)
 */
function listarProductosActivos() {
    $db = Database::connect();
    $sql = "SELECT p.*, c.Stock, c.Disponible 
            FROM producto p
            INNER JOIN catalogo c ON c.ProductoID = p.ProductoID
            WHERE c.Disponible = 1";
    $stmt = $db->prepare($sql);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
