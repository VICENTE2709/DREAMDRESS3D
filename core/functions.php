<?php
/**
 * Funciones Utilitarias - DreamDress 3D
 * Colección de funciones procedurales para el sistema MVC
 * 
 * @author DreamDress 3D Team
 * @version 1.2 (Rutas absolutas inteligentes, listo para subdirectorio/virtualhost)
 */

// Verificación de seguridad
if (!defined('ROOT')) {
    die('Acceso no permitido');
}

/**
 * Renderizar una vista con datos opcionales
 */
function render($vista, $datos = []) {
    $archivo = APP_PATH . '/Views/' . $vista . '.php';
    if (file_exists($archivo)) {
        extract($datos);
        require $archivo;
    } else {
        http_response_code(404);
        echo "<h1>404 - Vista no encontrada</h1><p>No existe la vista: $vista</p>";
        exit;
    }
}

/**
 * Redirigir a una URL
 */
function redireccionar($url, $codigo = 302)
{
    http_response_code($codigo);
    header("Location: {$url}");
    exit;
}

/**
 * Helper universal de rutas absolutas
 * Detecta automáticamente si está en subdirectorio o virtualhost
 * 
 * @param string $ruta Ruta relativa (ej: assets/css/estilo.css)
 * @return string URL absoluta lista para HTML, JS, AJAX, imágenes, etc.
 */
function urlBase($ruta = '')
{
    // Directorio base (ej: /DreamDress3D/public o solo / si es virtualhost)
    $base = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
    $base = rtrim($base, '/');
    if ($base === '') $base = '/';

    // Evita doble barra
    $rutaFinal = $base . '/' . ltrim($ruta, '/');
    $rutaFinal = preg_replace('#/+#', '/', $rutaFinal); // Quita barras duplicadas al inicio

    return $rutaFinal;
}

/**
 * Sanitizar datos de entrada
 */
function sanitizar($datos)
{
    if (is_array($datos)) {
        return array_map('sanitizar', $datos);
    }
    return htmlspecialchars(trim($datos), ENT_QUOTES, 'UTF-8');
}

/**
 * Validar si una petición es AJAX
 */
function esAjax()
{
    return isset($_SERVER['HTTP_X_REQUESTED_WITH']) && 
           strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest';
}

/**
 * Responder con JSON
 */
function responderJson($datos, $codigo = 200)
{
    http_response_code($codigo);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * Obtener datos POST como JSON
 */
function obtenerJsonPost()
{
    $json = file_get_contents('php://input');
    return json_decode($json, true) ?? [];
}

/**
 * Validar método HTTP
 */
function validarMetodo($metodo)
{
    return $_SERVER['REQUEST_METHOD'] === strtoupper($metodo);
}

/**
 * Generar token CSRF
 */
function generarTokenCsrf()
{
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Validar token CSRF
 */
function validarTokenCsrf($token)
{
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Escribir log de errores personalizado
 */
function escribirLog($mensaje, $nivel = 'ERROR')
{
    $fecha = date('Y-m-d H:i:s');
    $log = "[{$fecha}] [{$nivel}] {$mensaje}" . PHP_EOL;
    $archivo_log = ROOT . '/logs/app.log';
    // Crear directorio de logs si no existe
    if (!is_dir(dirname($archivo_log))) {
        mkdir(dirname($archivo_log), 0755, true);
    }
    file_put_contents($archivo_log, $log, FILE_APPEND | LOCK_EX);
}

/**
 * Formatear fecha para mostrar
 */
function formatearFecha($fecha, $formato = 'd/m/Y H:i')
{
    return date($formato, strtotime($fecha));
}

/**
 * Validar email
 */
function validarEmail($email)
{
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Cargar una vista (alias de render para compatibilidad)
 */
function cargarVista($vista, $datos = [])
{
    render($vista, $datos);
}
