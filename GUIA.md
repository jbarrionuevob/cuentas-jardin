# Cuentas del Jardín: puesta en marcha

Haz esto una sola vez. Toma unos 15 minutos.

## 1. Crear la base de datos (Supabase, gratis)
1. Entra a supabase.com, crea una cuenta y toca **New project**.
2. Nombre: `jardin39`. Región: **South America (São Paulo)**. Guarda la contraseña que elijas.
3. Espera a que termine de crearse (1 o 2 minutos).

## 2. Cargar la configuración
1. En el menú izquierdo abre **SQL Editor** y toca **New query**.
2. Pega todo el contenido de `supabase-setup.sql` y toca **Run**. Debe decir "Success".

## 3. Simplificar el registro
1. Ve a **Authentication > Sign In / Providers > Email**.
2. Apaga **Confirm email** y guarda. Así las personas entran en cuanto crean su cuenta.

## 4. Copiar dos datos y enviármelos
En **Project Settings > API** copia:
- **Project URL** (algo como `https://abcd1234.supabase.co`)
- **anon public key** (o "Publishable key")

Es seguro compartirlos. **No me envíes la `service_role` key ni la contraseña de la base de datos.**

## 5. Publicar la app
La publico en una dirección web tuya (GitHub Pages). Para eso necesito que conectes GitHub a Claude
(claude.ai > Configuración > Conectores) y que crees un repositorio vacío, por ejemplo `cuentas-jardin`.
También puedes subir tú los archivos de esta carpeta al repositorio y activar Pages.

## 6. Crear las cuentas
1. **Tú primero.** Abre la dirección, toca "Crear una cuenta" y regístrate. La primera cuenta queda como **administradora**.
2. Cada persona del equipo crea su cuenta con su nombre. Queda **pendiente**.
3. En **Más > Equipo y permisos** toca a cada persona y elige su rol:
   - **Administrador:** ve y hace todo, elimina y maneja al equipo.
   - **Empleado:** ve y registra todo, pero no elimina.
   - **Bloqueado:** sin acceso.

## 7. Instalarla en el celular
- **Android (Chrome):** menú de los tres puntos > **Instalar app** o **Agregar a pantalla de inicio**.
- **iPhone (Safari):** botón Compartir > **Añadir a pantalla de inicio**.

## 8. Pasar los datos del prototipo
En el prototipo: **Más > Copiar respaldo de todo**. En la app nueva: **Más > Restaurar un respaldo** y pega el texto.

## Notas
- Sin internet la app abre y guarda; todo se envía cuando vuelve la conexión. Arriba aparece cuántos cambios faltan por enviar.
- Si alguien olvida su contraseña, usa "Olvidé mi contraseña" en la pantalla de entrada.
- Para impedir cuentas nuevas más adelante: Supabase > Authentication > Sign In / Providers > apaga **Allow new users to sign up**.
