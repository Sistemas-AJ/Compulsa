from pydantic import BaseModel, Field, validator, EmailStr
from typing import Optional
from datetime import datetime
import re

class EmpresaBase(BaseModel):
    ruc: str = Field(..., min_length=11, max_length=11, description="RUC de 11 dígitos")
    razon_social: str = Field(..., min_length=1, max_length=200, description="Razón social de la empresa")
    nombre_comercial: Optional[str] = Field(None, max_length=200, description="Nombre comercial")
    direccion: Optional[str] = Field(None, max_length=500, description="Dirección de la empresa")
    telefono: Optional[str] = Field(None, max_length=20, description="Teléfono de contacto")
    email: Optional[EmailStr] = Field(None, description="Correo electrónico")
    regimen_tributario_id: int = Field(..., gt=0, description="ID del régimen tributario")
    activo: bool = Field(True, description="Estado de la empresa")

    @validator('ruc')
    def validate_ruc(cls, v):
        if not v.isdigit():
            raise ValueError('El RUC debe contener solo números')
        if len(v) != 11:
            raise ValueError('El RUC debe tener exactamente 11 dígitos')
        
        # Validación básica de RUC peruano
        if not v.startswith(('10', '15', '17', '20')):
            raise ValueError('RUC no válido: debe empezar con 10, 15, 17 o 20')
        
        return v

    @validator('telefono')
    def validate_telefono(cls, v):
        if v is not None:
            # Remover espacios y caracteres especiales
            clean_phone = re.sub(r'[^\d\+]', '', v)
            if len(clean_phone) < 6:
                raise ValueError('Teléfono debe tener al menos 6 dígitos')
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "ruc": "20123456789",
                "razon_social": "TECNOLOGÍA Y SISTEMAS SAC",
                "nombre_comercial": "TecSistemas",
                "direccion": "Av. Javier Prado Este 123, San Isidro, Lima",
                "telefono": "01-2345678",
                "email": "contacto@tecsistemas.com",
                "regimen_tributario_id": 1,
                "activo": True
            }
        }

class EmpresaCreate(EmpresaBase):
    pass

class EmpresaUpdate(BaseModel):
    ruc: Optional[str] = Field(None, min_length=11, max_length=11)
    razon_social: Optional[str] = Field(None, min_length=1, max_length=200)
    nombre_comercial: Optional[str] = Field(None, max_length=200)
    direccion: Optional[str] = Field(None, max_length=500)
    telefono: Optional[str] = Field(None, max_length=20)
    email: Optional[EmailStr] = None
    regimen_tributario_id: Optional[int] = Field(None, gt=0)
    activo: Optional[bool] = None

    @validator('ruc')
    def validate_ruc(cls, v):
        if v is not None:
            if not v.isdigit():
                raise ValueError('El RUC debe contener solo números')
            if len(v) != 11:
                raise ValueError('El RUC debe tener exactamente 11 dígitos')
            if not v.startswith(('10', '15', '17', '20')):
                raise ValueError('RUC no válido: debe empezar con 10, 15, 17 o 20')
        return v

class EmpresaResponse(EmpresaBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class EmpresaWithRegimenResponse(EmpresaResponse):
    regimen_tributario: dict = Field(..., description="Información del régimen tributario")
    
    class Config:
        from_attributes = True