# django-micro-crud-wars

Estructura base para la actividad de los estudiantes.


## Estructura

```
django-micro-crud-wars/
├─ database/
│  └─ init.sql
├─ services/
│  ├─ template-service/
│  │  ├─ Dockerfile
│  │  ├─ requirements.txt
│  │  ├─ manage.py
│  │  └─ service_template/
│  └─ order-service/
├─ docker-compose.yml
└─ README.md
```

Instrucciones:
1. Cada estudiante copia `services/template-service/` y la renombra.
2. Dentro de `template-service` hay un proyecto Django mínimo y un ejemplo de app `order`.


## Instrucciones paso a paso para levantar los servicios (Docker + Django)

Este repositorio contiene:
- Un contenedor de base de datos PostgreSQL definido en `docker-compose.yml`.
- Una plantilla de servicio Django en `services/template-service/` con una app de ejemplo `order`.
- Una carpeta `services/order-service/` vacía para que los estudiantes copien y adapten la plantilla.

> Ruta de la imagen de referencia (proporcionada por el docente): `/mnt/data/Estructura del repositorio.png`

### Requisitos previos (en la máquina local)
- Tener instalado Docker y Docker Compose.
- Espacio en disco suficiente.
- Git para clonar el repositorio.

### 1) Descargar y descomprimir (si usan el ZIP)
Si estás usando el ZIP proporcionado, descomprímelo y entra en la carpeta:
```bash
unzip django-micro-crud.zip
cd django-micro-crud
```

Si clonaste el repositorio con Git:
```bash
git clone <url-del-repositorio>
cd django-micro-crud
```

### 2) Levantar la base de datos con Docker Compose
El `docker-compose.yml` define el servicio `deliverydb_bo` con Postgres. Levanta los servicios:
```bash
docker-compose up -d
```
- Esto dejará corriendo el contenedor de Postgres y montará `database/init.sql` para inicializar tablas de ejemplo.

Verificar contenedores:
```bash
docker ps
```

### 3) Crear/usar un servicio Django basado en la plantilla
La plantilla está en `services/template-service/`. Para que cada estudiante tenga su servicio:
```bash
cp -r services/template-service services/my-service-<tu-nombre>
cd services/my-service-<tu-nombre>
```
Ajusta `service_template/settings.py` si necesitas cambiar nombre de BD/usuario/contraseña o variables de entorno.

### 4) Construir la imagen del servicio (opcional) y ejecutar localmente
Desde la carpeta del servicio puedes ejecutar la app Django en modo local (venv) (requiere Python y dependencias) o crear un contenedor Docker.

**Opción A — Ejecutar local (recomendado para desarrollo rápido):**
```bash
python -m venv venv
source venv/bin/activate   # en Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```
La aplicación Django intentará conectarse a la base de datos configurada en `service_template/settings.py`. Si Postgres está en Docker en la misma máquina, deja `POSTGRES_HOST=db` o configura `POSTGRES_HOST=localhost` según tu entorno.

**Opción B — Ejecutar con Docker (cada servicio en su contenedor)**
Desde la raíz del servicio (donde está el Dockerfile):
```bash
docker build -t my-service-img .
docker run --rm -e POSTGRES_DB=demo -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password --network host my-service-img
```
> Nota: usar `--network host` simplifica la conexión si Postgres está en la máquina host; en entornos con docker-compose se deben crear servicios y redes en `docker-compose.yml` para cada servicio.

### 5) Migraciones y superuser
Si corres el servicio (local o en contenedor) debes aplicar migraciones y crear un superusuario:
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```
Si corres dentro de un contenedor (con docker exec) y el contenedor se llama `my-service`:
```bash
docker exec -it my-service python manage.py migrate
docker exec -it my-service python manage.py createsuperuser
```

### 6) Probar el endpoint de ejemplo
La app `order` expone `/order/` que devuelve un JSON con las órdenes (inicialmente vacío).
Si ejecutas local con runserver en el puerto 8000:
```bash
curl http://127.0.0.1:8000/order/
# Debe devolver: {"orders": []} o datos si hay registros
```

### 7) Insertar datos de prueba
Puedes usar el admin o crear registros desde Django shell:
```bash
python manage.py shell
>>> from order.models import Order
>>> Order.objects.create(nombre='Prueba', monto=100.50)
>>> exit()
```
Luego consulta:
```bash
curl http://127.0.0.1:8000/order/
# Ahora verás el registro creado
```

### 8) Copiar plantilla para ejercicio individual
Cada estudiante debe:
1. Copiar `services/template-service` y renombrarlo a `services/<nombre-del-estudiante>-service`.
2. Editar `service_template/settings.py` para cambiar `SECRET_KEY`, `ALLOWED_HOSTS` y la configuración de `DATABASES` si es necesario.
3. Añadir sus propias apps Django dentro del proyecto (por ejemplo: `payments`, `customers`, etc).
4. Commit y push a su repositorio privado o entregar un ZIP.

### 9) Buenas prácticas y recomendaciones
- No subir `SECRET_KEY` reales a repositorios públicos.
- Usar variables de entorno para credenciales de DB.
- Añadir `requirements.txt` actualizado con dependencias del proyecto.
- Agregar un `README.md` dentro del servicio con endpoints disponibles y ejemplos de uso.
- Probar migraciones en una base de datos local antes de ejecutar en producción.

---

Si quieres, puedo:
- Añadir un `Makefile` o scripts `./scripts/start.sh` y `./scripts/stop.sh` para simplificar comandos `docker-compose up/down`, migraciones y creación de superuser.
- Extender `docker-compose.yml` para incluir un servicio `template-service` listo para levantar con la red adecuada (y así los estudiantes no tengan que construir imagen manualmente).
