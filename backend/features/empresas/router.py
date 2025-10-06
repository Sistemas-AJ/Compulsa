from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from db.database import get_db
from .service import EmpresaService
from .schemas import EmpresaCreate, EmpresaUpdate, EmpresaResponse, EmpresaWithRegimenResponse

router = APIRouter(prefix="/empresas", tags=["Empresas"])

@router.get("/", response_model=List[EmpresaWithRegimenResponse])
def get_empresas(
    skip: int = Query(0, ge=0, description="Número de registros a omitir"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros a retornar"),
    activo: Optional[bool] = Query(True, description="Filtrar por estado activo"),
    regimen_id: Optional[int] = Query(None, description="Filtrar por régimen tributario"),
    db: Session = Depends(get_db)
):
    """Obtener lista de empresas"""
    if regimen_id:
        return EmpresaService.get_by_regimen(db, regimen_id, skip=skip, limit=limit)
    return EmpresaService.get_all(db, skip=skip, limit=limit, activo=activo)

@router.get("/search", response_model=List[EmpresaWithRegimenResponse])
def search_empresas(
    q: str = Query(..., min_length=2, description="Término de búsqueda"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Buscar empresas por razón social o nombre comercial"""
    return EmpresaService.search_by_name(db, q, skip=skip, limit=limit)

@router.get("/{empresa_id}", response_model=EmpresaWithRegimenResponse)
def get_empresa(empresa_id: int, db: Session = Depends(get_db)):
    """Obtener empresa por ID"""
    empresa = EmpresaService.get_by_id(db, empresa_id)
    if not empresa:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa

@router.get("/ruc/{ruc}", response_model=EmpresaWithRegimenResponse)
def get_empresa_by_ruc(ruc: str, db: Session = Depends(get_db)):
    """Obtener empresa por RUC"""
    empresa = EmpresaService.get_by_ruc(db, ruc)
    if not empresa:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa

@router.post("/", response_model=EmpresaWithRegimenResponse, status_code=201)
def create_empresa(empresa_data: EmpresaCreate, db: Session = Depends(get_db)):
    """Crear nueva empresa"""
    return EmpresaService.create(db, empresa_data)

@router.put("/{empresa_id}", response_model=EmpresaWithRegimenResponse)
def update_empresa(
    empresa_id: int, 
    empresa_data: EmpresaUpdate, 
    db: Session = Depends(get_db)
):
    """Actualizar empresa"""
    empresa = EmpresaService.update(db, empresa_id, empresa_data)
    if not empresa:
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return empresa

@router.delete("/{empresa_id}")
def delete_empresa(empresa_id: int, db: Session = Depends(get_db)):
    """Eliminar (desactivar) empresa"""
    if not EmpresaService.delete(db, empresa_id):
        raise HTTPException(status_code=404, detail="Empresa no encontrada")
    return {"message": "Empresa eliminada correctamente"}

@router.get("/stats/count")
def get_empresas_count(
    activo: Optional[bool] = Query(True, description="Filtrar por estado activo"),
    db: Session = Depends(get_db)
):
    """Obtener conteo de empresas"""
    count = EmpresaService.count(db, activo=activo)
    return {"total": count, "activo": activo}