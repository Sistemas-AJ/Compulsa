from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from datetime import datetime
from db.database import Base

class Liquidacion(Base):
    __tablename__ = "liquidaciones"
    
    id = Column(Integer, primary_key=True, index=True)
    empresa_id = Column(Integer, ForeignKey("empresas.id"), nullable=False)
    periodo = Column(DateTime, nullable=False)
    
    # IGV
    igv_ventas = Column(Float, default=0.0)
    igv_compras = Column(Float, default=0.0)
    igv_por_pagar = Column(Float, default=0.0)
    
    # Renta
    renta_neta = Column(Float, default=0.0)
    impuesto_renta = Column(Float, default=0.0)
    renta_por_pagar = Column(Float, default=0.0)
    
    # Totales
    total_impuestos = Column(Float, default=0.0)
    total_por_pagar = Column(Float, default=0.0)
    
    # Estado
    estado = Column(String(50), default="BORRADOR")  # BORRADOR, CALCULADO, PRESENTADO, PAGADO
    observaciones = Column(Text, nullable=True)
    
    # Fechas
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    fecha_vencimiento = Column(DateTime, nullable=True)
    fecha_pago = Column(DateTime, nullable=True)
    
    # Metadatos
    creado_por = Column(String(100), nullable=True)
    actualizado_por = Column(String(100), nullable=True)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relaciones
    empresa = relationship("Empresa", back_populates="liquidaciones")
    
    def __repr__(self):
        return f"<Liquidacion(id={self.id}, empresa_id={self.empresa_id}, periodo={self.periodo}, estado={self.estado})>"