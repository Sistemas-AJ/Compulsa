import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/database_models.dart';
import '../models/regimen_tributario.dart';
import '../models/actividad_reciente.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Inicializar sqflite_ffi para Windows
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'Compulsa.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Crear tabla Regimenes_Tributarios
    await db.execute('''
      CREATE TABLE Regimenes_Tributarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        tasa_renta REAL NOT NULL
      )
    ''');

    // Crear tabla Empresas
    await db.execute('''
      CREATE TABLE Empresas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        regimen_id INTEGER NOT NULL,
        nombre_razon_social TEXT NOT NULL,
        ruc TEXT UNIQUE,
        FOREIGN KEY (regimen_id) REFERENCES Regimenes_Tributarios (id)
      )
    ''');

    // Crear tabla Liquidaciones_Mensuales
    await db.execute('''
      CREATE TABLE Liquidaciones_Mensuales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa_id INTEGER NOT NULL,
        periodo TEXT NOT NULL,
        total_ventas_netas REAL NOT NULL,
        total_compras_netas REAL NOT NULL,
        igv_resultante REAL NOT NULL,
        renta_calculada REAL NOT NULL,
        UNIQUE(empresa_id, periodo),
        FOREIGN KEY (empresa_id) REFERENCES Empresas (id) ON DELETE CASCADE
      )
    ''');

    // Crear tabla Saldos_Fiscales
    await db.execute('''
      CREATE TABLE Saldos_Fiscales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa_id INTEGER NOT NULL,
        periodo TEXT NOT NULL,
        monto_saldo_igv REAL NOT NULL DEFAULT 0,
        monto_saldo_renta REAL NOT NULL DEFAULT 0,
        origen TEXT,
        UNIQUE(empresa_id, periodo),
        FOREIGN KEY (empresa_id) REFERENCES Empresas (id) ON DELETE CASCADE
      )
    ''');

    // Crear tabla Pagos_Realizados
    await db.execute('''
      CREATE TABLE Pagos_Realizados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        liquidacion_id INTEGER NOT NULL,
        tipo_impuesto TEXT NOT NULL,
        monto_pagado REAL NOT NULL,
        fecha_pago TEXT NOT NULL,
        codigo_operacion TEXT,
        FOREIGN KEY (liquidacion_id) REFERENCES Liquidaciones_Mensuales (id)
      )
    ''');

    // Crear tabla Actividades_Recientes
    await db.execute('''
      CREATE TABLE Actividades_Recientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        datos TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        icono TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // Base de datos lista para uso del usuario
  }

  // ===== MÉTODOS PARA REGÍMENES TRIBUTARIOS =====
  Future<List<RegimenTributario>> obtenerRegimenes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Regimenes_Tributarios');
    
    return List.generate(maps.length, (i) {
      return RegimenTributario(
        id: maps[i]['id'],
        nombre: maps[i]['nombre'],
        tasaRenta: maps[i]['tasa_renta'],
      );
    });
  }

  Future<RegimenTributario?> obtenerRegimenPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Regimenes_Tributarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RegimenTributario(
        id: maps.first['id'],
        nombre: maps.first['nombre'],
        tasaRenta: maps.first['tasa_renta'],
      );
    }
    return null;
  }

  Future<int> insertarRegimen(RegimenTributario regimen) async {
    final db = await database;
    return await db.insert('Regimenes_Tributarios', {
      'nombre': regimen.nombre,
      'tasa_renta': regimen.tasaRenta,
    });
  }

  Future<int> actualizarRegimen(RegimenTributario regimen) async {
    final db = await database;
    return await db.update(
      'Regimenes_Tributarios',
      {
        'nombre': regimen.nombre,
        'tasa_renta': regimen.tasaRenta,
      },
      where: 'id = ?',
      whereArgs: [regimen.id],
    );
  }

  Future<int> eliminarRegimen(int id) async {
    final db = await database;
    return await db.delete(
      'Regimenes_Tributarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== MÉTODOS PARA EMPRESAS =====
  Future<int> insertarEmpresa(Empresa empresa) async {
    final db = await database;
    return await db.insert('Empresas', empresa.toJson());
  }

  Future<List<Empresa>> obtenerEmpresas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Empresas');
    
    return List.generate(maps.length, (i) {
      return Empresa.fromJson(maps[i]);
    });
  }

  Future<Empresa?> obtenerEmpresaPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Empresas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Empresa.fromJson(maps.first);
    }
    return null;
  }

  Future<int> actualizarEmpresa(Empresa empresa) async {
    final db = await database;
    return await db.update(
      'Empresas',
      empresa.toJson(),
      where: 'id = ?',
      whereArgs: [empresa.id],
    );
  }

  Future<int> eliminarEmpresa(int id) async {
    final db = await database;
    return await db.delete(
      'Empresas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== MÉTODOS PARA LIQUIDACIONES =====
  Future<int> insertarLiquidacion(LiquidacionMensual liquidacion) async {
    final db = await database;
    return await db.insert('Liquidaciones_Mensuales', liquidacion.toJson());
  }

  Future<List<LiquidacionMensual>> obtenerLiquidaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Liquidaciones_Mensuales');
    
    return List.generate(maps.length, (i) {
      return LiquidacionMensual.fromJson(maps[i]);
    });
  }

  Future<List<LiquidacionMensual>> obtenerLiquidacionesPorEmpresa(int empresaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Liquidaciones_Mensuales',
      where: 'empresa_id = ?',
      whereArgs: [empresaId],
      orderBy: 'periodo DESC',
    );
    
    return List.generate(maps.length, (i) {
      return LiquidacionMensual.fromJson(maps[i]);
    });
  }

  // ===== MÉTODOS PARA SALDOS FISCALES =====
  Future<int> insertarSaldoFiscal(SaldoFiscal saldo) async {
    final db = await database;
    return await db.insert('Saldos_Fiscales', saldo.toJson());
  }

  Future<List<SaldoFiscal>> obtenerSaldosFiscales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Saldos_Fiscales');
    
    return List.generate(maps.length, (i) {
      return SaldoFiscal.fromJson(maps[i]);
    });
  }

  // ===== MÉTODOS PARA PAGOS REALIZADOS =====
  Future<int> insertarPago(PagoRealizado pago) async {
    final db = await database;
    return await db.insert('Pagos_Realizados', pago.toJson());
  }

  Future<List<PagoRealizado>> obtenerPagos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Pagos_Realizados');
    
    return List.generate(maps.length, (i) {
      return PagoRealizado.fromJson(maps[i]);
    });
  }

  // ===== MÉTODOS PARA ACTIVIDADES RECIENTES =====
  Future<int> insertarActividad(ActividadReciente actividad) async {
    final db = await database;
    final data = actividad.toJson();
    data['datos'] = jsonEncode(data['datos']); // Convertir Map a JSON string
    return await db.insert('Actividades_Recientes', data);
  }

  Future<List<ActividadReciente>> obtenerActividadesRecientes({int limite = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Actividades_Recientes',
      orderBy: 'fecha_creacion DESC',
      limit: limite,
    );
    
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['datos'] = jsonDecode(map['datos']); // Convertir JSON string a Map
      return ActividadReciente.fromJson(map);
    });
  }

  Future<void> eliminarActividadReciente(int id) async {
    final db = await database;
    await db.delete(
      'Actividades_Recientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> limpiarActividadesAntiguas({int diasMaximos = 30}) async {
    final db = await database;
    final fechaLimite = DateTime.now().subtract(Duration(days: diasMaximos));
    await db.delete(
      'Actividades_Recientes',
      where: 'fecha_creacion < ?',
      whereArgs: [fechaLimite.toIso8601String()],
    );
  }

  // ===== MÉTODOS UTILITARIOS =====
  Future<void> cerrarDatabase() async {
    final db = await database;
    db.close();
  }

  Future<void> eliminarDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'Compulsa.db');
    await deleteDatabase(path);
  }
}