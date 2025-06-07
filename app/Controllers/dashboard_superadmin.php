<?php
// controllers/dashboard_superadmin.php

// Seguridad: evita acceso directo a config/database.php
define('ROOT', true);

require_once(__DIR__ . '/../config/database.php');                // Conexión BD
require_once(__DIR__ . '/funciones/func_usuarios.php');          // Funciones de usuarios
require_once(__DIR__ . '/../utils/urlBase.php');                 // Función rutas absolutas

// Sanitización rápida para entradas (puedes mejorar con filtros específicos)
function limpiar($dato) {
    return htmlspecialchars(trim($dato), ENT_QUOTES, 'UTF-8');
}

// Detectar la acción según GET (listar/agregar/editar/eliminar)
$accion = isset($_GET['accion']) ? $_GET['accion'] : 'listar';

switch ($accion) {

    // === AGREGAR USUARIO ===
    case 'agregar':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $nombreUsuario = limpiar($_POST['nombreUsuario']);
            $correo = limpiar($_POST['correo']);
            $contrasena = password_hash($_POST['contrasena'], PASSWORD_BCRYPT); // Hash seguro
            $rolID = isset($_POST['rolID']) ? (int)$_POST['rolID'] : 5; // Cliente por defecto
            $registroID = isset($_POST['registroID']) ? (int)$_POST['registroID'] : null; // Depende tu lógica

            // Puedes validar que no esté vacío, emails únicos, etc.
            agregarUsuario($nombreUsuario, $correo, $contrasena, $rolID, $registroID);

            // Redirecciona seguro
            header("Location: " . urlBase() . "controllers/dashboard_superadmin.php?accion=listar&msg=agregado");
            exit;
        }
        // Muestra el formulario de agregar
        require(__DIR__ . '/../views/usuarios/form_agregar.php');
        break;

    // === EDITAR USUARIO ===
    case 'editar':
        $usuarioID = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $nombreUsuario = limpiar($_POST['nombreUsuario']);
            $correo = limpiar($_POST['correo']);
            $rolID = (int)$_POST['rolID'];
            editarUsuario($usuarioID, $nombreUsuario, $correo, $rolID);

            header("Location: " . urlBase() . "controllers/dashboard_superadmin.php?accion=listar&msg=editado");
            exit;
        }
        // Buscar usuario actual para precargar el form
        $usuarios = listarUsuarios();
        $usuario = null;
        foreach ($usuarios as $u) {
            if ($u['UsuarioID'] == $usuarioID) {
                $usuario = $u;
                break;
            }
        }
        if (!$usuario) {
            header("Location: " . urlBase() . "controllers/dashboard_superadmin.php?accion=listar&msg=error_no_encontrado");
            exit;
        }
        require(__DIR__ . '/../views/usuarios/form_editar.php');
        break;

    // === ELIMINAR USUARIO ===
    case 'eliminar':
        $usuarioID = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if ($usuarioID > 0) {
            eliminarUsuario($usuarioID);
        }
        header("Location: " . urlBase() . "controllers/dashboard_superadmin.php?accion=listar&msg=eliminado");
        exit;

    // === LISTAR USUARIOS (default) ===
    default:
        $usuarios = listarUsuarios();
        require(__DIR__ . '/../views/usuarios/listar.php');
        break;
}
?>
