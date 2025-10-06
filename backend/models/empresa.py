from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from ..db.database import Base

class Empresa(Base):
    __tablename__ = "empresas"
    
    id = Column(Integer, primary_key=True, index=True)
    ruc = Column(String(11), unique=True, index=True, nullable=False)
    razon_social = Column(String(200), nullable=False)
    nombre_comercial = Column(String(200), nullable=True)
    direccion = Column(String(300), nullable=True)
    telefono = Column(String(20), nullable=True)
    email = Column(String(100), nullable=True)
    
    # Régimen tributario
    regimen_tributario_id = Column(Integer, ForeignKey("regimenes_tributarios.id"), nullable=False)
    
    # Estado
    activo = Column(Boolean, default=True)
    fecha_inscripcion = Column(DateTime, default=datetime.utcnow)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relaciones
    regimen_tributario = relationship("RegimenTributario", back_populates="empresas")
    calculos_igv = relationship("CalculoIGV", back_populates="empresa")
    calculos_renta = relationship("CalculoRenta", back_populates="empresa")
    liquidaciones = relationship("Liquidacion", back_populates="empresa")
    
    def __repr__(self):
        return f"<Empresa(id={self.id}, ruc={self.ruc}, razon_social={self.razon_social})>"