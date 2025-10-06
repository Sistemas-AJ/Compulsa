from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

class LiquidacionBase(BaseModel):
    empresa_id: int = Field(..., gt=0, description="ID de la empresa")
    periodo: str = Field(..., regex=r'^\d{4}-\d{2}$', description="Período en formato YYYY-MM")
    ingresos_gravados: float = Field(0.0, ge=0, description="Ingresos gravados")
    ingresos_exonerados: float = Field(0.0, ge=0, description="Ingresos exonerados")
    igv_ventas: float = Field(0.0, ge=0, description="IGV por ventas")
    igv_compras: float = Field(0.0, ge=0, description="IGV por compras")
    igv_por_pagar: float = Field(0.0, ge=0, description="IGV neto a pagar")
    renta_tercera_categoria: float = Field(0.0, ge=0, description="Renta de tercera categoría")
    estado: str = Field("CALCULADO", description="Estado de la liquidación")

    @validator('periodo')
    def validate_periodo(cls, v):
        try:
            year, month = v.split('-')
            if len(year) != 4 or not year.isdigit():
                raise ValueError('Año debe ser de 4 dígitos')
            if not (1 <= int(month) <= 12):
                raise ValueError('Mes debe estar entre 01 y 12')
            return v
        except:
            raise ValueError('Período debe tener formato YYYY-MM')

    @validator('estado')
    def validate_estado(cls, v):
        estados_validos = ['CALCULADO', 'DECLARADO', 'PAGADO', 'ANULADO']
        if v not in estados_validos:
            raise ValueError(f'Estado debe ser uno de: {estados_validos}')
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "empresa_id": 1,
                "periodo": "2024-01",
                "ingresos_gravados": 10000.0,
                "ingresos_exonerados": 0.0,
                "igv_ventas": 1800.0,
                "igv_compras": 900.0,
                "igv_por_pagar": 900.0,
                "renta_tercera_categoria": 1500.0,
                "estado": "CALCULADO"
            }
        }

class LiquidacionCreate(LiquidacionBase):
    pass

class LiquidacionUpdate(BaseModel):
    ingresos_gravados: Optional[float] = Field(None, ge=0)
    ingresos_exonerados: Optional[float] = Field(None, ge=0)
    igv_ventas: Optional[float] = Field(None, ge=0)
    igv_compras: Optional[float] = Field(None, ge=0)
    igv_por_pagar: Optional[float] = Field(None, ge=0)
    renta_tercera_categoria: Optional[float] = Field(None, ge=0)
    estado: Optional[str] = None

    @validator('estado')
    def validate_estado(cls, v):
        if v is not None:
            estados_validos = ['CALCULADO', 'DECLARADO', 'PAGADO', 'ANULADO']
            if v not in estados_validos:
                raise ValueError(f'Estado debe ser uno de: {estados_validos}')
        return v

class LiquidacionResponse(LiquidacionBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class LiquidacionWithEmpresaResponse(LiquidacionResponse):
    empresa: dict = Field(..., description="Información de la empresa")
    
    class Config:
        from_attributes = True