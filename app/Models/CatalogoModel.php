<?php
require_once(__DIR__ . '/../../config/database.php');

/**
 * Obtener todos los productos del catálogo
 * Utiliza el stored procedure sp_listar_catalogo
 */
function catalogo_obtener_todos() {
    $conn = Database::connect();

    $stmt = $conn->prepare("CALL sp_listar_catalogo()");
    $stmt->execute();

    $productos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $stmt->closeCursor();

    return $productos;
}

/**
 * Obtener producto por ID
 */
function catalogo_obtener_por_id($productoID) {
    $conn = Database::connect();

    $stmt = $conn->prepare("CALL sp_listar_productos()");
    $stmt->execute();

    $productos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $stmt->closeCursor();

    foreach ($productos as $producto) {
        if ($producto['ProductoID'] == $productoID) {
            return $producto;
        }
    }

    return null;
}
