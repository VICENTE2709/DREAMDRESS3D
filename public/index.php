<?php
/**
 * Front Controller - DreamDress 3D
 * Maneja enrutamiento amigable y procedural (MVC)
 */

// Definiciones de paths absolutas
define('ROOT', dirname(__DIR__));
define('PUBLIC_PATH', __DIR__);
define('APP_PATH', ROOT . '/app');
define('CORE_PATH', ROOT . '/core');
define('CONFIG_PATH', ROOT . '/config');

// Errores en modo desarrollo (¡comenta en producción!)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Carga helpers y config
require_once CONFIG_PATH . '/database.php';
require_once CORE_PATH . '/functions.php';

// Mapa de rutas amigables
$rutas_amigables = [
    ''           => ['producto', 'listar'],      // Home
    'inicio'     => ['producto', 'listar'],
    'catalogo'   => ['producto', 'listar'],
    'productos'  => ['producto', 'listar'],
    'login'      => ['auth', 'login'],
    'registro'   => ['auth', 'registro'],
    'logout'     => ['auth', 'logout'],

    // Rutas extra
    'panel'      => ['cliente', 'dashboard'],
    // 'carrito'  => ['carrito', 'ver'],
    // ...
];

// Procesar ruta solicitada
$url = $_GET['route'] ?? '';
$url = rtrim($url, '/');
$url = filter_var($url, FILTER_SANITIZE_URL);

// Si existe en rutas amigables, mapear a controlador/acción
if (isset($rutas_amigables[$url])) {
    list($controlador, $accion) = $rutas_amigables[$url];
    $parametros = [];
} else {
    // Formato clásico: controlador/accion/param
    $url_partes = $url ? explode('/', $url) : [];
    $controlador = strtolower($url_partes[0] ?? 'producto');
    $accion = strtolower($url_partes[1] ?? 'listar');
    $parametros = (count($url_partes) > 2) ? array_slice($url_partes, 2) : [];
}

// Archivo real del controlador
$archivo_controlador = APP_PATH . '/Controllers/' . ucfirst($controlador) . 'Controller.php';

// Validar existencia
if (!file_exists($archivo_controlador)) {
    http_response_code(404);
    cargarVista('error/404', [
        'mensaje' => 'Página no encontrada',
        'controlador' => $controlador,
        'accion' => $accion
    ]);
    exit;
}

require_once $archivo_controlador;

// Nomenclatura: primero controlador_accion, luego solo acción, luego index
$nombre_funcion = $controlador . '_' . $accion;
if (!function_exists($nombre_funcion)) {
    $nombre_funcion = $accion;
    if (!function_exists($nombre_funcion)) {
        if ($accion !== 'index' && function_exists('index')) {
            $nombre_funcion = 'index';
        } else {
            http_response_code(404);
            cargarVista('error/404', [
                'mensaje' => "Acción '$accion' no encontrada en controlador '$controlador'",
                'controlador' => $controlador,
                'accion' => $accion
            ]);
            exit;
        }
    }
}

// Ejecutar acción
try {
    call_user_func_array($nombre_funcion, $parametros);
} catch (Exception $e) {
    http_response_code(500);
    cargarVista('error/500', [
        'mensaje' => 'Error interno del servidor',
        'error' => $e->getMessage()
    ]);
}
