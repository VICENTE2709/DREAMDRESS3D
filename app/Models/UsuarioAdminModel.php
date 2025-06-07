<?php
require_once(__DIR__ . '/../config/database.php');

/**
 * Listar todos los usuarios (SP: sp_listar_usuarios)
 */
function listar_usuarios_admin() {
    $db = Database::connect();
    $stmt = $db->prepare("CALL sp_listar_usuarios()");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Editar usuario (SP: sp_editar_usuario)
 */
function editar_usuario_admin($datos) {
    $db = Database::connect();
    $stmt = $db->prepare("CALL sp_editar_usuario(:UsuarioID, :NombreUsuario, :correo, :RolID, :Habilitado)");
    return $stmt->execute([
        'UsuarioID'      => $datos['UsuarioID'],
        'NombreUsuario'  => $datos['NombreUsuario'],
        'correo'         => $datos['correo'],
        'RolID'          => $datos['RolID'],
        'Habilitado'     => $datos['Habilitado'],
    ]);
}

/**
 * Dar de baja lógica a usuario (SP: sp_baja_usuario)
 */
function baja_usuario_admin($usuarioId) {
    $db = Database::connect();
    $stmt = $db->prepare("CALL sp_baja_usuario(:UsuarioID)");
    return $stmt->execute(['UsuarioID' => $usuarioId]);
}
