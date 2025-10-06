from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

# Schemas para IGV
class CalculoIGVRequest(BaseModel):
    empresa_id: int = Field(..., description="ID de la empresa")
    periodo: str = Field(..., pattern=r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$', description="Período en formato ISO datetime")
    ventas_gravadas: float = Field(..., ge=0, description="Ventas gravadas con IGV")
    compras_gravadas: float = Field(..., ge=0, description="Compras gravadas con IGV")
    exportaciones: float = Field(0.0, ge=0, description="Exportaciones (exoneradas)")
    compras_no_domiciliados: float = Field(0.0, ge=0, description="Compras a no domiciliados")

class CalculoIGVResponse(BaseModel):
    id: int
    empresa_id: int
    periodo: datetime
    ventas_gravadas: float
    compras_gravadas: float
    exportaciones: float
    compras_no_domiciliados: float
    igv_ventas: float
    igv_compras: float
    igv_por_pagar: float
    fecha_calculo: datetime
    finalizado: bool

    class Config:
        from_attributes = True

# Schemas para Renta
class CalculoRentaRequest(BaseModel):
    empresa_id: int = Field(..., description="ID de la empresa")
    periodo: str = Field(..., pattern=r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$', description="Período en formato ISO datetime")
    ingresos: float = Field(..., ge=0, description="Ingresos totales del período")
    gastos_deducibles: float = Field(..., ge=0, description="Gastos deducibles del período")
    gastos_no_deducibles: float = Field(0.0, ge=0, description="Gastos no deducibles")
    pagos_cuenta: float = Field(0.0, ge=0, description="Pagos a cuenta realizados")

class CalculoRentaResponse(BaseModel):
    id: int
    empresa_id: int
    periodo: datetime
    ingresos: float
    gastos_deducibles: float
    gastos_no_deducibles: float
    renta_neta: float
    impuesto_renta: float
    pagos_cuenta: float
    renta_por_pagar: float
    fecha_calculo: datetime
    finalizado: bool

    class Config:
        from_attributes = True

# Schema para cálculo completo (IGV + Renta)
class CalculoCompletoRequest(BaseModel):
    empresa_id: int = Field(..., description="ID de la empresa")
    periodo: str = Field(..., pattern=r'^\d{4}-\d{2}$', description="Período en formato YYYY-MM")
    
    # Datos para IGV
    ventas_gravadas: float = Field(..., ge=0)
    compras_gravadas: float = Field(..., ge=0)
    exportaciones: float = Field(0.0, ge=0)
    compras_no_domiciliados: float = Field(0.0, ge=0)
    
    # Datos para Renta
    ingresos: float = Field(..., ge=0)
    gastos_deducibles: float = Field(..., ge=0)
    gastos_no_deducibles: float = Field(0.0, ge=0)
    pagos_cuenta: float = Field(0.0, ge=0)

class CalculoCompletoResponse(BaseModel):
    igv: CalculoIGVResponse
    renta: CalculoRentaResponse
    
    # Resumen
    total_impuestos: float
    total_por_pagar: float
    
    class Config:
        from_attributes = True

# Schemas para listados
class CalculoIGVList(BaseModel):
    calculos: list[CalculoIGVResponse]
    total: int

class CalculoRentaList(BaseModel):
    calculos: list[CalculoRentaResponse]
    total: int