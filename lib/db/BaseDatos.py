import sqlite3
import os

DB_NOMBRE = "Compulsa.db"

def crear_estructura_db():
    """
    Crea la base de datos 'Compulsa.db' con 5 tablas vacías,
    listas para ser utilizadas por la aplicación.
    Solo se pre-cargan los regímenes tributarios, que son datos base.
    """
    # Si la base de datos ya existe, se elimina para asegurar una creación limpia
    if os.path.exists(DB_NOMBRE):
        os.remove(DB_NOMBRE)
        print(f"Base de datos '{DB_NOMBRE}' existente eliminada para crear una nueva estructura.")

    try:
        # Conectar a la base de datos (se crea el archivo si no existe)
        conn = sqlite3.connect(DB_NOMBRE)
        cursor = conn.cursor()
        print(f"Base de datos '{DB_NOMBRE}' creada y conectada.")

        # Habilitar el uso de llaves foráneas (fundamental para las relaciones)
        cursor.execute("PRAGMA foreign_keys = ON;")

        # --- Creación de la Tabla 1: Regimenes_Tributarios ---
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS Regimenes_Tributarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL UNIQUE,
            tasa_renta REAL NOT NULL
        );
        ''')

        # --- Creación de la Tabla 2: Empresas ---
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS Empresas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            regimen_id INTEGER NOT NULL,
            nombre_razon_social TEXT NOT NULL,
            ruc TEXT UNIQUE,
            FOREIGN KEY (regimen_id) REFERENCES Regimenes_Tributarios (id)
        );
        ''')

        # --- Creación de la Tabla 3: Liquidaciones_Mensuales ---
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS Liquidaciones_Mensuales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            empresa_id INTEGER NOT NULL,
            periodo TEXT NOT NULL,
            total_ventas_netas REAL NOT NULL,
            total_compras_netas REAL NOT NULL,
            igv_resultante REAL NOT NULL,
            renta_calculada REAL NOT NULL,
            UNIQUE(empresa_id, periodo),
            FOREIGN KEY (empresa_id) REFERENCES Empresas (id) ON DELETE CASCADE
        );
        ''')

        # --- Creación de la Tabla 4: Saldos_Fiscales ---
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS Saldos_Fiscales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            empresa_id INTEGER NOT NULL,
            periodo TEXT NOT NULL,
            monto_saldo_igv REAL NOT NULL DEFAULT 0,
            monto_saldo_renta REAL NOT NULL DEFAULT 0,
            origen TEXT,
            UNIQUE(empresa_id, periodo),
            FOREIGN KEY (empresa_id) REFERENCES Empresas (id) ON DELETE CASCADE
        );
        ''')
        
        # --- Creación de la Tabla 5: Pagos_Realizados ---
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS Pagos_Realizados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            liquidacion_id INTEGER NOT NULL,
            tipo_impuesto TEXT NOT NULL,
            monto_pagado REAL NOT NULL,
            fecha_pago TEXT NOT NULL,
            codigo_operacion TEXT,
            FOREIGN KEY (liquidacion_id) REFERENCES Liquidaciones_Mensuales (id)
        );
        ''')
        
        print("¡Éxito! Las 5 tablas han sido creadas correctamente.")

        # --- Inserción de datos base (esenciales para el funcionamiento) ---
        regimenes = [
            ('Régimen Especial de Renta (RER)', 0.015),
            ('Régimen MYPE Tributario (RMT)', 0.01),
            ('Régimen General (RG)', 0.015),
            ('Nuevo Régimen Único Simplificado (NRUS)', 0.0)
        ]
        cursor.executemany('INSERT INTO Regimenes_Tributarios (nombre, tasa_renta) VALUES (?, ?)', regimenes)
        print("Datos base de regímenes tributarios insertados.")

        # Guardar todos los cambios
        conn.commit()
        print("\nEstructura de la base de datos guardada en 'Compulsa.db'.")

    except sqlite3.Error as e:
        print(f"Error al crear la base de datos: {e}")

    finally:
        # Cerrar la conexión
        if conn:
            conn.close()
            print("Conexión a la base de datos cerrada.")

# --- Ejecutar la función ---
if __name__ == '__main__':
    crear_estructura_db()