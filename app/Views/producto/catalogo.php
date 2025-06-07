<?php
// Evitar warning si $user no viene definido desde el controlador
$user = $user ?? null;
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Catálogo de Productos</title>
    <!-- Hojas de estilo -->
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/normalize.css') ?>" />
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/skeleton.css') ?>" />
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/custom.css') ?>" />
</head>
<body>
<header class="head">
    <div class="logo">
        <a href="<?= urlBase('catalogo') ?>">DreamDress 3D</a>
    </div>
    <nav class="navbar">
        <a href="<?= urlBase('catalogo') ?>">Home</a>
        <a href="#">Categorías</a>
        <a href="#">Editor</a>
        <a href="#">Reservas</a>
    </nav>
</header>

<div class="container">
    <h1>Catálogo de Productos</h1>
    <div class="row">
        <?php if (!empty($productos)): ?>
            <?php foreach ($productos as $producto): ?>
                <div class="four columns">
                    <div class="card">
                        <img src="<?= urlBase('assets/img/main_menu/' . htmlspecialchars($producto['Imagen'])) ?>"
                             alt="<?= htmlspecialchars($producto['Nombre']) ?>"
                             class="imagen-curso u-full-width" />
                        <div class="info-card">
                            <h4><?= htmlspecialchars($producto['Nombre']) ?></h4>
                            <p><?= htmlspecialchars($producto['Descripcion']) ?></p>
                            <p class="precio"><?= number_format($producto['Precio'], 2, ',', '.') ?> Bs</p>
                            <!-- Botón AGREGAR, con control según usuario -->
                            <a
                              href="#"
                              class="u-full-width button-primary button input agregar-carrito"
                              data-id="<?= $producto['ProductoID'] ?>"
                              <?= (!$user) ? 'data-requiere-login="1"' : '' ?>
                            >AGREGAR</a>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php else: ?>
            <p>No hay productos disponibles en este momento.</p>
        <?php endif; ?>
    </div>
</div>

<script>
    // Usamos PHP para definir la ruta base universal
    const BASE_URL = "<?= urlBase() ?>";

    document.addEventListener('DOMContentLoaded', function() {
        const agregarBtns = document.querySelectorAll('.agregar-carrito');

        agregarBtns.forEach(btn => {
            btn.addEventListener('click', function(e) {
                // ¿Requiere login?
                if (btn.dataset.requiereLogin === "1") {
                    e.preventDefault();
                    if (confirm("Para agregar productos al carrito debes iniciar sesión o registrarte. ¿Deseas hacerlo ahora?")) {
                        window.location.href = BASE_URL + "login";
                    }
                    return;
                }
                // Aquí va tu lógica normal para agregar al carrito (AJAX o submit)
                // Ejemplo:
                // agregarProductoAlCarrito(btn.dataset.id);
            });
        });
    });
</script>
</body>
</html>
