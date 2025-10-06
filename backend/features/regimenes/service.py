from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import List, Optional
from fastapi import HTTPException
from models.regimen_tributario import RegimenTributario
from .schemas import RegimenTributarioCreate, RegimenTributarioUpdate

class RegimenTributarioService:
    
    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100, activo: bool = True) -> List[RegimenTributario]:
        """Obtener todos los regímenes tributarios"""
        query = db.query(RegimenTributario)
        if activo is not None:
            query = query.filter(RegimenTributario.activo == activo)
        return query.offset(skip).limit(limit).all()
    
    @staticmethod
    def get_by_id(db: Session, regimen_id: int) -> Optional[RegimenTributario]:
        """Obtener régimen por ID"""
        return db.query(RegimenTributario).filter(RegimenTributario.id == regimen_id).first()
    
    @staticmethod
    def get_by_name(db: Session, nombre: str) -> Optional[RegimenTributario]:
        """Obtener régimen por nombre"""
        return db.query(RegimenTributario).filter(RegimenTributario.nombre == nombre).first()
    
    @staticmethod
    def create(db: Session, regimen_data: RegimenTributarioCreate) -> RegimenTributario:
        """Crear nuevo régimen tributario"""
        try:
            db_regimen = RegimenTributario(**regimen_data.model_dump())
            db.add(db_regimen)
            db.commit()
            db.refresh(db_regimen)
            return db_regimen
        except IntegrityError as e:
            db.rollback()
            if "UNIQUE constraint failed" in str(e):
                raise HTTPException(status_code=400, detail="Ya existe un régimen con ese nombre")
            raise HTTPException(status_code=400, detail="Error al crear régimen tributario")
    
    @staticmethod
    def update(db: Session, regimen_id: int, regimen_data: RegimenTributarioUpdate) -> Optional[RegimenTributario]:
        """Actualizar régimen tributario"""
        db_regimen = RegimenTributarioService.get_by_id(db, regimen_id)
        if not db_regimen:
            return None
        
        try:
            update_data = regimen_data.model_dump(exclude_unset=True)
            for field, value in update_data.items():
                setattr(db_regimen, field, value)
            
            db.commit()
            db.refresh(db_regimen)
            return db_regimen
        except IntegrityError as e:
            db.rollback()
            if "UNIQUE constraint failed" in str(e):
                raise HTTPException(status_code=400, detail="Ya existe un régimen con ese nombre")
            raise HTTPException(status_code=400, detail="Error al actualizar régimen tributario")
    
    @staticmethod
    def delete(db: Session, regimen_id: int) -> bool:
        """Eliminar (desactivar) régimen tributario"""
        db_regimen = RegimenTributarioService.get_by_id(db, regimen_id)
        if not db_regimen:
            return False
        
        # Soft delete: solo desactivar
        db_regimen.activo = False
        db.commit()
        return True
    
    @staticmethod
    def count(db: Session, activo: bool = True) -> int:
        """Contar regímenes tributarios"""
        query = db.query(RegimenTributario)
        if activo is not None:
            query = query.filter(RegimenTributario.activo == activo)
        return query.count()