console.log("✅ registro.js cargado correctamente");

// ✅ Mostrar mensajes bonitos en la página (igual que en login)
function mostrarMensaje(texto, tipo = 'error') {
    let mensaje = document.getElementById('mensaje');
    if (!mensaje) {
        mensaje = document.createElement('div');
        mensaje.id = 'mensaje';
        mensaje.style.padding = '10px';
        mensaje.style.margin = '10px 0';
        mensaje.style.borderRadius = '5px';
        mensaje.style.fontWeight = 'bold';
        mensaje.style.textAlign = 'center';
        mensaje.style.transition = 'all 0.5s ease';
        document.getElementById('sign-Up').prepend(mensaje);
    }

    mensaje.className = '';
    mensaje.style.display = 'block';
    mensaje.style.opacity = '1';

    mensaje.style.backgroundColor = tipo === 'success' ? '#d4edda' : '#f8d7da';
    mensaje.style.color = tipo === 'success' ? '#155724' : '#721c24';
    mensaje.style.border = tipo === 'success'
        ? '1px solid #c3e6cb'
        : '1px solid #f5c6cb';

    mensaje.innerHTML = texto;

    setTimeout(() => {
        mensaje.style.opacity = '0';
        setTimeout(() => {
            mensaje.style.display = 'none';
        }, 500);
    }, 4000);
}

// ✅ Validaciones individuales reutilizables
function tieneSecuenciasInvalidas(texto) {
    return /[aeiou]{3}/i.test(texto) || /[^aeiou\s\d]{4}/i.test(texto);
}

function esFechaValida(fecha) {
    const hoy = new Date();
    const nacimiento = new Date(fecha);
    const edad = hoy.getFullYear() - nacimiento.getFullYear();
    return !isNaN(nacimiento.getTime()) && nacimiento <= hoy && edad <= 90;
}

function esTelefonoValido(telefono) {
    return /^[67]\d{7}$/.test(telefono);
}

function esCorreoValido(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function esUsuarioValido(usuario) {
    return usuario.length >= 6 && usuario.length <= 15;
}

function esPasswordFuerte(password) {
    return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/.test(password);
}

function esNumeroPuertaValido(nro) {
    return /^\d{1,4}$/.test(nro);
}

function esCiudadValida(ciudad) {
    const ciudades = ['LA PAZ', 'EL ALTO', 'COCHABAMBA', 'SANTA CRUZ', 'TARIJA', 'BENI', 'PANDO', 'ORURO', 'POTOSI', 'CHUQUISACA'];
    return ciudades.includes(ciudad.toUpperCase());
}

// DESHABILITAR este archivo ya que la funcionalidad está en login.js
// Este archivo está causando conflictos
console.warn("⚠️ registro.js está deshabilitado. La funcionalidad de registro está en login.js");

// Comentar todo el event listener para evitar conflictos
/*
document.getElementById('sign-Up').addEventListener('submit', async function(event) {
    event.preventDefault();
    // ... resto del código comentado para evitar conflictos
});
*/