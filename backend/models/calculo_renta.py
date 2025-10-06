from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from db.database import Base

class CalculoRenta(Base):
    __tablename__ = "calculos_renta"
    
    id = Column(String, primary_key=True, index=True)
    empresa_id = Column(Integer, ForeignKey("empresas.id"), nullable=False)
    periodo = Column(DateTime, nullable=False)
    
    # Ingresos y gastos
    ingresos = Column(Float, default=0.0)
    gastos_deducibles = Column(Float, default=0.0)
    gastos_no_deducibles = Column(Float, default=0.0)
    
    # Renta calculada
    renta_neta = Column(Float, default=0.0)
    impuesto_renta = Column(Float, default=0.0)
    
    # Pagos
    pagos_cuenta = Column(Float, default=0.0)
    renta_por_pagar = Column(Float, default=0.0)
    
    # Metadatos
    fecha_calculo = Column(DateTime, default=datetime.utcnow)
    finalizado = Column(Boolean, default=False)
    
    # Relaciones
    empresa = relationship("Empresa", back_populates="calculos_renta")
    
    def __repr__(self):
        return f"<CalculoRenta(id={self.id}, empresa_id={self.empresa_id}, periodo={self.periodo})>"