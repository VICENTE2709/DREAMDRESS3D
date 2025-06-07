<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>500 - Error Interno</title></head>
<body>
    <h1>Error 500</h1>
    <p>Ha ocurrido un error en el servidor. Intenta más tarde.</p>
    <?php if (isset($error)) echo "<pre>$error</pre>"; ?>
</body>
</html>
