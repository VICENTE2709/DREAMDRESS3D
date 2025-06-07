<?php
/**
 * Configuración de Base de Datos - DreamDress 3D
 * Clase Database con patrón Singleton para conexión PDO a MySQL
 * ADAPTADO 100% para la estructura real de dreamdress3d.sql
 * 
 * TABLAS DE LA BD REAL:
 * - producto (ProductoID, Nombre, Descripcion, Precio, TipoID, Imagen)
 * - tipo_producto (TipoID, Nombre_tipo, Descripcion)
 * - catalogo (CatalogoID, ProductoID, Stock, Disponible)
 * - vestido (VestidoID, Codigo, ProductoID, Talla, Tipo_escote, Corte_falda, Manga, Cola, Color)
 * - producto_extra (GeneralID, Codigo, ProductoID, Color, Material, Tamano)
 * - usuario (UsuarioID, NombreUsuario, correo, Contrasena, Habilitado, RolID, RegistroID)
 * - cliente (ClienteID, UsuarioID)
 * - carrito (CarritoID, ClienteID, Fecha_creacion, Estado)
 * - carrito_item (ItemID, CarritoID, CatalogoID, Cantidad)
 * - pago (PagoID, CarritoID, Monto_total, Monto_pagado, Estado_pago, MetodoPagoID, TipoPagoID, Fecha_pago)
 * - registro (RegistroID, Nombres, Ap_paterno, Ap_materno, CI, Fecha_nacimiento, Telefono, Ciudad, Zona, Calle, Nro_puerta)
 * - rol (RolID, Rol_Nombre, Descripcion, Nivel_acceso)
 * 
 * @author DreamDress 3D Team
 * @version 2.0
 */

// Verificación de seguridad: evitar acceso directo por URL
if (!defined('ROOT')) {
    die('Acceso no permitido');
}

/**
 * Clase Database
 * Maneja la conexión a la base de datos MySQL usando PDO
 * Implementa el patrón Singleton para una sola instancia de conexión
 * 
 * CONFIGURACIÓN ESPECÍFICA PARA DREAMDRESS3D:
 * - Base de datos: dreamdress3d (nombre exacto del archivo .sql importado)
 * - Charset: utf8mb4 (compatible con emojis y caracteres especiales)
 * - Collation: utf8mb4_general_ci (como está configurado en la BD real)
 */
class Database
{
    // Propiedades privadas para los datos de conexión
    private $host = '127.0.0.1';           // Host de Laragon/XAMPP
    private $dbname = 'dreamdress3d';      // NOMBRE EXACTO de la base de datos real
    private $username = 'root';            // Usuario por defecto de Laragon
    private $password = '';                // Contraseña vacía por defecto en Laragon
    private $charset = 'utf8mb4';          // Charset configurado en la BD real
    
    // Propiedad para almacenar la conexión PDO
    private $pdo;
    
    // Instancia estática para el patrón Singleton
    private static $instance = null;

