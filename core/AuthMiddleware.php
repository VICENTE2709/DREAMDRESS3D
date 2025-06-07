<?php
// core/AuthMiddleware.php

// Inicia sesión si no está activa
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Verifica si el usuario está autenticado.
 * Si no lo está, lo redirige al login.
 * Debes llamar a esta función en la parte superior de cada archivo privado.
 */
function require_auth() {
    // Importar helper si es necesario
    if (!function_exists('urlBase')) {
        require_once __DIR__ . '/functions.php';
    }

    if (!isset($_SESSION['usuario']) || empty($_SESSION['usuario']['UsuarioID'])) {
        // Redirigir a login usando ruta universal
        header("Location: " . urlBase('auth/login'));
        exit;
    }
}

/**
 * Devuelve los datos del usuario autenticado (o null si no hay).
 */
function current_user() {
    return isset($_SESSION['usuario']) ? $_SESSION['usuario'] : null;
}

/**
 * Para autenticación basada en token (opcional, si usas tokens en API).
 * Busca un token válido en $_SESSION o en una cookie.
 */
function is_authenticated_token() {
    return isset($_SESSION['token']) && !empty($_SESSION['token']);
}
