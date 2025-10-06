from sqlalchemy import Column, Integer, String, Float, Boolean, Text
from sqlalchemy.orm import relationship
from ..db.database import Base

class RegimenTributario(Base):
    __tablename__ = "regimenes_tributarios"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False, unique=True)
    descripcion = Column(Text, nullable=True)
    
    # Tasas tributarias
    tasa_igv = Column(Float, default=0.18)  # 18%
    tasa_renta = Column(Float, nullable=False)
    
    # Límites
    limite_ingresos = Column(Float, nullable=True)  # Límite anual de ingresos
    limite_activos = Column(Float, nullable=True)   # Límite de activos
    limite_trabajadores = Column(Integer, nullable=True)  # Límite de trabajadores
    
    # Estado
    activo = Column(Boolean, default=True)
    
    # Configuraciones específicas
    requiere_libros = Column(Boolean, default=True)
    periodicidad_pago = Column(String(20), default="MENSUAL")  # MENSUAL, ANUAL
    
    # Relaciones
    empresas = relationship("Empresa", back_populates="regimen_tributario")
    
    def __repr__(self):
        return f"<RegimenTributario(id={self.id}, nombre={self.nombre}, tasa_renta={self.tasa_renta})>"