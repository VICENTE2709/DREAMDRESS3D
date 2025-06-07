<?php
// app/Controllers/ClienteController.php

require_once(__DIR__ . '/../../core/AuthMiddleware.php');
require_once(__DIR__ . '/../Models/ClienteModel.php');
require_once(__DIR__ . '/../../core/functions.php');

// Cambia el nombre de la función:
function dashboard() {
    $usuario = current_user();

    if (!$usuario || $usuario['RolID'] != 5) {
        header("Location: /login");
        exit;
    }

    $cliente = obtenerDatosCliente($usuario['UsuarioID']);

    render('cliente/dashboard', [
        'usuario' => $usuario,
        'cliente' => $cliente
    ]);
}
