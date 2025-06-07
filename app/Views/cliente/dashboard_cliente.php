
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Cliente - DreamDress 3D</title>
    <link rel="stylesheet" href="<?= urlBase('assets/css/global.css') ?>">
</head>
<body>
    <h1>Bienvenido(a), <?= htmlspecialchars($cliente['Nombres'] . ' ' . $cliente['Ap_paterno']) ?>!</h1>

    <section>
        <p><strong>Usuario:</strong> <?= htmlspecialchars($usuario['NombreUsuario']) ?></p>
        <p><strong>Email:</strong> <?= htmlspecialchars($usuario['correo']) ?></p>
    </section>

    <nav>
        <ul>
            <li><a href="<?= urlBase('perfil') ?>">Ver perfil</a></li>
            <li><a href="<?= urlBase('carrito') ?>">Ver mi carrito</a></li>
            <li><a href="<?= urlBase('historial') ?>">Historial de compras</a></li>
            <li><a href="<?= urlBase('logout') ?>">Cerrar sesión</a></li>
        </ul>
    </nav>
</body>
</html>
