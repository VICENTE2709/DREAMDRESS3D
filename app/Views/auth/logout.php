<?php
require_once(__DIR__ . '/../../core/token_helper.php');

$headers = function_exists('getallheaders') ? getallheaders() : [];
if (!isset($headers['Authorization'])) {
    echo json_encode(['status'=>'error', 'message'=>'Token requerido.']); exit;
}
$auth = $headers['Authorization'];
if (strpos($auth, 'Bearer ') !== 0) {
    echo json_encode(['status'=>'error', 'message'=>'Formato de token inválido.']); exit;
}
$token = substr($auth, 7);

if (cerrarSesion($token)) {
    echo json_encode(['status'=>'success', 'message'=>'Sesión cerrada correctamente.']);
} else {
    echo json_encode(['status'=>'error', 'message'=>'No se pudo cerrar sesión o token ya está inactivo.']);
}
?>
