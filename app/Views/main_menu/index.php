<?php
// app/Views/main_menu/index.php

// $productos viene del controlador y es un array con los productos del catálogo
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>DreamDress 3D - Inicio</title>

    <!-- CSS externos, rutas absolutas -->
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/normalize.css') ?>" />
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/skeleton.css') ?>" />
    <link rel="stylesheet" href="<?= urlBase('assets/main_menu/css/custom.css') ?>" />
</head>
<body>
    <header id="header" class="header">
        <nav class="navbar container">
            <a href="<?= urlBase('auth/login') ?>">Usuario</a>
            <a href="<?= urlBase() ?>" aria-current="page">Home</a>
            <a href="<?= urlBase('producto/listar') ?>">Categorías</a>
            <a href="<?= urlBase('editor') ?>">Editor</a>
            <a href="<?= urlBase('reservas') ?>">Reservas</a>
        </nav>
    </header>

    <main class="container" role="main">
        <section id="hero" class="row contenido-hero">
            <div class="six columns">
                <h2>CREA TU NUEVO DISEÑO</h2>
                <p>Directamente aquí</p>
                <form action="#" id="busqueda" method="post" class="formulario" role="search" aria-label="Buscar vestido">
                    <button type="submit" class="btn-register button button-primary">EMPEZAR</button>
                </form>
            </div>
        </section>

        <section class="barra row">
            <div class="four columns icono icono1">
                <a href="<?= urlBase('info/info') ?>" class="u-full-width info-block-link" aria-label="Misión">
                    <h3>MISIÓN</h3>
                    <p>Brindar a cada novia una experiencia inolvidable.</p>
                </a>
            </div>
            <div class="four columns icono icono2">
                <a href="<?= urlBase('info/info') ?>" class="u-full-width info-block-link" aria-label="Visión">
                    <h3>VISIÓN</h3>
                    <p>Ser la tienda online de referencia en vestidos de boda.</p>
                </a>
            </div>
            <div class="four columns icono icono3">
                <a href="<?= urlBase('info/info') ?>" class="u-full-width info-block-link" aria-label="Valores">
                    <h3>VALORES</h3>
                    <p>Cuidamos cada diseño para resaltar la belleza de cada novia.</p>
                </a>
            </div>
        </section>

        <section id="lista-cursos" class="container">
            <h2 id="encabezado" class="encabezado">Novedades</h2>
            <div class="row">
                <?php if (!empty($productos)): ?>
                    <?php foreach ($productos as $producto): ?>
                        <div class="four columns">
                            <div class="card">
                                <img src="<?= urlBase('assets/main_menu/img/' . htmlspecialchars($producto['Imagen'])) ?>" class="imagen-curso u-full-width" alt="<?= htmlspecialchars($producto['Nombre']) ?>" />
                                <div class="info-card">
                                    <h4><?= htmlspecialchars(strtoupper($producto['Nombre'])) ?></h4>
                                    <p><?= htmlspecialchars($producto['Descripcion']) ?></p>
                                    <p class="precio"><?= number_format($producto['Precio'], 2) ?> Bs</p>
                                    <a href="#" class="u-full-width button-primary button input agregar-carrito" data-id="<?= $producto['ProductoID'] ?>">AGREGAR</a>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                <?php else: ?>
                    <p>No hay productos disponibles en este momento.</p>
                <?php endif; ?>
            </div>
        </section>
    </main>

    <aside class="submenu">
        <img src="<?= urlBase('assets/main_menu/img/cart.png') ?>" id="img-carrito" alt="Carrito de Compras" />
        <div id="carrito" aria-live="polite" aria-label="Carrito de compras">
            <table id="lista-carrito" class="u-full-width" role="table">
                <thead>
                    <tr>
                        <th scope="col">Imagen</th>
                        <th scope="col">Nombre</th>
                        <th scope="col">Precio</th>
                        <th scope="col">Cantidad</th>
                        <th scope="col">Acción</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
            <button id="vaciar-carrito" class="button u-full-width" aria-label="Vaciar carrito">Vaciar Carrito</button>
            <a href="<?= urlBase('compra/seleccion_pago') ?>" id="checkout-btn" class="button u-full-width">Proceder al Pago</a>
        </div>
    </aside>

    <footer id="footer" class="footer container">
        <div class="row">
            <nav id="principal" class="four columns menu" aria-label="Menú principal">
                <a class="enlace" href="#">Dónde encontrarnos</a>
                <a class="enlace" href="#">Sobre Nosotros</a>
                <a class="enlace" href="#">Instagram</a>
                <a class="enlace" href="#">Soporte</a>
                <a class="enlace" href="#">Temas</a>
            </nav>
            <nav id="secundaria" class="four columns menu" aria-label="Menú secundario">
                <a class="enlace" href="#">Whatsapp</a>
                <a class="enlace" href="#">Empleo</a>
                <a class="enlace" href="#">Blog</a>
            </nav>
        </div>
    </footer>

    <!-- JS con rutas absolutas -->
    <script src="<?= urlBase('assets/main_menu/js/app.js') ?>"></script>
</body>
</html>
