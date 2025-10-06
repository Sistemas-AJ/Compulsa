from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from db.database import Base

class CalculoIGV(Base):
    __tablename__ = "calculos_igv"
    
    id = Column(String, primary_key=True, index=True)
    empresa_id = Column(Integer, ForeignKey("empresas.id"), nullable=False)
    periodo = Column(DateTime, nullable=False)
    
    # Ventas
    ventas_gravadas = Column(Float, default=0.0)
    exportaciones = Column(Float, default=0.0)
    
    # Compras
    compras_gravadas = Column(Float, default=0.0)
    compras_no_domiciliados = Column(Float, default=0.0)
    
    # IGV calculado
    igv_ventas = Column(Float, default=0.0)
    igv_compras = Column(Float, default=0.0)
    igv_por_pagar = Column(Float, default=0.0)
    
    # Metadatos
    fecha_calculo = Column(DateTime, default=datetime.utcnow)
    finalizado = Column(Boolean, default=False)
    
    # Relaciones
    empresa = relationship("Empresa", back_populates="calculos_igv")
    
    def __repr__(self):
        return f"<CalculoIGV(id={self.id}, empresa_id={self.empresa_id}, periodo={self.periodo})>"