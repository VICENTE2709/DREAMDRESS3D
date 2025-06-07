<?php
// app/Controllers/ProductoController.php

require_once(__DIR__ . '/../Models/ProductoModel.php');      // Para ABMs y API
require_once(__DIR__ . '/../Models/CatalogoModel.php');      // Para listar catálogo en main menu
require_once(__DIR__ . '/../../core/functions.php');         // Para render()

// --- 1. API: Operaciones ABM de producto (POST, responde JSON) ---
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_once(__DIR__ . '/../../core/token_helper.php');
    $usuarioID = validarToken(); // Valida token y retorna UsuarioID o termina con error 401

    $accion = $_POST['accion'] ?? '';

    switch ($accion) {
        case 'crear':
            $nombre      = $_POST['nombre']      ?? '';
            $descripcion = $_POST['descripcion'] ?? '';
            $precio      = $_POST['precio']      ?? 0;
            $tipoID      = $_POST['tipoID']      ?? 1;
            $imagen      = $_POST['imagen']      ?? '';
            $modulo_afectado = 'producto';
            $ip_acceso   = $_SERVER['REMOTE_ADDR'];
            $detalle     = $_POST['detalle']     ?? 'Alta de producto';
            $resultado   = crearProducto($nombre, $descripcion, $precio, $tipoID, $imagen, $usuarioID, $modulo_afectado, $ip_acceso, $detalle);
            echo json_encode($resultado);
            break;

        case 'editar':
            $productoID  = $_POST['productoID']  ?? 0;
            $nombre      = $_POST['nombre']      ?? '';
            $descripcion = $_POST['descripcion'] ?? '';
            $precio      = $_POST['precio']      ?? 0;
            $tipoID      = $_POST['tipoID']      ?? 1;
            $imagen      = $_POST['imagen']      ?? '';
            $modulo_afectado = 'producto';
            $ip_acceso   = $_SERVER['REMOTE_ADDR'];
            $detalle     = $_POST['detalle']     ?? 'Modificación de producto';
            $resultado   = editarProducto($productoID, $nombre, $descripcion, $precio, $tipoID, $imagen, $usuarioID, $modulo_afectado, $ip_acceso, $detalle);
            echo json_encode($resultado);
            break;

        case 'baja':
            $productoID  = $_POST['productoID']  ?? 0;
            $modulo_afectado = 'producto';
            $ip_acceso   = $_SERVER['REMOTE_ADDR'];
            $detalle     = $_POST['detalle']     ?? 'Baja lógica de producto';
            $resultado   = bajaLogicaProducto($productoID, $usuarioID, $modulo_afectado, $ip_acceso, $detalle);
            echo json_encode($resultado);
            break;

        case 'ver':
            $productoID  = $_POST['productoID']  ?? 0;
            $resultado   = obtenerProductoPorID($productoID);
            echo json_encode($resultado);
            break;

        case 'listar':
            $resultado   = listarProductosActivos();
            echo json_encode($resultado);
            break;

        default:
            echo json_encode(['status' => 'error', 'mensaje' => 'Acción no reconocida']);
    }
    // Termina ejecución para no cargar vista
    exit;
}

// --- 2. Acción procedural para mostrar el catálogo en el navegador (GET) ---
function listar() {
    $productos = catalogo_obtener_todos();
    render('producto/catalogo', ['productos' => $productos]);
}