    /**
     * Constructor privado - Patrón Singleton
     * Establece la conexión PDO con configuración optimizada
     * Compatible con la estructura de dreamdress3d.sql
     */
    private function __construct()
    {
        try {
            // Construcción del DSN (Data Source Name) para MySQL
            $dsn = "mysql:host={$this->host};dbname={$this->dbname};charset={$this->charset}";
            
            // Opciones optimizadas para PDO y compatible con la BD real
            $options = [
                // Modo de errores por excepción para mejor debugging
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                
                // Modo de fetch por defecto como array asociativo
                // Esto facilita el mapeo de campos: ProductoID => id, Nombre => nombre, etc.
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                
                // Desactivar emulación de prepared statements para mejor rendimiento
                // Importante para consultas complejas con JOINs (producto + tipo_producto + catalogo)
                PDO::ATTR_EMULATE_PREPARES   => false,
                
                // Conexión persistente para mejor rendimiento (opcional)
                PDO::ATTR_PERSISTENT         => true,
                
                // Timeout de conexión en segundos
                PDO::ATTR_TIMEOUT            => 30,
                
                // Configuración específica para MySQL
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_general_ci"
            ];
            
            // Establecer la conexión PDO
            $this->pdo = new PDO($dsn, $this->username, $this->password, $options);
            
            // Configuraciones adicionales para la BD real
            $this->pdo->exec("SET SESSION sql_mode='STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO'");
            $this->pdo->exec("SET SESSION time_zone = '+00:00'");
            
        } catch (PDOException $e) {
            // Capturar errores de conexión y mostrar mensaje controlado
            $error_message = "Error de conexión a dreamdress3d: " . $e->getMessage();
            
            // En desarrollo, mostrar detalles del error
            if (ini_get('display_errors')) {
                $error_details = [
                    'Error' => $e->getMessage(),
                    'Host' => $this->host,
                    'Database' => $this->dbname,
                    'Charset' => $this->charset,
                    'Código de Error' => $e->getCode()
                ];
                
                error_log("Error de conexión a dreamdress3d: " . print_r($error_details, true));
            } else {
                // En producción, registrar el error en logs sin detalles sensibles
                error_log("Error de conexión a base de datos - Timestamp: " . date('Y-m-d H:i:s'));
            }
            
            // Detener la ejecución con mensaje apropiado según el entorno
            if (ini_get('display_errors')) {
                die("
                    <div style='background:#f8d7da;color:#721c24;padding:20px;border:1px solid #f5c6cb;border-radius:5px;font-family:monospace;'>
                        <h3>Error de Conexión a DreamDress 3D</h3>
                        <p><strong>Base de datos:</strong> {$this->dbname}</p>
                        <p><strong>Host:</strong> {$this->host}</p>
                        <p><strong>Error:</strong> " . htmlspecialchars($e->getMessage()) . "</p>
                        <hr>
                        <p><strong>Verificar:</strong></p>
                        <ul>
                            <li>¿Está Laragon/XAMPP ejecutándose?</li>
                            <li>¿Se importó el archivo dreamdress3d.sql en phpMyAdmin?</li>
                            <li>¿La base de datos se llama exactamente 'dreamdress3d'?</li>
                            <li>¿Las credenciales MySQL son correctas?</li>
                        </ul>
                    </div>
                ");
            } else {
                die("Error: No se pudo conectar a la base de datos. Por favor, contacte al administrador.");
            }
        }
    }

    /**
     * Método estático para obtener la instancia única de la clase (Singleton)
     * 
     * @return PDO Instancia única de la conexión PDO a dreamdress3d
     */
    public static function connect()
    {
        // Si no existe una instancia, crear una nueva
        if (self::$instance === null) {
            self::$instance = new self();
        }
        
        // Retornar la conexión PDO
        return self::$instance->pdo;
    }

    /**
     * Prevenir la clonación del objeto (Singleton)
     */
    private function __clone() {}

    /**
     * Prevenir la deserialización del objeto (Singleton)
     */
    public function __wakeup()
    {
        throw new Exception("No se puede deserializar un Singleton.");
    }

    /**
     * Método para cerrar la conexión explícitamente si es necesario
     */
    public static function disconnect()
    {
        self::$instance = null;
    }

    /**
     * Método para verificar si la conexión está activa
     * Útil para debugging y health checks
     * 
     * @return bool True si la conexión está activa, false en caso contrario
     */
    public static function isConnected()
    {
        try {
            if (self::$instance !== null) {
                // Hacer una consulta simple para verificar la conexión
                self::$instance->pdo->query('SELECT 1');
                return true;
            }
            return false;
        } catch (PDOException $e) {
            return false;
        }
    }

    /**
     * Método para obtener información de la base de datos
     * Útil para debugging y verificación de la estructura
     * 
     * @return array Información de la BD
     */
    public static function getDatabaseInfo()
    {
        try {
            if (self::$instance === null) {
                self::connect();
            }
            
            $pdo = self::$instance->pdo;
            
            // Obtener información básica
            $info = [
                'database_name' => '',
                'charset' => '',
                'collation' => '',
                'tables' => [],
                'version' => ''
            ];
            
            // Nombre de la base de datos
            $stmt = $pdo->query("SELECT DATABASE() as db_name");
            $result = $stmt->fetch();
            $info['database_name'] = $result['db_name'];
            
            // Versión de MySQL
            $stmt = $pdo->query("SELECT VERSION() as version");
            $result = $stmt->fetch();
            $info['version'] = $result['version'];
            
            // Charset y collation
            $stmt = $pdo->query("SELECT @@character_set_database as charset, @@collation_database as collation");
            $result = $stmt->fetch();
            $info['charset'] = $result['charset'];
            $info['collation'] = $result['collation'];
            
            // Lista de tablas
            $stmt = $pdo->query("SHOW TABLES");
            while ($row = $stmt->fetch(PDO::FETCH_NUM)) {
                $table_name = $row[0];
                
                // Obtener número de registros por tabla
                $count_stmt = $pdo->query("SELECT COUNT(*) as count FROM `{$table_name}`");
                $count_result = $count_stmt->fetch();
                
                $info['tables'][] = [
                    'name' => $table_name,
                    'records' => $count_result['count']
                ];
            }
            
            return $info;
            
        } catch (PDOException $e) {
            return [
                'error' => 'No se pudo obtener información de la base de datos',
                'message' => $e->getMessage()
            ];
        }
    }

    /**
     * Método para verificar que las tablas principales existen
     * Verificación específica para la estructura de dreamdress3d
     * 
     * @return array Resultado de la verificación
     */
    public static function verifyDreamDressStructure()
    {
        try {
            if (self::$instance === null) {
                self::connect();
            }
            
            $pdo = self::$instance->pdo;
            
            // Tablas principales que debe tener la BD real
            $required_tables = [
                'producto',
                'tipo_producto', 
                'catalogo',
                'vestido',
                'producto_extra',
                'usuario',
                'cliente',
                'carrito',
                'carrito_item',
                'pago',
                'registro',
                'rol'
            ];
            
            $verification = [
                'database_exists' => true,
                'tables_found' => [],
                'tables_missing' => [],
                'all_tables_exist' => true
            ];
            
            foreach ($required_tables as $table) {
                $stmt = $pdo->prepare("SHOW TABLES LIKE ?");
                $stmt->execute([$table]);
                
                if ($stmt->rowCount() > 0) {
                    $verification['tables_found'][] = $table;
                } else {
                    $verification['tables_missing'][] = $table;
                    $verification['all_tables_exist'] = false;
                }
            }
            
            return $verification;
            
        } catch (PDOException $e) {
            return [
                'database_exists' => false,
                'error' => $e->getMessage(),
                'all_tables_exist' => false
            ];
        }
    }
} 

/**
 * Función utilitaria para verificar la conexión (solo para debugging)
 * NO usar en producción
 */
if (defined('DEBUG_DB') && DEBUG_DB === true) {
    function debugDatabaseConnection() {
        echo "<h3>Debug: Información de la Base de Datos DreamDress 3D</h3>";
        
        if (Database::isConnected()) {
            echo "<p style='color:green;'>✓ Conexión exitosa a dreamdress3d</p>";
            
            $info = Database::getDatabaseInfo();
            if (!isset($info['error'])) {
                echo "<ul>";
                echo "<li><strong>Base de datos:</strong> " . htmlspecialchars($info['database_name']) . "</li>";
                echo "<li><strong>Versión MySQL:</strong> " . htmlspecialchars($info['version']) . "</li>";
                echo "<li><strong>Charset:</strong> " . htmlspecialchars($info['charset']) . "</li>";
                echo "<li><strong>Collation:</strong> " . htmlspecialchars($info['collation']) . "</li>";
                echo "<li><strong>Tablas encontradas:</strong> " . count($info['tables']) . "</li>";
                echo "</ul>";
                
                echo "<h4>Tablas con registros:</h4>";
                echo "<ul>";
                foreach ($info['tables'] as $table) {
                    echo "<li>{$table['name']}: {$table['records']} registros</li>";
                }
                echo "</ul>";
            }
            
            $verification = Database::verifyDreamDressStructure();
            if ($verification['all_tables_exist']) {
                echo "<p style='color:green;'>✓ Todas las tablas principales de DreamDress 3D están presentes</p>";
            } else {
                echo "<p style='color:red;'>✗ Faltan tablas: " . implode(', ', $verification['tables_missing']) . "</p>";
            }
            
        } else {
            echo "<p style='color:red;'>✗ Error de conexión</p>";
        }
    }
} 