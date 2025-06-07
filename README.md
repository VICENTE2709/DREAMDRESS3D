# DreamDress 3D 🎨

Sistema de gestión y catálogo virtual para una tienda de vestidos y productos de moda.

## 📋 Descripción

DreamDress 3D es una plataforma web desarrollada para la gestión y visualización de productos de moda, especialmente vestidos y accesorios. El sistema permite a los usuarios explorar el catálogo, gestionar carritos de compra y realizar pedidos, mientras que los administradores pueden gestionar productos, usuarios y ventas.

## 🚀 Características Principales

- Catálogo virtual de productos de moda
- Sistema de gestión de usuarios y roles
- Carrito de compras
- Gestión de inventario
- Sistema de pagos
- Panel de administración
- Gestión de clientes y pedidos

## 🛠️ Requisitos Técnicos

- PHP 7.4 o superior
- MySQL 5.7 o superior
- Servidor web (Apache/Nginx)
- Laragon/XAMPP (entorno de desarrollo recomendado)
- Navegador web moderno

## 📦 Estructura del Proyecto

```
DreamDress3D/
├── app/                    # Lógica de la aplicación
│   ├── Controllers/       # Controladores
│   ├── Models/           # Modelos
│   └── Views/            # Vistas
├── config/                # Configuraciones
├── core/                  # Núcleo del sistema
├── logs/                  # Registros del sistema
├── public/               # Archivos públicos
└── utils/                # Utilidades
```

## 🗄️ Base de Datos

El sistema utiliza una base de datos MySQL con las siguientes tablas principales:

- `producto`: Información general de productos
- `tipo_producto`: Categorías de productos
- `catalogo`: Gestión de inventario
- `vestido`: Especificaciones de vestidos
- `producto_extra`: Productos adicionales
- `usuario`: Gestión de usuarios
- `cliente`: Información de clientes
- `carrito`: Gestión de carritos
- `carrito_item`: Items en carritos
- `pago`: Registro de pagos
- `registro`: Datos de registro
- `rol`: Roles de usuario

## 🚀 Instalación

1. Clonar el repositorio:
   ```bash
   git clone [URL_DEL_REPOSITORIO]
   ```

2. Configurar el entorno:
   - Instalar Laragon/XAMPP
   - Importar la base de datos usando el archivo `dreamdress3d.sql`
   - Configurar el archivo `config/database.php` según el entorno

3. Configurar el servidor web:
   - Apuntar el DocumentRoot a la carpeta `public/`
   - Asegurar que mod_rewrite está habilitado (Apache)

4. Permisos de archivos:
   - Asegurar que la carpeta `logs/` tiene permisos de escritura
   - Configurar permisos adecuados para archivos de carga

## 🔧 Configuración

### Base de Datos
Editar `config/database.php` con los datos de conexión:
```php
private $host = '127.0.0.1';
private $dbname = 'dreamdress3d';
private $username = 'root';
private $password = '';
```

### Entorno de Desarrollo
- Habilitar la visualización de errores en desarrollo
- Configurar las rutas base en `utils/urlBase.php`

## 👥 Roles de Usuario

- Super Administrador: Acceso total al sistema
- Administrador: Gestión de productos y pedidos
- Cliente: Acceso al catálogo y compras
- Usuario: Acceso básico

## 🔒 Seguridad

- Implementación de contraseñas hasheadas (BCRYPT)
- Protección contra SQL Injection usando PDO
- Sanitización de entradas
- Control de acceso basado en roles
- Protección contra acceso directo a archivos

## 📝 Logs y Monitoreo

- Registro de errores en `logs/`
- Monitoreo de conexiones a base de datos
- Registro de actividades de usuarios
- Verificación de estructura de base de datos

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

## ✨ Créditos

Desarrollado por el equipo DreamDress 3D

## 📞 Soporte

Para soporte, por favor contactar al equipo de desarrollo o abrir un issue en el repositorio. 