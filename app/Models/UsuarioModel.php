<?php
require_once(__DIR__ . '/../../config/database.php');

/**
 * LOGIN de usuario (usando SP y hash desde PHP)
 * Llama a: sp_login_usuario(p_usuario_o_correo)
 */
function modelo_login_usuario($usuario_o_correo, $contrasena) {
    $db = Database::connect();

    $sql = "CALL sp_login_usuario(:p_usuario_o_correo)";
    $stmt = $db->prepare($sql);
    $stmt->execute(['p_usuario_o_correo' => $usuario_o_correo]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    $stmt->closeCursor();

    if (!$usuario) {
        return ['success' => false, 'message' => 'Usuario o correo no encontrado.'];
    }

    if (!$usuario['Habilitado']) {
        return ['success' => false, 'message' => 'Usuario deshabilitado. Contacta al administrador.'];
    }

    if (!password_verify($contrasena, $usuario['Contrasena'])) {
        return ['success' => false, 'message' => 'Contraseña incorrecta.'];
    }

    unset($usuario['Contrasena']);

    return ['success' => true, 'usuario' => $usuario];
}

/**
 * REGISTRAR usuario (usando SP)
 * Debes tener un SP tipo: sp_registrar_usuario(...)
 */
function modelo_registrar_usuario($datos) {
    $db = Database::connect();
    try {
        $hash = password_hash($datos['contrasena'], PASSWORD_DEFAULT);

        $sql = "CALL sp_registrar_usuario(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        $stmt->execute([
            $datos['nombre'],             // p_nombres
            $datos['ap_paterno'],         // p_ap_paterno
            $datos['ap_materno'],         // p_ap_materno
            $datos['carnet_i'],           // p_ci
            $datos['fecha_nacimiento'],   // p_fecha_nacimiento
            $datos['telefono'],           // p_telefono
            strtoupper($datos['ciudad']), // p_ciudad
            $datos['zona'],               // p_zona
            $datos['calle'],              // p_calle
            $datos['puerta'],             // p_nro_puerta
            $datos['nombre_usuario'],     // p_nombre_usuario
            $datos['email'],              // p_correo
            $hash,                       // p_contrasena
            $datos['detalle'] ?? '',      // p_detalle
            $datos['ip_acceso'] ?? ''     // p_ip_acceso
        ]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        if (isset($result['success']) && $result['success']) {
            return [
                'success' => true,
                'message' => $result['message'],
                'usuario_id' => $result['usuario_id'] ?? null
            ];
        } else {
            return [
                'success' => false,
                'message' => $result['message'] ?? 'Error desconocido'
            ];
        }
    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

/**
 * Registrar sesión del usuario usando SP (si tienes un SP para sesiones)
 * Si no, deja el SQL aquí temporalmente, o dime y creo el SP.
 */
function registrarSesionUsuario($usuarioId, $token, $ip) {
    $db = Database::connect();
    // Si tienes SP tipo sp_registrar_sesion_usuario, usa así:
    // $sql = "CALL sp_registrar_sesion_usuario(:usuarioId, :token, :ip)";
    // $stmt = $db->prepare($sql);
    // return $stmt->execute(['usuarioId' => $usuarioId, 'token' => $token, 'ip' => $ip]);
    // --- Si no hay SP, puedes usar el SQL temporalmente: ---
    $sql = "INSERT INTO sesion_usuario (UsuarioID, Token, IP_acceso, Activa, Fecha_inicio) VALUES (:usuarioId, :token, :ip, 1, NOW())";
    $stmt = $db->prepare($sql);
    return $stmt->execute([
        'usuarioId' => $usuarioId,
        'token' => $token,
        'ip' => $ip
    ]);
}
