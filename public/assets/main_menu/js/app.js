// public/assets/main_menu/js/app.js

// Variables de referencia al DOM
const carrito = document.querySelector('#carrito');
const listaCursos = document.querySelector('#lista-cursos'); // Este ID deberías cambiarlo por el de tu catálogo real si es necesario
const contenedorCarrito = document.querySelector('#lista-carrito tbody');
const vaciarCarritoBtn = document.querySelector('#vaciar-carrito'); 
let articulosCarrito = [];

// Inicialización de eventos y carga inicial del carrito
cargarEventListeners();
cargarCarritoDesdeBackend();

function cargarEventListeners() {
    if (listaCursos) {
        listaCursos.addEventListener('click', agregarCurso);
    }
    if (carrito) {
        carrito.addEventListener('click', eliminarCurso);
    }
    if (vaciarCarritoBtn) {
        vaciarCarritoBtn.addEventListener('click', vaciarCarrito);
    }
}

// Cargar carrito del backend al iniciar
async function cargarCarritoDesdeBackend() {
    const token = localStorage.getItem('token');
    const usuario_id = localStorage.getItem('usuario_id');
    if (!token || !usuario_id) return; // No está logueado

    try {
        // Ruta amigable y profesional
        const res = await fetch(`/api/resumen_carrito?usuario_id=${usuario_id}`, {
            headers: { 'Authorization': 'Bearer ' + token }
        });
        const data = await res.json();
        if (data.status === 'success') {
            articulosCarrito = data.productos.map(p => ({
                id: p.ProductoID,
                titulo: p.Nombre,
                imagen: `/assets/img/main_menu/${p.Imagen}`,
                precio: p.Precio,
                cantidad: p.Cantidad
            }));
            carritoHTML();
        } else {
            console.warn('No se pudo cargar carrito:', data.message);
        }
    } catch (error) {
        console.error('Error cargando carrito:', error);
    }
}

// Agregar curso/producto al carrito
async function agregarCurso(e) {
    e.preventDefault();

    if (!e.target.classList.contains('agregar-carrito')) return;

    // Aquí NO mostramos alert ni confirm, pues el control de login ya lo hace catálogo.php
    const token = localStorage.getItem('token');
    const usuario_id = localStorage.getItem('usuario_id');
    if (!token || !usuario_id) {
        // Silencioso: control de login ya se hace en catálogo.php con confirm.
        return;
    }

    const card = e.target.closest('.card');
    const infoProducto = {
        id: e.target.getAttribute('data-id'),
        titulo: card.querySelector('h4').textContent,
        imagen: card.querySelector('img').src,
        precio: card.querySelector('.precio')?.textContent,
        cantidad: 1
    };

    // Sumar cantidad si ya existe
    if (articulosCarrito.some(p => p.id === infoProducto.id)) {
        articulosCarrito = articulosCarrito.map(p => 
            p.id === infoProducto.id ? { ...p, cantidad: p.cantidad + 1 } : p
        );
    } else {
        articulosCarrito.push(infoProducto);
    }

    carritoHTML();

    // Enviar actualización al backend
    try {
        const response = await fetch('/api/guardar_carrito', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
            },
            body: JSON.stringify({
                usuario_id,
                productos: articulosCarrito.map(p => ({ ProductoID: p.id, Cantidad: p.cantidad }))
            })
        });
        const result = await response.json();
        if (result.status !== 'success') {
            alert('Error al guardar carrito: ' + (result.message || 'Error desconocido'));
        }
    } catch (error) {
        console.error('Error enviando carrito:', error);
    }
}

// Eliminar curso/producto del carrito
async function eliminarCurso(e) {
    e.preventDefault();
    if (!e.target.classList.contains('borrar-curso')) return;

    const productoId = e.target.getAttribute('data-id');
    articulosCarrito = articulosCarrito.filter(p => p.id !== productoId);
    carritoHTML();

    // Opcional: sincronizar con backend aquí si lo deseas
}

// Renderizar el HTML del carrito
function carritoHTML() {
    vaciarCarrito();

    articulosCarrito.forEach(producto => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td><img src="${producto.imagen}" width="100"></td>
            <td>${producto.titulo}</td>
            <td>${producto.precio}</td>
            <td>${producto.cantidad}</td>
            <td><a href="#" class="borrar-curso" data-id="${producto.id}">X</a></td>
        `;
        contenedorCarrito.appendChild(row);
    });
}

// Vaciar visualmente el carrito en la vista
function vaciarCarrito() {
    while (contenedorCarrito && contenedorCarrito.firstChild) {
        contenedorCarrito.removeChild(contenedorCarrito.firstChild);
    }
}
