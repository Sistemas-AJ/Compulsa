from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.database import get_db
from .service import CalculoService
from .schemas import (
    CalculoIGVRequest, CalculoIGVResponse,
    CalculoRentaRequest, CalculoRentaResponse,
    CalculoCompletoRequest, CalculoCompletoResponse
)

router = APIRouter(prefix="/calculos", tags=["Cálculos Tributarios"])

@router.post("/igv", response_model=CalculoIGVResponse)
def calcular_igv(data: CalculoIGVRequest):
    """
    Calcular IGV según normativa peruana
    
    - **ingresos_gravados**: Monto total de ingresos gravados con IGV
    - **igv_compras**: IGV de compras que puede usarse como crédito fiscal
    """
    return CalculoService.calcular_igv(data)

@router.post("/renta", response_model=CalculoRentaResponse)
def calcular_renta(data: CalculoRentaRequest, db: Session = Depends(get_db)):
    """
    Calcular Impuesto a la Renta según régimen tributario
    
    - **ingresos**: Ingresos totales del período
    - **gastos**: Gastos deducibles del período
    - **regimen_id**: ID del régimen tributario de la empresa
    """
    return CalculoService.calcular_renta(db, data)

@router.post("/completo", response_model=CalculoCompletoResponse)
def calcular_completo(data: CalculoCompletoRequest, db: Session = Depends(get_db)):
    """
    Cálculo completo de IGV y Renta para una empresa en un período específico
    
    Calcula tanto el IGV como el Impuesto a la Renta basado en:
    - Los ingresos gravados y exonerados
    - Los gastos deducibles
    - El régimen tributario de la empresa
    - El IGV de compras como crédito fiscal
    """
    return CalculoService.calcular_completo(db, data)

@router.get("/tasas")
def get_tasas_tributarias():
    """Obtener las tasas tributarias actuales"""
    return {
        "igv": {
            "tasa": CalculoService.IGV_RATE,
            "porcentaje": f"{CalculoService.IGV_RATE * 100}%",
            "descripcion": "Impuesto General a las Ventas"
        },
        "observaciones": "Las tasas de renta varían según el régimen tributario"
    }