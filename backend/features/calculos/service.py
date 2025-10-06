from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import uuid
from fastapi import HTTPException

from .schemas import (
    CalculoIGVRequest, CalculoIGVResponse,
    CalculoRentaRequest, CalculoRentaResponse,
    CalculoCompletoRequest, CalculoCompletoResponse
)
# Cambiar importaciones relativas por absolutas
from db.database import get_db
from models import CalculoIGV, CalculoRenta, Empresa, RegimenTributario

class CalculoService:
    # Constantes tributarias Perú
    IGV_RATE = 0.18  # 18%
    
    @staticmethod
    def calcular_igv(data: CalculoIGVRequest) -> CalculoIGVResponse:
        """Calcular IGV según normativa peruana"""
        ingresos_gravados = data.ingresos_gravados
        igv_compras = data.igv_compras
        
        # Calcular ingresos netos (sin IGV)
        ingresos_netos = ingresos_gravados / (1 + CalculoService.IGV_RATE)
        
        # IGV generado por las ventas
        igv_ventas = ingresos_netos * CalculoService.IGV_RATE
        
        # IGV a pagar (IGV ventas - IGV compras)
        igv_por_pagar = max(0, igv_ventas - igv_compras)
        
        return CalculoIGVResponse(
            ingresos_gravados=round(ingresos_gravados, 2),
            ingresos_netos=round(ingresos_netos, 2),
            igv_ventas=round(igv_ventas, 2),
            igv_compras=round(igv_compras, 2),
            igv_por_pagar=round(igv_por_pagar, 2),
            tasa_igv=CalculoService.IGV_RATE
        )
    
    @staticmethod
    def calcular_renta(db: Session, data: CalculoRentaRequest) -> CalculoRentaResponse:
        """Calcular Impuesto a la Renta según régimen"""
        # Obtener régimen tributario
        regimen = db.query(RegimenTributario).filter(
            RegimenTributario.id == data.regimen_id,
            RegimenTributario.activo == True
        ).first()
        
        if not regimen:
            raise HTTPException(status_code=400, detail="Régimen tributario no encontrado")
        
        ingresos = data.ingresos
        gastos = data.gastos
        
        # Calcular renta neta
        renta_neta = max(0, ingresos - gastos)
        
        # Verificar límites de ingresos si aplica
        exonerado = False
        observaciones = None
        
        if regimen.limite_ingresos and ingresos > regimen.limite_ingresos:
            observaciones = f"Los ingresos superan el límite de S/ {regimen.limite_ingresos:,.2f} para este régimen"
        
        # Calcular impuesto
        if renta_neta <= 0:
            impuesto_renta = 0
            exonerado = True
            observaciones = "Sin renta gravable"
        elif regimen.nombre.upper().startswith('RUS'):
            # RUS tiene cuotas fijas, no porcentuales
            impuesto_renta = 0
            exonerado = True
            observaciones = "RUS paga cuota fija mensual"
        else:
            impuesto_renta = renta_neta * regimen.tasa_renta
        
        return CalculoRentaResponse(
            ingresos=round(ingresos, 2),
            gastos=round(gastos, 2),
            renta_neta=round(renta_neta, 2),
            tasa_aplicada=regimen.tasa_renta,
            impuesto_renta=round(impuesto_renta, 2),
            regimen_nombre=regimen.nombre,
            exonerado=exonerado,
            observaciones=observaciones
        )
    
    @staticmethod
    def calcular_completo(db: Session, data: CalculoCompletoRequest) -> CalculoCompletoResponse:
        """Cálculo completo de IGV y Renta para una empresa"""
        # Verificar que la empresa existe
        empresa = db.query(Empresa).filter(Empresa.id == data.empresa_id).first()
        if not empresa:
            raise HTTPException(status_code=400, detail="Empresa no encontrada")
        
        # Calcular IGV
        igv_data = CalculoIGVRequest(
            ingresos_gravados=data.ingresos_gravados,
            igv_compras=data.igv_compras
        )
        calculo_igv = CalculoService.calcular_igv(igv_data)
        
        # Calcular Renta (usar ingresos totales para renta)
        ingresos_totales = data.ingresos_gravados + data.ingresos_exonerados
        renta_data = CalculoRentaRequest(
            ingresos=ingresos_totales,
            gastos=data.gastos_deducibles,
            regimen_id=empresa.regimen_tributario_id
        )
        calculo_renta = CalculoService.calcular_renta(db, renta_data)
        
        # Total de tributos
        total_tributos = calculo_igv.igv_por_pagar + calculo_renta.impuesto_renta
        
        return CalculoCompletoResponse(
            empresa_id=data.empresa_id,
            periodo=data.periodo,
            calculo_igv=calculo_igv,
            calculo_renta=calculo_renta,
            total_tributos=round(total_tributos, 2)
        )
    
    @staticmethod
    def validar_periodo(periodo: str) -> bool:
        """Validar formato de período YYYY-MM"""
        try:
            year, month = periodo.split('-')
            return len(year) == 4 and year.isdigit() and 1 <= int(month) <= 12
        except:
            return False
    
    @staticmethod
    def crear_calculo_igv(db: Session, calculo_data: CalculoIGVRequest) -> CalculoIGVResponse:
        """Crear un nuevo cálculo de IGV"""
        
        # Verificar que la empresa existe
        empresa = db.query(Empresa).filter(Empresa.id == calculo_data.empresa_id).first()
        if not empresa:
            raise ValueError("Empresa no encontrada")
        
        # Obtener régimen tributario
        regimen = db.query(RegimenTributario).filter(
            RegimenTributario.id == empresa.regimen_tributario_id
        ).first()
        
        if not regimen:
            raise ValueError("Régimen tributario no encontrado")
        
        # Calcular IGV
        igv_ventas = calculo_data.ventas_gravadas * regimen.tasa_igv
        igv_compras = calculo_data.compras_gravadas * regimen.tasa_igv
        igv_por_pagar = max(0, igv_ventas - igv_compras)
        
        # Crear el cálculo
        nuevo_calculo = CalculoIGV(
            id=str(uuid.uuid4()),
            empresa_id=calculo_data.empresa_id,
            periodo=datetime.fromisoformat(calculo_data.periodo),
            ventas_gravadas=calculo_data.ventas_gravadas,
            compras_gravadas=calculo_data.compras_gravadas,
            exportaciones=calculo_data.exportaciones,
            compras_no_domiciliados=calculo_data.compras_no_domiciliados,
            igv_ventas=igv_ventas,
            igv_compras=igv_compras,
            igv_por_pagar=igv_por_pagar,
            fecha_calculo=datetime.now()
        )
        
        db.add(nuevo_calculo)
        db.commit()
        db.refresh(nuevo_calculo)
        
        return CalculoIGVResponse.model_validate(nuevo_calculo)
    
    @staticmethod
    def crear_calculo_renta(db: Session, calculo_data: CalculoRentaRequest) -> CalculoRentaResponse:
        """Crear un nuevo cálculo de Renta"""
        
        # Verificar que la empresa existe
        empresa = db.query(Empresa).filter(Empresa.id == calculo_data.empresa_id).first()
        if not empresa:
            raise ValueError("Empresa no encontrada")
        
        # Obtener régimen tributario
        regimen = db.query(RegimenTributario).filter(
            RegimenTributario.id == empresa.regimen_tributario_id
        ).first()
        
        if not regimen:
            raise ValueError("Régimen tributario no encontrado")
        
        # Calcular Renta
        renta_neta = calculo_data.ingresos - calculo_data.gastos_deducibles - calculo_data.gastos_no_deducibles
        impuesto_renta = max(0, renta_neta * regimen.tasa_renta) if renta_neta > 0 else 0
        renta_por_pagar = max(0, impuesto_renta - calculo_data.pagos_cuenta)
        
        # Crear el cálculo
        nuevo_calculo = CalculoRenta(
            id=str(uuid.uuid4()),
            empresa_id=calculo_data.empresa_id,
            periodo=datetime.fromisoformat(calculo_data.periodo),
            ingresos=calculo_data.ingresos,
            gastos_deducibles=calculo_data.gastos_deducibles,
            gastos_no_deducibles=calculo_data.gastos_no_deducibles,
            renta_neta=renta_neta,
            impuesto_renta=impuesto_renta,
            pagos_cuenta=calculo_data.pagos_cuenta,
            renta_por_pagar=renta_por_pagar,
            fecha_calculo=datetime.now()
        )
        
        db.add(nuevo_calculo)
        db.commit()
        db.refresh(nuevo_calculo)
        
        return CalculoRentaResponse.model_validate(nuevo_calculo)
    
    @staticmethod
    def obtener_calculos_igv(db: Session, empresa_id: Optional[int] = None) -> List[CalculoIGVResponse]:
        """Obtener todos los cálculos de IGV"""
        query = db.query(CalculoIGV)
        
        if empresa_id:
            query = query.filter(CalculoIGV.empresa_id == empresa_id)
        
        calculos = query.all()
        return [CalculoIGVResponse.model_validate(calculo) for calculo in calculos]
    
    @staticmethod
    def obtener_calculos_renta(db: Session, empresa_id: Optional[int] = None) -> List[CalculoRentaResponse]:
        """Obtener todos los cálculos de Renta"""
        query = db.query(CalculoRenta)
        
        if empresa_id:
            query = query.filter(CalculoRenta.empresa_id == empresa_id)
        
        calculos = query.all()
        return [CalculoRentaResponse.model_validate(calculo) for calculo in calculos]
    
    @staticmethod
    def crear_calculo_completo(db: Session, calculo_data: CalculoCompletoRequest) -> CalculoCompletoResponse:
        """Crear cálculos de IGV y Renta para el mismo período"""
        
        # Convertir período YYYY-MM a datetime
        periodo_datetime = f"{calculo_data.periodo}-01T00:00:00"
        
        # Crear cálculo de IGV
        igv_request = CalculoIGVRequest(
            empresa_id=calculo_data.empresa_id,
            periodo=periodo_datetime,
            ventas_gravadas=calculo_data.ventas_gravadas,
            compras_gravadas=calculo_data.compras_gravadas,
            exportaciones=calculo_data.exportaciones,
            compras_no_domiciliados=calculo_data.compras_no_domiciliados
        )
        
        calculo_igv = CalculoService.crear_calculo_igv(db, igv_request)
        
        # Crear cálculo de Renta
        renta_request = CalculoRentaRequest(
            empresa_id=calculo_data.empresa_id,
            periodo=periodo_datetime,
            ingresos=calculo_data.ingresos,
            gastos_deducibles=calculo_data.gastos_deducibles,
            gastos_no_deducibles=calculo_data.gastos_no_deducibles,
            pagos_cuenta=calculo_data.pagos_cuenta
        )
        
        calculo_renta = CalculoService.crear_calculo_renta(db, renta_request)
        
        # Calcular totales
        total_impuestos = calculo_igv.igv_por_pagar + calculo_renta.impuesto_renta
        total_por_pagar = calculo_igv.igv_por_pagar + calculo_renta.renta_por_pagar
        
        return CalculoCompletoResponse(
            igv=calculo_igv,
            renta=calculo_renta,
            total_impuestos=total_impuestos,
            total_por_pagar=total_por_pagar
        )