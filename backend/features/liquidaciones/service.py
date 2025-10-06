from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import IntegrityError
from typing import List, Optional
from fastapi import HTTPException
from models.liquidacion import Liquidacion # Se asume que este es el modelo correcto
from models.empresa import Empresa
from .schemas import LiquidacionCreate, LiquidacionUpdate

class LiquidacionService:

    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100, empresa_id: Optional[int] = None) -> List[Liquidacion]:
        """Obtener todas las liquidaciones"""
        # Se inicia la consulta con el modelo Liquidacion
        query = db.query(Liquidacion).options(joinedload(Liquidacion.empresa))

        if empresa_id:
            # CORRECCIÓN: Se filtró usando el modelo correcto 'Liquidacion'
            query = query.filter(Liquidacion.empresa_id == empresa_id)

        return query.offset(skip).limit(limit).all()

    @staticmethod
    def get_by_id(db: Session, liquidacion_id: int) -> Optional[Liquidacion]:
        """Obtener liquidación por ID"""
        return db.query(Liquidacion).options(
            joinedload(Liquidacion.empresa)
        ).filter(Liquidacion.id == liquidacion_id).first()

    @staticmethod
    def get_by_empresa_periodo(db: Session, empresa_id: int, periodo: str) -> Optional[Liquidacion]:
        """Obtener liquidación por empresa y período"""
        return db.query(Liquidacion).filter(
            Liquidacion.empresa_id == empresa_id,
            Liquidacion.periodo == periodo
        ).first()

    @staticmethod
    def get_by_periodo(db: Session, periodo: str, skip: int = 0, limit: int = 100) -> List[Liquidacion]:
        """Obtener liquidaciones por período"""
        # CORRECCIÓN: Se cambió 'LiquidacionMensual' por 'Liquidacion'
        return db.query(Liquidacion).options(
            joinedload(Liquidacion.empresa)
        ).filter(Liquidacion.periodo == periodo).offset(skip).limit(limit).all()

    @staticmethod
    def create(db: Session, liquidacion_data: LiquidacionCreate) -> Liquidacion:
        """Crear nueva liquidación"""
        # Verificar que la empresa existe
        empresa = db.query(Empresa).filter(Empresa.id == liquidacion_data.empresa_id).first()
        if not empresa:
            raise HTTPException(status_code=404, detail="Empresa no encontrada")

        # Verificar que no existe una liquidación para ese período
        existing = LiquidacionService.get_by_empresa_periodo(
            db, liquidacion_data.empresa_id, liquidacion_data.periodo
        )
        if existing:
            raise HTTPException(
                status_code=409, # 409 Conflict es más apropiado aquí
                detail=f"Ya existe una liquidación para la empresa {liquidacion_data.empresa_id} en el período {liquidacion_data.periodo}"
            )

        try:
            # CORRECCIÓN: Se usó 'Liquidacion' para crear la instancia
            db_liquidacion = Liquidacion(**liquidacion_data.model_dump())
            db.add(db_liquidacion)
            db.commit()
            db.refresh(db_liquidacion)
            # El objeto refrescado ya contiene la relación cargada si se configura correctamente
            return db_liquidacion
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=400, detail="Error de integridad de datos al crear la liquidación.")

    @staticmethod
    def update(db: Session, liquidacion_id: int, liquidacion_data: LiquidacionUpdate) -> Optional[Liquidacion]:
        """Actualizar liquidación"""
        db_liquidacion = LiquidacionService.get_by_id(db, liquidacion_id)
        if not db_liquidacion:
            return None

        update_data = liquidacion_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_liquidacion, field, value)

        db.commit()
        db.refresh(db_liquidacion)
        return db_liquidacion

    @staticmethod
    def delete(db: Session, liquidacion_id: int) -> bool:
        """Eliminar liquidación"""
        # CORRECCIÓN: Se usó 'Liquidacion' para buscar el objeto a eliminar
        db_liquidacion = db.query(Liquidacion).filter(Liquidacion.id == liquidacion_id).first()
        if not db_liquidacion:
            return False

        db.delete(db_liquidacion)
        db.commit()
        return True

    @staticmethod
    def count(db: Session, empresa_id: Optional[int] = None) -> int:
        """Contar liquidaciones"""
        # CORRECCIÓN: Se usó 'Liquidacion' para la consulta
        query = db.query(Liquidacion)
        if empresa_id:
            query = query.filter(Liquidacion.empresa_id == empresa_id)
        return query.count()

    @staticmethod
    def get_resumen_anual(db: Session, empresa_id: int, year: int) -> dict:
        """Obtener resumen anual de liquidaciones"""
        # CORRECCIÓN: Se usó 'Liquidacion' para la consulta
        liquidaciones = db.query(Liquidacion).filter(
            Liquidacion.empresa_id == empresa_id,
            Liquidacion.periodo.like(f"{year}-%")
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
                },
                "promedio_mensual": {}
            }

        totales = {
            "ingresos_gravados": sum(l.ingresos_gravados for l in liquidaciones),
            "ingresos_exonerados": sum(l.ingresos_exonerados for l in liquidaciones),
            "igv_por_pagar": sum(l.igv_por_pagar for l in liquidaciones),
            "renta_tercera_categoria": sum(l.renta_tercera_categoria for l in liquidaciones)
        }

        total_count = len(liquidaciones)
        return {
            "empresa_id": empresa_id,
            "año": year,
            "total_liquidaciones": total_count,
            "totales": totales,
            "promedio_mensual": {k: v / total_count for k, v in totales.items()}
        }