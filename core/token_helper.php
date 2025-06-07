<?php
require_once(__DIR__ . '/../config/database.php');

/**
 * Responde con un mensaje de error JSON y termina la ejecución
 * @param string $mensaje Mensaje de error a enviar
 * @param int $codigo Código HTTP (por defecto 401)
 */
function responderError($mensaje, $codigo = 401) {
    http_response_code($codigo);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'status' => 'error',
        'message' => $mensaje
    ]);
    exit;
}

/**
 * Valida el token enviado por Authorization: Bearer [TOKEN]
 * - Devuelve el array de sesión encontrada (incluye UsuarioID, etc.)
 * - Si el token es inválido o está vencido, responde error y termina.
 * @return array Sesión de usuario válida
 */
function validarToken() {
    $headers = function_exists('getallheaders') ? getallheaders() : [];

    // Permitir compatibilidad con mayúsculas/minúsculas
    $authorizationHeader = '';
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            $authorizationHeader = $value;
            break;
        }
    }

    if (!$authorizationHeader) {
        responderError('Token requerido.');
    }
    if (strpos($authorizationHeader, 'Bearer ') !== 0) {
        responderError('Formato de token inválido.');
    }
    $token = substr($authorizationHeader, 7);

    $db = Database::connect();
    $stmt = $db->prepare("SELECT * FROM sesion_usuario WHERE Token = :token AND Activa = 1 LIMIT 1");
    $stmt->execute(['token' => $token]);
    $sesion = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$sesion) {
        responderError('Token inválido o expirado.');
    }
    return $sesion; // Retorna toda la sesión (incluye UsuarioID)
}

/**
 * Cierra una sesión activa (logout) usando el token
 * - Cambia Activa=0 y fecha_fin
 * @param string $token Token de la sesión
 * @return bool True si cerró sesión correctamente
 */
function cerrarSesion($token) {
    $db = Database::connect();
    $stmt = $db->prepare("UPDATE sesion_usuario SET Activa = 0, Fecha_fin = NOW() WHERE Token = :token AND Activa = 1");
    $stmt->execute(['token' => $token]);
    return $stmt->rowCount() > 0;
}
