from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

class RegimenTributarioBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100, description="Nombre del régimen tributario")
    descripcion: Optional[str] = Field(None, max_length=500, description="Descripción del régimen")
    tasa_renta: float = Field(..., ge=0.0, le=1.0, description="Tasa de renta como decimal (ej: 0.295 para 29.5%)")
    limite_ingresos: Optional[float] = Field(None, ge=0, description="Límite de ingresos anuales")
    activo: bool = Field(True, description="Estado del régimen")

    @validator('tasa_renta')
    def validate_tasa_renta(cls, v):
        if v < 0 or v > 1:
            raise ValueError('La tasa de renta debe estar entre 0 y 1')
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "nombre": "Régimen General",
                "descripcion": "Para empresas con ingresos anuales mayores a 1,700 UIT",
                "tasa_renta": 0.295,
                "limite_ingresos": 8415000.0,
                "activo": True
            }
        }

class RegimenTributarioCreate(RegimenTributarioBase):
    pass

class RegimenTributarioUpdate(BaseModel):
    nombre: Optional[str] = Field(None, min_length=1, max_length=100)
    descripcion: Optional[str] = Field(None, max_length=500)
    tasa_renta: Optional[float] = Field(None, ge=0.0, le=1.0)
    limite_ingresos: Optional[float] = Field(None, ge=0)
    activo: Optional[bool] = None

class RegimenTributarioResponse(RegimenTributarioBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True