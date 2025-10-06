from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from db.database import get_db
from .service import RegimenTributarioService
from .schemas import RegimenTributarioCreate, RegimenTributarioUpdate, RegimenTributarioResponse

router = APIRouter(prefix="/regimenes-tributarios", tags=["Regímenes Tributarios"])

@router.get("/", response_model=List[RegimenTributarioResponse])
def get_regimenes(
    skip: int = Query(0, ge=0, description="Número de registros a omitir"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros a retornar"),
    activo: Optional[bool] = Query(True, description="Filtrar por estado activo"),
    db: Session = Depends(get_db)
):
    """Obtener lista de regímenes tributarios"""
    return RegimenTributarioService.get_all(db, skip=skip, limit=limit, activo=activo)

@router.get("/{regimen_id}", response_model=RegimenTributarioResponse)
def get_regimen(regimen_id: int, db: Session = Depends(get_db)):
    """Obtener régimen tributario por ID"""
    regimen = RegimenTributarioService.get_by_id(db, regimen_id)
    if not regimen:
        raise HTTPException(status_code=404, detail="Régimen tributario no encontrado")
    return regimen

@router.post("/", response_model=RegimenTributarioResponse, status_code=201)
def create_regimen(regimen_data: RegimenTributarioCreate, db: Session = Depends(get_db)):
    """Crear nuevo régimen tributario"""
    return RegimenTributarioService.create(db, regimen_data)

@router.put("/{regimen_id}", response_model=RegimenTributarioResponse)
def update_regimen(
    regimen_id: int, 
    regimen_data: RegimenTributarioUpdate, 
    db: Session = Depends(get_db)
):
    """Actualizar régimen tributario"""
    regimen = RegimenTributarioService.update(db, regimen_id, regimen_data)
    if not regimen:
        raise HTTPException(status_code=404, detail="Régimen tributario no encontrado")
    return regimen

@router.delete("/{regimen_id}")
def delete_regimen(regimen_id: int, db: Session = Depends(get_db)):
    """Eliminar (desactivar) régimen tributario"""
    if not RegimenTributarioService.delete(db, regimen_id):
        raise HTTPException(status_code=404, detail="Régimen tributario no encontrado")
    return {"message": "Régimen tributario eliminado correctamente"}

@router.get("/stats/count")
def get_regimenes_count(
    activo: Optional[bool] = Query(True, description="Filtrar por estado activo"),
    db: Session = Depends(get_db)
):
    """Obtener conteo de regímenes tributarios"""
    count = RegimenTributarioService.count(db, activo=activo)
    return {"total": count, "activo": activo}