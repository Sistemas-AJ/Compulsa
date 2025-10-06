#!/usr/bin/env python3
"""
Script para inicializar la base de datos con datos de ejemplo
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from db.database import SessionLocal, engine, Base
from models.regimen_tributario import RegimenTributario
from models.empresa import Empresa
from datetime import datetime

def init_database():
    """Inicializar base de datos con datos de ejemplo"""
    
    # Crear las tablas si no existen
    Base.metadata.create_all(bind=engine)
    
    # Crear sesión
    db = SessionLocal()
    
    try:
        # Verificar si ya hay datos
        existing_regimenes = db.query(RegimenTributario).count()
        if existing_regimenes > 0:
            print("La base de datos ya contiene datos. Saltando inicialización.")
            return
        
        # Crear regímenes tributarios
        regimenes = [
            RegimenTributario(
                nombre="Régimen General",
                descripcion="Para empresas con ingresos anuales mayores a 1,700 UIT",
                tasa_renta=0.295,  # 29.5%
                limite_ingresos=None,
                activo=True
            ),
            RegimenTributario(
                nombre="Régimen MYPE Tributario",
                descripcion="Para micro y pequeñas empresas hasta 1,700 UIT anuales",
                tasa_renta=0.10,   # 10%
                limite_ingresos=1700 * 4950,  # 1,700 UIT (asumiendo UIT 2024: S/ 4,950)
                activo=True
            ),
            RegimenTributario(
                nombre="Régimen Especial",
                descripcion="Para empresas con ingresos hasta 525 UIT anuales",
                tasa_renta=0.015,  # 1.5%
                limite_ingresos=525 * 4950,   # 525 UIT
                activo=True
            ),
            RegimenTributario(
                nombre="Nuevo RUS",
                descripcion="Régimen Único Simplificado para pequeños negocios",
                tasa_renta=0.0,    # Cuota fija
                limite_ingresos=96000,  # S/ 96,000 anuales
                activo=True
            )
        ]
        
        for regimen in regimenes:
            db.add(regimen)
        
        db.commit()
        
        # Crear empresas de ejemplo
        empresas_ejemplo = [
            Empresa(
                ruc="20123456789",
                razon_social="TECNOLOGÍA Y SISTEMAS SAC",
                nombre_comercial="TecSistemas",
                direccion="Av. Javier Prado Este 123, San Isidro, Lima",
                telefono="01-2345678",
                email="contacto@tecsistemas.com",
                regimen_tributario_id=1,  # Régimen General
                activo=True
            ),
            Empresa(
                ruc="10987654321",
                razon_social="COMERCIAL LÓPEZ EIRL",
                nombre_comercial="López Comercial",
                direccion="Jr. Ucayali 456, Cercado de Lima",
                telefono="01-8765432",
                email="info@lopezcomercial.com",
                regimen_tributario_id=2,  # MYPE
                activo=True
            ),
            Empresa(
                ruc="20555666777",
                razon_social="SERVICIOS MÚLTIPLES DEL SUR SRL",
                nombre_comercial="ServiSur",
                direccion="Av. El Sol 789, Cusco",
                telefono="084-123456",
                email="ventas@servisur.com",
                regimen_tributario_id=3,  # Especial
                activo=True
            )
        ]
        
        for empresa in empresas_ejemplo:
            db.add(empresa)
        
        db.commit()
        
        print("✅ Base de datos inicializada correctamente!")
        print(f"📊 Se crearon {len(regimenes)} regímenes tributarios")
        print(f"🏢 Se crearon {len(empresas_ejemplo)} empresas de ejemplo")
        
        # Mostrar datos creados
        print("\n📋 Regímenes Tributarios creados:")
        for regimen in regimenes:
            print(f"  - {regimen.nombre}: {regimen.tasa_renta*100:.1f}%")
        
        print("\n🏢 Empresas creadas:")
        for empresa in empresas_ejemplo:
            print(f"  - {empresa.razon_social} (RUC: {empresa.ruc})")
    
    except Exception as e:
        print(f"❌ Error al inicializar la base de datos: {e}")
        db.rollback()
    
    finally:
        db.close()

if __name__ == "__main__":
    init_database()