import sys
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

# Agregar el directorio actual al path para importaciones
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from db.database import engine, Base
from features.regimenes.router import router as regimenes_router
from features.empresas.router import router as empresas_router
from features.calculos.router import router as calculos_router
from features.liquidaciones.router import router as liquidaciones_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Crear tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Shutdown: Cleanup si es necesario
    pass

# Crear aplicación FastAPI
app = FastAPI(
    title="Compulsa API",
    description="""
    # Compulsa - API del Asistente Tributario Inteligente
    
    API REST completa para el manejo de información tributaria empresarial en Perú.
    
    ## Características principales:
    
    * **Gestión de Regímenes Tributarios**: CRUD completo para regímenes (General, MYPE, Especial, RUS)
    * **Gestión de Empresas**: Registro y administración de empresas con validación de RUC
    * **Cálculos Tributarios**: IGV e Impuesto a la Renta según normativa peruana
    * **Validaciones**: Cumplimiento de reglas tributarias peruanas
    
    ## Regímenes Tributarios Soportados:
    
    1. **Régimen General**: Empresas grandes (29.5% renta)
    2. **Régimen MYPE**: Micro y pequeñas empresas (10% renta)  
    3. **Régimen Especial**: Empresas medianas (1.5% renta)
    4. **RUS**: Régimen Único Simplificado (cuotas fijas)
    
    ## Cálculos Automatizados:
    
    * **IGV**: 18% sobre base imponible, menos crédito fiscal
    * **Renta**: Según régimen tributario de la empresa
    * **Validaciones**: Límites por régimen y RUC peruano
    """,
    version="2.0.0",
    contact={
        "name": "Sistemas AJ",
        "url": "https://github.com/Sistemas-AJ",
    },
    license_info={
        "name": "MIT",
    },
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios exactos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(regimenes_router, prefix="/api/v1")
app.include_router(empresas_router, prefix="/api/v1")
app.include_router(calculos_router, prefix="/api/v1")
app.include_router(liquidaciones_router, prefix="/api/v1")

# Endpoint raíz
@app.get("/", tags=["Root"])
def read_root():
    return {
        "message": "Compulsa API - Asistente Tributario Inteligente",
        "version": "2.0.0",
        "status": "running",
        "docs": "/docs",
        "redoc": "/redoc"
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": "Compulsa API",
        "version": "2.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app", 
        host="127.0.0.1",
        port=8001,
        reload=True,
        log_level="info"
    )