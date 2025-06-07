<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, shrink-to-fit=no" />
    <title>Login | DreamDress 3D</title>
    <!-- Estilo principal del login (rutas absolutas) -->
    <link rel="stylesheet" href="<?= urlBase('assets/auth/logins.css') ?>" />
</head>
<body>

<div class="container" id="container">
    <div class="forms-container">
        <div class="forms" id="forms">
            <!-- Formulario LOGIN -->
            <form action="" id="sign-In">
                <h2>LOGIN</h2>
                <p>No tienes una cuenta? <a href="#" id="link-sign-in">Regístrate</a></p>
                <div class="input-container">
                    <label for="email">Ingresa tu G-mail o Nombre de Usuario.</label>
                    <input id="email" type="text" placeholder="Correo o Nombre de Usuario" />
                    <small id="errorEmail" class="error-message">Por favor, ingresa tu correo o nombre de usuario.</small>
                </div>
                <div class="input-container">
                    <div class="forget">
                        <label for="password">Contraseña.</label>
                        <a href="<?= urlBase('codigo_recuperacion') ?>">¿Olvidaste tu contraseña?</a>
                    </div>
                    <div class="password-verify">
                        <input id="password" type="password" placeholder="Ingresa tu contraseña" />
                        <span id="ojoPassword" class="ojo-password">
                            <img id="iconoPassword" src="<?= urlBase('assets/auth/img/ojocerrado.png') ?>" alt="Ver contraseña" width="24" />
                        </span>
                    </div>
                    <small id="errorPassword" class="error-message">La contraseña debe tener mínimo 6 caracteres.</small>
                </div>
                <div class="remember-me">
                    <input type="checkbox" id="checkbox" />
                    <label for="checkbox">Recuérdame</label>
                </div>
                <button type="submit">ACCEDER</button>
            </form>

            <!-- Formulario REGISTRO -->
            <form action="" id="sign-Up">
                <h2>Registrar</h2>
                <p>¿Ya estás registrado? <a href="#" id="link-sign-up">Iniciar Sesión</a></p>
                <div class="input-container">
                    <label for="name">Nombre</label>
                    <input id="name" type="text" placeholder="Tu nombre es..." />
                    <small id="errorName" class="error-message">El nombre es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="Ap_paterno">Apellido Paterno</label>
                    <input id="Ap_paterno" type="text" placeholder="Tu apellido paterno es..." />
                    <small id="errorApPaterno" class="error-message">El apellido paterno es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="Ap_materno">Apellido Materno</label>
                    <input id="Ap_materno" type="text" placeholder="Tu apellido materno es..." />
                    <small id="errorApMaterno" class="error-message">El apellido materno es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="Carnet_i">CI</label>
                    <input id="Carnet_i" type="text" placeholder="Tu Carnet de identidad es..." />
                    <small id="errorCarnetI" class="error-message">El carnet de identidad es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="Fecha_nacimiento">Fecha de Nacimiento</label>
                    <input id="Fecha_nacimiento" type="date" placeholder="Tu Fecha de nacimiento es..." />
                    <small id="errorFechaNacimiento" class="error-message">La fecha de nacimiento es requerida.</small>
                </div>
                <div class="input-container">
                    <label for="email-register">Tu correo electrónico</label>
                    <input id="email-register" type="email" placeholder="you@example.com" />
                    <small id="errorEmailRegister" class="error-message">Ingresa un correo electrónico válido.</small>
                </div>
                <div class="input-container">
                    <label for="telefono">Número de celular</label>
                    <input id="telefono" type="tel" placeholder="tu Celular es..." />
                    <small id="errorTelefono" class="error-message">Ingresa un número de celular válido.</small>
                </div>
                <div class="input-container">
                          <label for="ciudad">Ciudad</label>
                         <select id="ciudad" name="ciudad" required>
                          <option value="">Selecciona una ciudad</option>
                          <option value="LA PAZ">LA PAZ</option>
                          <option value="EL ALTO">EL ALTO</option>
                         <option value="SANTA CRUZ">SANTA CRUZ</option>
                          <option value="COCHABAMBA">COCHABAMBA</option>
                           <option value="TARIJA">TARIJA</option>
                          <option value="PANDO">PANDO</option>
                         <option value="CHUQUISACA">CHUQUISACA</option>
                         <option value="BENI">BENI</option>
                         <option value="ORURO">ORURO</option>
                          <option value="POTOSI">POTOSI</option>
                           </select>
                        <small id="errorCiudad" class="error-message">La ciudad es requerida.</small>
                </div>

                <div class="input-container">
                    <label for="Zona">Zona</label>
                    <input id="Zona" type="text" placeholder="Tu Zona es...." />
                    <small id="errorZona" class="error-message">La zona es requerida.</small>
                </div>
                <div class="input-container">
                    <label for="Calle">Calle</label>
                    <input id="Calle" type="text" placeholder="Tu Calle es...." />
                    <small id="errorCalle" class="error-message">La calle es requerida.</small>
                </div>
                <div class="input-container">
                    <label for="Puerta">Número de puerta</label>
                    <input id="Puerta" type="text" placeholder="Tu Puerta es...." />
                    <small id="errorPuerta" class="error-message">El número de puerta es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="Usuario">Nombre de Usuario</label>
                    <input id="Usuario" type="text" placeholder="¿Qué nombre de usuario quieres?" />
                    <small id="errorUsuario" class="error-message">El nombre de usuario es requerido.</small>
                </div>
                <div class="input-container">
                    <label for="password-register">Contraseña</label>
                    <div class="password-verify">
                        <input id="password-register" type="password" placeholder="Ingresa 8 caracteres o más" />
                        <span id="ojoPasswordRegister" class="ojo-password">
                            <img id="iconoPasswordRegister" src="<?= urlBase('assets/auth/img/ojocerrado.png') ?>" alt="Ver contraseña" width="24" />
                        </span>
                    </div>
                    <small id="errorPasswordRegister" class="error-message">La contraseña es requerida y debe tener al menos 8 caracteres.</small>
                </div>
                <button type="submit" class="btn-register">REGISTRARSE</button>
            </form>
        </div>
    </div>

    <div class="banner">
        <section>
            <img src="<?= urlBase('assets/auth/img/vestido2.png') ?>" alt="vestido" width="325" height="600" />
        </section>
    </div>
    <div class="sidebar" id="sidebar">
        <div class="sign" id="btn-Sign-In">
            <img src="<?= urlBase('assets/auth/icons/crown.svg') ?>" alt="Sign In" />
            <span>Sign In</span>
        </div>
        <div class="sign" id="btn-Sign-Up">
            <img src="<?= urlBase('assets/auth/icons/rule.svg') ?>" alt="Sign Up" />
            <span>Sign Up</span>
        </div>
    </div>
