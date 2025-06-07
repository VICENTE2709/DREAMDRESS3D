<?php
// app/Models/ClienteModel.php

require_once(__DIR__ . '/../../config/database.php');

// Obtiene los datos del cliente a partir del UsuarioID
function obtenerDatosCliente($usuarioID) {
    $db = Database::connect();
    $sql = "
        SELECT c.*, u.NombreUsuario, u.correo, r.Nombres, r.Ap_paterno, r.Ap_materno
        FROM cliente c
        INNER JOIN usuario u ON u.UsuarioID = c.UsuarioID
        INNER JOIN registro r ON u.RegistroID = r.RegistroID
        WHERE c.UsuarioID = :usuarioID
        LIMIT 1
    ";
    $stmt = $db->prepare($sql);
    $stmt->execute(['usuarioID' => $usuarioID]);
    return $stmt->fetch(PDO::FETCH_ASSOC); // Devuelve un array asociativo o false si no existe
}
