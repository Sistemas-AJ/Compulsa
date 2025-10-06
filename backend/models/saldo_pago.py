from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from db.database import Base

class SaldoFiscal(Base):
    __tablename__ = "saldos_fiscales"
    
    id = Column(Integer, primary_key=True, index=True)
    empresa_id = Column(Integer, ForeignKey("empresas.id"), nullable=False)
    tipo_tributo = Column(String(20), nullable=False)  # IGV, RENTA
    saldo_favor = Column(Float, default=0.0)
    saldo_contra = Column(Float, default=0.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    empresa = relationship("Empresa", backref="saldos_fiscales")

class PagoRealizado(Base):
    __tablename__ = "pagos_realizados"
    
    id = Column(Integer, primary_key=True, index=True)
    liquidacion_id = Column(Integer, ForeignKey("liquidaciones_mensuales.id"), nullable=False)
    tipo_tributo = Column(String(20), nullable=False)
    monto_pagado = Column(Float, nullable=False)
    fecha_pago = Column(DateTime, nullable=False)
    numero_recibo = Column(String(50))
    observaciones = Column(String(500))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    liquidacion = relationship("LiquidacionMensual", backref="pagos")