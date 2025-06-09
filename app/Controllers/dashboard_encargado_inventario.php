<?php
require_once(__DIR__ . '/../../core/AuthMiddleware.php');
require_once(__DIR__ . '/../../core/functions.php');

require_auth();

$usuario = current_user();
if (!$usuario || !in_array($usuario['RolID'], [3, 1])) {
    header('Location: ' . urlBase('login'));
    exit;
}

render('encargado_inventario/dashboard_encargado_inventario', [
    'usuario' => $usuario
]);
