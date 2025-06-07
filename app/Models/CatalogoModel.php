<?php
require_once(__DIR__ . '/../../config/database.php');

/**
 * Obtener todos los productos del catálogo
 * Consulta directa sin stored procedures
 */
function catalogo_obtener_todos() {
    $conn = Database::connect();

    // Consulta JOIN para obtener productos con información completa
    $sql = "SELECT 
                p.ProductoID,
                p.Nombre,
                p.Descripcion,
                p.Precio,
                p.Imagen,
                tp.Nombre_tipo as TipoProducto,
                c.Stock,
                c.Disponible
            FROM producto p
            INNER JOIN tipo_producto tp ON p.TipoID = tp.TipoID
            LEFT JOIN catalogo c ON p.ProductoID = c.ProductoID
            WHERE c.Disponible = 1 OR c.Disponible IS NULL
            ORDER BY p.Nombre ASC";
    
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    
    $productos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    return $productos;
}

/**
 * Obtener producto por ID
 */
function catalogo_obtener_por_id($productoID) {
    $conn = Database::connect();

    $sql = "SELECT 
                p.ProductoID,
                p.Nombre,
                p.Descripcion,
                p.Precio,
                p.Imagen,
                tp.Nombre_tipo as TipoProducto,
                c.Stock,
                c.Disponible
            FROM producto p
            INNER JOIN tipo_producto tp ON p.TipoID = tp.TipoID
            LEFT JOIN catalogo c ON p.ProductoID = c.ProductoID
            WHERE p.ProductoID = :productoID";
    
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':productoID', $productoID, PDO::PARAM_INT);
    $stmt->execute();
    
    return $stmt->fetch(PDO::FETCH_ASSOC);
}
