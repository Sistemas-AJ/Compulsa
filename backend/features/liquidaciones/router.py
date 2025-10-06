from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from db.database import get_db
from .service import LiquidacionService
from .schemas import LiquidacionCreate, LiquidacionUpdate, LiquidacionResponse, LiquidacionWithEmpresaResponse

router = APIRouter(prefix="/liquidaciones", tags=["Liquidaciones Mensuales"])

@router.get("/", response_model=List[LiquidacionWithEmpresaResponse])
def get_liquidaciones(
    skip: int = Query(0, ge=0, description="Número de registros a omitir"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros a retornar"),
    empresa_id: Optional[int] = Query(None, description="Filtrar por empresa"),
    periodo: Optional[str] = Query(None, description="Filtrar por período (YYYY-MM)"),
    db: Session = Depends(get_db)
):
    """Obtener lista de liquidaciones mensuales"""
    if periodo:
        return LiquidacionService.get_by_periodo(db, periodo, skip=skip, limit=limit)
    return LiquidacionService.get_all(db, skip=skip, limit=limit, empresa_id=empresa_id)

@router.get("/{liquidacion_id}", response_model=LiquidacionWithEmpresaResponse)
def get_liquidacion(liquidacion_id: int, db: Session = Depends(get_db)):
    """Obtener liquidación por ID"""
    liquidacion = LiquidacionService.get_by_id(db, liquidacion_id)
    if not liquidacion:
        raise HTTPException(status_code=404, detail="Liquidación no encontrada")
    return liquidacion

@router.get("/empresa/{empresa_id}/periodo/{periodo}", response_model=LiquidacionWithEmpresaResponse)
def get_liquidacion_by_empresa_periodo(empresa_id: int, periodo: str, db: Session = Depends(get_db)):
    """Obtener liquidación específica por empresa y período"""
    liquidacion = LiquidacionService.get_by_empresa_periodo(db, empresa_id, periodo)
    if not liquidacion:
        raise HTTPException(status_code=404, detail="Liquidación no encontrada para ese período")
    return liquidacion

@router.post("/", response_model=LiquidacionWithEmpresaResponse, status_code=201)
def create_liquidacion(liquidacion_data: LiquidacionCreate, db: Session = Depends(get_db)):
    """Crear nueva liquidación mensual"""
    return LiquidacionService.create(db, liquidacion_data)

@router.put("/{liquidacion_id}", response_model=LiquidacionWithEmpresaResponse)
def update_liquidacion(
    liquidacion_id: int, 
    liquidacion_data: LiquidacionUpdate, 
    db: Session = Depends(get_db)
):
    """Actualizar liquidación mensual"""
    liquidacion = LiquidacionService.update(db, liquidacion_id, liquidacion_data)
    if not liquidacion:
        raise HTTPException(status_code=404, detail="Liquidación no encontrada")
    return liquidacion

@router.delete("/{liquidacion_id}")
def delete_liquidacion(liquidacion_id: int, db: Session = Depends(get_db)):
    """Eliminar liquidación mensual"""
    if not LiquidacionService.delete(db, liquidacion_id):
        raise HTTPException(status_code=404, detail="Liquidación no encontrada")
    return {"message": "Liquidación eliminada correctamente"}

@router.get("/empresa/{empresa_id}/resumen/{year}")
def get_resumen_anual(empresa_id: int, year: int, db: Session = Depends(get_db)):
    """Obtener resumen anual de liquidaciones de una empresa"""
    if year < 2020 or year > 2030:
        raise HTTPException(status_code=400, detail="Año debe estar entre 2020 y 2030")
    return LiquidacionService.get_resumen_anual(db, empresa_id, year)

@router.get("/stats/count")
def get_liquidaciones_count(
    empresa_id: Optional[int] = Query(None, description="Filtrar por empresa"),
    db: Session = Depends(get_db)
):
    """Obtener conteo de liquidaciones"""
    count = LiquidacionService.count(db, empresa_id=empresa_id)
    return {"total": count, "empresa_id": empresa_id}