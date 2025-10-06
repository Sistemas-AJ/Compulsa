from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import IntegrityError
from typing import List, Optional
from fastapi import HTTPException
from models.empresa import Empresa
from models.regimen_tributario import RegimenTributario
from .schemas import EmpresaCreate, EmpresaUpdate

class EmpresaService:
    
    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100, activo: bool = True) -> List[Empresa]:
        """Obtener todas las empresas con información del régimen"""
        query = db.query(Empresa).options(joinedload(Empresa.regimen_tributario))
        if activo is not None:
            query = query.filter(Empresa.activo == activo)
        return query.offset(skip).limit(limit).all()
    
    @staticmethod
    def get_by_id(db: Session, empresa_id: int) -> Optional[Empresa]:
        """Obtener empresa por ID"""
        return db.query(Empresa).options(joinedload(Empresa.regimen_tributario)).filter(Empresa.id == empresa_id).first()
    
    @staticmethod
    def get_by_ruc(db: Session, ruc: str) -> Optional[Empresa]:
        """Obtener empresa por RUC"""
        return db.query(Empresa).options(joinedload(Empresa.regimen_tributario)).filter(Empresa.ruc == ruc).first()
    
    @staticmethod
    def search_by_name(db: Session, search_term: str, skip: int = 0, limit: int = 100) -> List[Empresa]:
        """Buscar empresas por razón social o nombre comercial"""
        return db.query(Empresa).options(joinedload(Empresa.regimen_tributario)).filter(
            (Empresa.razon_social.ilike(f"%{search_term}%")) |
            (Empresa.nombre_comercial.ilike(f"%{search_term}%"))
        ).filter(Empresa.activo == True).offset(skip).limit(limit).all()
    
    @staticmethod
    def create(db: Session, empresa_data: EmpresaCreate) -> Empresa:
        """Crear nueva empresa"""
        # Verificar que el régimen tributario existe
        regimen = db.query(RegimenTributario).filter(
            RegimenTributario.id == empresa_data.regimen_tributario_id,
            RegimenTributario.activo == True
        ).first()
        if not regimen:
            raise HTTPException(status_code=400, detail="Régimen tributario no encontrado o inactivo")
        
        try:
            db_empresa = Empresa(**empresa_data.model_dump())
            db.add(db_empresa)
            db.commit()
            db.refresh(db_empresa)
            return EmpresaService.get_by_id(db, db_empresa.id)
        except IntegrityError as e:
            db.rollback()
            if "UNIQUE constraint failed" in str(e) and "ruc" in str(e):
                raise HTTPException(status_code=400, detail="Ya existe una empresa con este RUC")
            raise HTTPException(status_code=400, detail="Error al crear empresa")
    
    @staticmethod
    def update(db: Session, empresa_id: int, empresa_data: EmpresaUpdate) -> Optional[Empresa]:
        """Actualizar empresa"""
        db_empresa = EmpresaService.get_by_id(db, empresa_id)
        if not db_empresa:
            return None
        
        # Si se está actualizando el régimen, verificar que existe
        if empresa_data.regimen_tributario_id:
            regimen = db.query(RegimenTributario).filter(
                RegimenTributario.id == empresa_data.regimen_tributario_id,
                RegimenTributario.activo == True
            ).first()
            if not regimen:
                raise HTTPException(status_code=400, detail="Régimen tributario no encontrado o inactivo")
        
        try:
            update_data = empresa_data.model_dump(exclude_unset=True)
            for field, value in update_data.items():
                setattr(db_empresa, field, value)
            
            db.commit()
            db.refresh(db_empresa)
            return EmpresaService.get_by_id(db, db_empresa.id)
        except IntegrityError as e:
            db.rollback()
            if "UNIQUE constraint failed" in str(e) and "ruc" in str(e):
                raise HTTPException(status_code=400, detail="Ya existe una empresa con este RUC")
            raise HTTPException(status_code=400, detail="Error al actualizar empresa")
    
    @staticmethod
    def delete(db: Session, empresa_id: int) -> bool:
        """Eliminar (desactivar) empresa"""
        db_empresa = EmpresaService.get_by_id(db, empresa_id)
        if not db_empresa:
            return False
        
        # Soft delete: solo desactivar
        db_empresa.activo = False
        db.commit()
        return True
    
    @staticmethod
    def count(db: Session, activo: bool = True) -> int:
        """Contar empresas"""
        query = db.query(Empresa)
        if activo is not None:
            query = query.filter(Empresa.activo == activo)
        return query.count()
    
    @staticmethod
    def get_by_regimen(db: Session, regimen_id: int, skip: int = 0, limit: int = 100) -> List[Empresa]:
        """Obtener empresas por régimen tributario"""
        return db.query(Empresa).options(joinedload(Empresa.regimen_tributario)).filter(
            Empresa.regimen_tributario_id == regimen_id,
            Empresa.activo == True
        ).offset(skip).limit(limit).all()