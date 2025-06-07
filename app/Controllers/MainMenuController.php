<?php
// app/Controllers/MainMenuController.php

require_once __DIR__ . '/../Models/CatalogoModel.php';
require_once __DIR__ . '/../../core/functions.php';

/**
 * Función principal para mostrar el menú principal con catálogo dinámico
 */
function index() {
    // Obtener todos los productos disponibles desde el modelo
    $productos = catalogo_obtener_todos();

    // Cargar la vista principal del menú pasando los productos
    render('main_menu/index', ['productos' => $productos]);
}
