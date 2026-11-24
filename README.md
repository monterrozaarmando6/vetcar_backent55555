# Backend del Sistema de Gestion Veterinaria

API REST en Java para gestionar propietarios, mascotas, usuarios, citas, consultas, historial medico, vacunas, tratamientos, medicamentos, inventario, servicios, pagos, facturas, notificaciones y hospitalizaciones.

No requiere Maven, Gradle ni librerias externas. Usa `HttpServer` del JDK y guarda los datos localmente en `data/veterinaria.bin`.

## Requisitos

- JDK 21 o superior

## Ejecutar

Desde esta carpeta:

```powershell
javac -d out src\main\java\com\veterinaria\ApiServer.java
java -cp out com.veterinaria.ApiServer
```

El servidor se inicia en `http://localhost:8080`.

## Despliegue con Docker o Render

El `Dockerfile` compila el archivo Java dentro del contenedor. Antes de desplegar, asegúrese de subir **la carpeta completa** `backend-veterinaria-java`, no solamente el archivo `Dockerfile`. La carpeta debe contener, como mínimo, esta estructura:

```text
Dockerfile
src/main/java/com/veterinaria/ApiServer.java
```

En Render, indique `backend-veterinaria-java` como *Root Directory* si el repositorio contiene esta carpeta. Si sube solamente el contenido del ZIP del backend a un repositorio independiente, deje *Root Directory* vacío. El error `"/src: not found"` se produce cuando Render recibe solo el Dockerfile o se elige una carpeta raíz equivocada.

## Autenticacion

1. Cree un usuario administrador:

```http
POST /api/auth/register
Content-Type: application/json

{"name":"Administrador","email":"admin@veterinaria.local","password":"CambioSeguro123","role":"ADMIN"}
```

2. Inicie sesion:

```http
POST /api/auth/login
Content-Type: application/json

{"email":"admin@veterinaria.local","password":"CambioSeguro123"}
```

3. Envie el token en las demas solicitudes:

```http
Authorization: Bearer <token>
```

## Recursos REST

Cada recurso admite `GET /api/{recurso}`, `POST /api/{recurso}`, `GET /api/{recurso}/{id}`, `PUT /api/{recurso}/{id}` y `DELETE /api/{recurso}/{id}`.

| Recurso | Uso |
| --- | --- |
| `owners` | Propietarios |
| `pets` | Mascotas e informacion clinica basica |
| `users` | Personal y roles |
| `appointments` | Citas veterinarias |
| `consultations` | Consultas e historial medico |
| `vaccines` | Vacunas |
| `treatments` | Tratamientos |
| `allergies` | Alergias y antecedentes |
| `medications` | Medicamentos |
| `inventory` | Existencias y alertas de inventario |
| `services` | Servicios veterinarios |
| `payments` | Pagos |
| `invoices` | Facturas |
| `notifications` | Recordatorios y notificaciones |
| `hospitalizations` | Hospitalizaciones |

### Ejemplo: registrar una mascota

```http
POST /api/pets
Authorization: Bearer <token>
Content-Type: application/json

{"name":"Luna","species":"Perro","breed":"Labrador","ownerId":"<id-del-propietario>","birthDate":"2022-03-10","weight":"18.5"}
```

### Reporte general

```http
GET /api/reports/dashboard
Authorization: Bearer <token>
```

## Roles

- `ADMIN`: acceso completo.
- `VETERINARIAN`: atencion clinica, citas, historial, vacunas y tratamientos.
- `RECEPTIONIST`: propietarios, mascotas, citas, pagos, facturas y notificaciones.
- `OWNER`: consulta de la informacion asociada a sus mascotas.

Para un entorno productivo, cambie la clave de firma definida en `APP_SECRET`, use una base de datos relacional y sirva la API detras de HTTPS.

## Desplegar en Render

El proyecto incluye un `Dockerfile` y `render.yaml` para desplegarlo como servicio web.

1. Cree un repositorio en GitHub y suba esta carpeta completa.
2. En Render, seleccione **New > Blueprint**.
3. Conecte el repositorio y seleccione el archivo `render.yaml`.
4. Render generara automaticamente `APP_SECRET` y asignara el puerto.
5. Espere a que finalice el despliegue y abra `/api/health`.

Ejemplo:

```text
https://backend-veterinaria-java.onrender.com/api/health
```

La configuracion incluida usa el plan gratuito, sin almacenamiento persistente (el bloque `disk` de `render.yaml` esta comentado; actívalo con un plan de pago). El archivo `data/veterinaria.bin` es adecuado para pruebas, pero puede perderse al reiniciar o desplegar nuevamente en un plan sin disco persistente. Para produccion debe reemplazarse por PostgreSQL y un volumen persistente o disco administrado.

## Variables de entorno

| Variable | Descripcion |
| --- | --- |
| `PORT` | Lo asigna la plataforma (por defecto 8080) |
| `APP_SECRET` | Clave para firmar tokens (obligatoria en produccion) |
| `CORS_ORIGIN` | URL exacta de tu frontend, sin `/` final |
| `DATA_DIR` | Carpeta de datos (por defecto `/data` en Docker) |

## Railway / Fly.io

El `Dockerfile` ya no usa `VOLUME` (Railway lo prohibe). Cree el volumen desde el panel de la plataforma y montelo en `/data`.
