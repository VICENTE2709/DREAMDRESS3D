<?php
// Cargar la conexión PDO usando tu clase Singleton
require_once(__DIR__ . '/../../config/database.php');

/**
 * Listar todos los usuarios usando un procedimiento almacenado
 */
function listarUsuarios() {
    $pdo = Database::connect();
    $stmt = $pdo->prepare("CALL sp_listar_usuarios()");
    $stmt->execute();
    $usuarios = $stmt->fetchAll();
    $stmt->closeCursor(); // MUY importante al usar SP con PDO
    return $usuarios;
}

/**
 * Agregar usuario usando SP (ejemplo, adapta los parámetros a tu SP)
 */
function agregarUsuario($nombreUsuario, $correo, $contrasena, $rolID, $registroID) {
    $pdo = Database::connect();
    $stmt = $pdo->prepare("CALL sp_agregar_usuario(:nombreUsuario, :correo, :contrasena, :rolID, :registroID)");
    $stmt->bindParam(':nombreUsuario', $nombreUsuario);
    $stmt->bindParam(':correo', $correo);
    $stmt->bindParam(':contrasena', $contrasena); // Hashea antes de llamar
    $stmt->bindParam(':rolID', $rolID, PDO::PARAM_INT);
    $stmt->bindParam(':registroID', $registroID, PDO::PARAM_INT);
    $stmt->execute();
    $stmt->closeCursor();
    return true;
}

/**
 * Editar usuario usando SP
 */
function editarUsuario($usuarioID, $nombreUsuario, $correo, $rolID) {
    $pdo = Database::connect();
    $stmt = $pdo->prepare("CALL sp_editar_usuario(:usuarioID, :nombreUsuario, :correo, :rolID)");
    $stmt->bindParam(':usuarioID', $usuarioID, PDO::PARAM_INT);
    $stmt->bindParam(':nombreUsuario', $nombreUsuario);
    $stmt->bindParam(':correo', $correo);
    $stmt->bindParam(':rolID', $rolID, PDO::PARAM_INT);
    $stmt->execute();
    $stmt->closeCursor();
    return true;
}

/**
 * Eliminar usuario (lógica, no física)
 */
function eliminarUsuario($usuarioID) {
    $pdo = Database::connect();
    $stmt = $pdo->prepare("CALL sp_eliminar_usuario(:usuarioID)");
    $stmt->bindParam(':usuarioID', $usuarioID, PDO::PARAM_INT);
    $stmt->execute();
    $stmt->closeCursor();
    return true;
}
?>
