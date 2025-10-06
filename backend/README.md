# Compulsa Backend

API REST para el sistema tributario Compulsa desarrollada con FastAPI y SQLAlchemy.

## Instalación

1. **Crear entorno virtual:**
```bash
python -m venv venv
```

2. **Activar entorno virtual:**
- Windows:
```bash
venv\Scripts\activate
```
- Linux/Mac:
```bash
source venv/bin/activate
```

3. **Instalar dependencias:**
```bash
pip install -r requirements.txt
```

4. **Inicializar la base de datos:**
```bash
python init_db.py
```

5. **Ejecutar el servidor:**
```bash
python main.py
```

La API estará disponible en: `http://localhost:8000`

## Documentación de la API

FastAPI genera automáticamente documentación interactiva:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Endpoints Principales

### Regímenes Tributarios
- `GET /regimenes-tributarios/` - Listar regímenes
- `POST /regimenes-tributarios/` - Crear régimen
- `GET /regimenes-tributarios/{id}` - Obtener régimen específico
- `PUT /regimenes-tributarios/{id}` - Actualizar régimen
- `DELETE /regimenes-tributarios/{id}` - Eliminar régimen

### Empresas
- `GET /empresas/` - Listar empresas
- `POST /empresas/` - Crear empresa
- `GET /empresas/{id}` - Obtener empresa específica
- `GET /empresas/ruc/{ruc}` - Buscar empresa por RUC
- `PUT /empresas/{id}` - Actualizar empresa
- `DELETE /empresas/{id}` - Eliminar empresa

### Liquidaciones Mensuales
- `GET /liquidaciones/` - Listar liquidaciones
- `POST /liquidaciones/` - Crear liquidación
- `GET /liquidaciones/{id}` - Obtener liquidación específica
- `PUT /liquidaciones/{id}` - Actualizar liquidación
- `DELETE /liquidaciones/{id}` - Eliminar liquidación

### Saldos Fiscales
- `GET /saldos-fiscales/` - Listar saldos
- `POST /saldos-fiscales/` - Crear saldo
- `GET /saldos-fiscales/{id}` - Obtener saldo específico
- `PUT /saldos-fiscales/{id}` - Actualizar saldo

### Pagos
- `GET /pagos/` - Listar pagos
- `POST /pagos/` - Registrar pago
- `GET /pagos/{id}` - Obtener pago específico

### Cálculos
- `POST /calcular-igv/` - Calcular IGV
- `POST /calcular-renta/` - Calcular Impuesto a la Renta

## Estructura de la Base de Datos

La API utiliza SQLite con las siguientes tablas:
1. **regimens_tributarios** - Regímenes tributarios disponibles
2. **empresas** - Información de las empresas
3. **liquidaciones_mensuales** - Liquidaciones tributarias mensuales
4. **saldos_fiscales** - Saldos a favor o en contra
5. **pagos_realizados** - Registro de pagos efectuados

## Datos de Prueba

El script `init_db.py` crea automáticamente:
- 4 regímenes tributarios (General, MYPE, Especial, RUS)
- 3 empresas de ejemplo con diferentes regímenes

## Desarrollo

Para desarrollo con recarga automática:
```bash
pip install uvicorn[standard]
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```