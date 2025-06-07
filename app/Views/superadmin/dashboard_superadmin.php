<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// Seguridad: solo Superadmin (RolID = 1)
if (!isset($_SESSION['rol_id']) || $_SESSION['rol_id'] != 1) {
    header("Location: " . urlBase("Views/error/404.php"));
    exit();
}

require_once(__DIR__ . '/../../core/funciones.php'); // O la ruta real de tus helpers

$usuario = $_SESSION['usuario'] ?? [];
$nombre = $usuario['NombreUsuario'] ?? 'Superadmin';
$correo = $usuario['correo'] ?? '';
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Superadmin - DreamDress 3D</title>
    <link rel="stylesheet" href="<?= urlBase('public/css/custom.css') ?>">
</head>
<body>
    <header>
        <h1>Panel de Control: Superadmin 👑</h1>
        <p>Bienvenido, <b><?= htmlspecialchars($nombre) ?></b> | <?= htmlspecialchars($correo) ?></p>
        <a href="<?= urlBase('Views/auth/logout.php') ?>">Cerrar sesión</a>
    </header>

    <nav>
        <ul>
            <li><a href="<?= urlBase('backend/controllers/dashboard_superadmin.php') ?>">Inicio Superadmin</a></li>
            <li><a href="<?= urlBase('backend/controllers/usuarios.php') ?>">Gestión de usuarios</a></li>
            <li><a href="<?= urlBase('backend/controllers/roles.php') ?>">Roles y permisos</a></li>
            <li><a href="<?= urlBase('backend/controllers/logs.php') ?>">Logs del sistema</a></li>
            <li><a href="<?= urlBase('backend/controllers/estadisticas.php') ?>">Estadísticas</a></li>
        </ul>
    </nav>

    <main>
        <h2>Panel Principal</h2>
        <p>
            Desde aquí puedes administrar todo el sistema: usuarios, roles, logs, inventario y visualizar estadísticas generales.<br>
            Selecciona una opción del menú lateral para empezar.
        </p>
    </main>
</body>
</html>
