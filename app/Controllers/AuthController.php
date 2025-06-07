<?php
require_once(__DIR__ . '/../Models/UsuarioModel.php');
require_once(__DIR__ . '/../../core/functions.php');
require_once(__DIR__ . '/../../core/token_helper.php');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

/**
 * Acción: login
 */
function login() {
    try {
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            render('auth/login');
            exit;
        }
        header('Content-Type: application/json');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $input = json_decode(file_get_contents("php://input"), true);

            $usuarioInput = isset($input['usuario']) ? trim($input['usuario']) : null;
            $contrasenaInput = $input['contrasena'] ?? null;

            if (!$usuarioInput || !$contrasenaInput) {
                respuesta_json(['status' => 'error', 'message' => 'Faltan datos: usuario o contraseña.'], 400);
            }

            $result = modelo_login_usuario($usuarioInput, $contrasenaInput);
            if (!$result['success']) {
                respuesta_json(['status' => 'error', 'message' => $result['message']], 401);
            }
            $usuario = $result['usuario'];
            if (!$usuario['Habilitado']) {
                respuesta_json(['status' => 'error', 'message' => 'Usuario deshabilitado. Contacta al administrador.'], 403);
            }

            $token = bin2hex(random_bytes(32));
            $ip = $_SERVER['REMOTE_ADDR'];
            registrarSesionUsuario($usuario['UsuarioID'], $token, $ip);

            respuesta_json([
                'status' => 'success',
                'usuario' => [
                    'usuario_id' => $usuario['UsuarioID'],
                    'nombre_usuario' => $usuario['NombreUsuario'],
                    'rol_id' => $usuario['RolID'],
                    'token' => $token
                ]
            ], 200);
        } else {
            respuesta_json(['status' => 'error', 'message' => 'Método no permitido.'], 405);
        }
    } catch (Exception $e) {
        respuesta_json(['status' => 'error', 'message' => 'Error interno: ' . $e->getMessage()], 500);
    }
}

/**
 * Acción: registro
 */
function registro() {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        header('Location: /login');
        exit;
    }
    header('Content-Type: application/json');
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents("php://input"), true);

        // Validaciones igual que antes
        $camposRequeridos = [
            'nombre', 'ap_paterno', 'ap_materno', 'carnet_i', 'fecha_nacimiento',
            'email', 'telefono', 'ciudad', 'zona', 'calle', 'puerta',
            'nombre_usuario', 'contrasena'
        ];

        foreach ($camposRequeridos as $campo) {
            if (!isset($input[$campo]) || trim($input[$campo]) === '') {
                respuesta_json(['status' => 'error', 'message' => "El campo $campo es requerido."], 400);
            }
        }
        if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
            respuesta_json(['status' => 'error', 'message' => 'El formato del correo electrónico no es válido.'], 400);
        }
        // ...agrega aquí validaciones de unicidad si las necesitas vía otros SP...

        try {
            $datosUsuario = [
                'nombre' => trim($input['nombre']),
                'ap_paterno' => trim($input['ap_paterno']),
                'ap_materno' => trim($input['ap_materno']),
                'carnet_i' => trim($input['carnet_i']),
                'fecha_nacimiento' => $input['fecha_nacimiento'],
                'telefono' => trim($input['telefono']),
                'ciudad' => strtoupper(trim($input['ciudad'])),
                'zona' => trim($input['zona']),
                'calle' => trim($input['calle']),
                'puerta' => trim($input['puerta']),
                'nombre_usuario' => trim($input['nombre_usuario']),
                'email' => trim($input['email']),
                'contrasena' => $input['contrasena'],
                'detalle' => 'Registro vía formulario web',
                'ip_acceso' => $_SERVER['REMOTE_ADDR']
            ];
            $result = modelo_registrar_usuario($datosUsuario);

            if ($result['success']) {
                respuesta_json([
                    'status' => 'success',
                    'message' => $result['message'],
                    'usuario_id' => $result['usuario_id']
                ], 201);
            } else {
                respuesta_json(['status' => 'error', 'message' => $result['message']], 500);
            }
        } catch (Exception $e) {
            respuesta_json(['status' => 'error', 'message' => 'Error interno: ' . $e->getMessage()], 500);
        }
    } else {
        respuesta_json(['status' => 'error', 'message' => 'Método no permitido.'], 405);
    }
}

/**
 * Acción: logout
 * Cerrar sesión del usuario
 */
function logout() {
    // Iniciar sesión si no está iniciada
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    // Destruir todas las variables de sesión
    session_unset();
    session_destroy();
    
    // Limpiar cookies de sesión
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time() - 3600, '/');
    }
    
    // Redirigir al login
    header('Location: /login');
    exit;
}

/**
 * Helper para responder JSON
 */
function respuesta_json($arr, $status = 200) {
    http_response_code($status);
    echo json_encode($arr);
    exit;
}
