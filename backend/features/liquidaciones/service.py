from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import IntegrityError
from typing import List, Optional
from fastapi import HTTPException
from models.liquidacion import LiquidacionMensual
from models.empresa import Empresa
from .schemas import LiquidacionCreate, LiquidacionUpdate

class LiquidacionService:
    
    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100, empresa_id: Optional[int] = None) -> List[LiquidacionMensual]:
        """Obtener todas las liquidaciones"""
        query = db.query(LiquidacionMensual).options(joinedload(LiquidacionMensual.empresa))
        
        if empresa_id:
            query = query.filter(LiquidacionMensual.empresa_id == empresa_id)
            
        return query.offset(skip).limit(limit).all()
    
    @staticmethod
    def get_by_id(db: Session, liquidacion_id: int) -> Optional[LiquidacionMensual]:
        """Obtener liquidación por ID"""
        return db.query(LiquidacionMensual).options(
            joinedload(LiquidacionMensual.empresa)
        ).filter(LiquidacionMensual.id == liquidacion_id).first()
    
    @staticmethod
    def get_by_empresa_periodo(db: Session, empresa_id: int, periodo: str) -> Optional[LiquidacionMensual]:
        """Obtener liquidación por empresa y período"""
        return db.query(LiquidacionMensual).filter(
            LiquidacionMensual.empresa_id == empresa_id,
            LiquidacionMensual.periodo == periodo
        ).first()
    
    @staticmethod
    def get_by_periodo(db: Session, periodo: str, skip: int = 0, limit: int = 100) -> List[LiquidacionMensual]:
        """Obtener liquidaciones por período"""
        return db.query(LiquidacionMensual).options(
            joinedload(LiquidacionMensual.empresa)
        ).filter(LiquidacionMensual.periodo == periodo).offset(skip).limit(limit).all()
    
    @staticmethod
    def create(db: Session, liquidacion_data: LiquidacionCreate) -> LiquidacionMensual:
        """Crear nueva liquidación"""
        # Verificar que la empresa existe
        empresa = db.query(Empresa).filter(Empresa.id == liquidacion_data.empresa_id).first()
        if not empresa:
            raise HTTPException(status_code=400, detail="Empresa no encontrada")
        
        # Verificar que no existe una liquidación para ese período
        existing = LiquidacionService.get_by_empresa_periodo(
            db, liquidacion_data.empresa_id, liquidacion_data.periodo
        )
        if existing:
            raise HTTPException(
                status_code=400, 
                detail=f"Ya existe una liquidación para la empresa {liquidacion_data.empresa_id} en el período {liquidacion_data.periodo}"
            )
        
        try:
            db_liquidacion = LiquidacionMensual(**liquidacion_data.model_dump())
            db.add(db_liquidacion)
            db.commit()
            db.refresh(db_liquidacion)
            return LiquidacionService.get_by_id(db, db_liquidacion.id)
        except IntegrityError as e:
            db.rollback()
            raise HTTPException(status_code=400, detail="Error al crear liquidación")
    
    @staticmethod
    def update(db: Session, liquidacion_id: int, liquidacion_data: LiquidacionUpdate) -> Optional[LiquidacionMensual]:
        """Actualizar liquidación"""
        db_liquidacion = LiquidacionService.get_by_id(db, liquidacion_id)
        if not db_liquidacion:
            return None
        
        try:
            update_data = liquidacion_data.model_dump(exclude_unset=True)
            for field, value in update_data.items():
                setattr(db_liquidacion, field, value)
            
            db.commit()
            db.refresh(db_liquidacion)
            return LiquidacionService.get_by_id(db, db_liquidacion.id)
        except IntegrityError as e:
            db.rollback()
            raise HTTPException(status_code=400, detail="Error al actualizar liquidación")
    
    @staticmethod
    def delete(db: Session, liquidacion_id: int) -> bool:
        """Eliminar liquidación"""
        db_liquidacion = db.query(LiquidacionMensual).filter(LiquidacionMensual.id == liquidacion_id).first()
        if not db_liquidacion:
            return False
        
        db.delete(db_liquidacion)
        db.commit()
        return True
    
    @staticmethod
    def count(db: Session, empresa_id: Optional[int] = None) -> int:
        """Contar liquidaciones"""
        query = db.query(LiquidacionMensual)
        if empresa_id:
            query = query.filter(LiquidacionMensual.empresa_id == empresa_id)
        return query.count()
    
    @staticmethod
    def get_resumen_anual(db: Session, empresa_id: int, year: int) -> dict:
        """Obtener resumen anual de liquidaciones"""
        liquidaciones = db.query(LiquidacionMensual).filter(
            LiquidacionMensual.empresa_id == empresa_id,
            LiquidacionMensual.periodo.like(f"{year}-%")
        ).all()
        
        if not liquidaciones:
            return {
                "empresa_id": empresa_id,
                "año": year,
                "total_liquidaciones": 0,
                "totales": {
                    "ingresos_gravados": 0.0,
                    "ingresos_exonerados": 0.0,
                    "igv_por_pagar": 0.0,
                    "renta_tercera_categoria": 0.0
                }
            }
        
        totales = {
            "ingresos_gravados": sum(l.ingresos_gravados for l in liquidaciones),
            "ingresos_exonerados": sum(l.ingresos_exonerados for l in liquidaciones),
            "igv_por_pagar": sum(l.igv_por_pagar for l in liquidaciones),
            "renta_tercera_categoria": sum(l.renta_tercera_categoria for l in liquidaciones)
        }
        
        return {
            "empresa_id": empresa_id,
            "año": year,
            "total_liquidaciones": len(liquidaciones),
            "totales": totales,
            "promedio_mensual": {k: v/len(liquidaciones) for k, v in totales.items()}
        }