</div>

<!-- Scripts funcionalidad de login y registro -->
<script>
    const btnSignIn = document.getElementById('btn-Sign-In');
    const btnSignUp = document.getElementById('btn-Sign-Up');
    const forms = document.getElementById('forms');
    const sidebar = document.getElementById('sidebar');
    const signIn = document.getElementById('sign-In');
    const signUp = document.getElementById('sign-Up');
    const container = document.getElementById('container');
    const linkSignIn = document.getElementById('link-sign-in');
    const linkSignUp = document.getElementById('link-sign-up');

    linkSignUp.addEventListener('click', (e) => {
        e.preventDefault();
        changeSignIn();
    });
    linkSignIn.addEventListener('click', (e) => {
        e.preventDefault();
        changeSignUp();
    });

    btnSignIn.addEventListener('click', () => {
        changeSignIn();
    });
    btnSignUp.addEventListener('click', () => {
        changeSignUp();
    });

    function changeSignIn() {
        forms.classList.remove('active');
        sidebar.classList.remove('active');
        container.style.animation = 'none';
        container.style.animation = 'bounce-up 1s ease';
        transition(signIn);
    }

    function changeSignUp() {
        forms.classList.add('active');
        sidebar.classList.add('active');
        container.style.animation = 'none';
        container.style.animation = 'bounce-down 1s ease';
        transition(signUp);
    }

    function transition(parent) {
        const children = parent.children;
        Array.from(children).forEach((child) => {
            child.style.opacity = '0';
            child.style.animation = 'none';
        });
        setTimeout(() => {
            Array.from(children).forEach((child, index) => {
                child.style.animation = 'slideIn 0.4s ease forwards';
                let delay = (index * 0.05) + 's';
                child.style.animationDelay = delay;
            });
        }, 300);
    }
</script>

<script src="<?= urlBase('assets/auth/login.js') ?>"></script>
<script src="<?= urlBase('assets/auth/registro.js') ?>"></script>

</body>
</html>
