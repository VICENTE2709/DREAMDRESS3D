<?php
require_once(__DIR__ . '/../../core/AuthMiddleware.php');
require_once(__DIR__ . '/../../core/functions.php');
require_once(__DIR__ . '/../Models/ClienteModel.php');

require_auth();

$usuario = current_user();
if (!$usuario || !in_array($usuario['RolID'], [5, 1])) {
    header('Location: ' . urlBase('login'));
    exit;
}

$cliente = obtenerDatosCliente($usuario['UsuarioID']);

render('cliente/dashboard_cliente', [
    'usuario' => $usuario,
    'cliente' => $cliente
]);
