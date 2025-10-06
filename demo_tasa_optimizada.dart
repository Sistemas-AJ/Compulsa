// 🎯 Demostración de la función calcularTasaRenta integrada
// Este archivo muestra cómo usar la nueva función optimizada

import 'lib/models/regimen_tributario.dart';

void main() async {
  print('🎯 === DEMOSTRACIÓN DE FUNCIÓN CALCULAR TASA RENTA ===\n');
  
  // 🚀 CASOS DE USO BÁSICOS
  print('📊 CASOS DE USO BÁSICOS:');
  await demoBasico();
  print('');
  
  // 🔧 CASOS AVANZADOS PARA MYPE
  print('📊 CASOS AVANZADOS MYPE:');
  await demoMyPEAvanzado();
  print('');
  
  // 🧮 UTILIDADES Y HELPERS
  print('📊 UTILIDADES ADICIONALES:');
  await demoUtilidades();
  print('');
  
  // ⚡ COMPARACIÓN CON LÓGICA ANTERIOR
  print('📊 COMPARACIÓN DE RENDIMIENTO:');
  await demoComparacion();
}

Future<void> demoBasico() async {
  print('  🔹 Régimen General:');
  final tasaGeneral1 = calcularTasaRenta(RegimenTributarioEnum.general, monto: 500000);
  final tasaGeneral2 = calcularTasaRenta(RegimenTributarioEnum.general, monto: 5000000);
  print('    → S/ 500,000: ${(tasaGeneral1 * 100).toStringAsFixed(2)}%');
  print('    → S/ 5,000,000: ${(tasaGeneral2 * 100).toStringAsFixed(2)}%');
  
  print('  🔹 RUS:');
  final tasaRUS = calcularTasaRenta(RegimenTributarioEnum.rus, monto: 800000);
  print('    → S/ 800,000: ${(tasaRUS * 100).toStringAsFixed(2)}%');
  
  print('  🔹 Régimen Especial:');
  final tasaEspecial = calcularTasaRenta(RegimenTributarioEnum.especial, monto: 1200000);
  print('    → S/ 1,200,000: ${(tasaEspecial * 100).toStringAsFixed(2)}%');
}

Future<void> demoMyPEAvanzado() async {
  print('  💰 MYPE - Casos dentro del límite (≤ S/ 1,605,000):');
  final tasaMyPE1 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 1000000);
  final tasaMyPE2 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 1605000);
  print('    → S/ 1,000,000: ${(tasaMyPE1 * 100).toStringAsFixed(2)}%');
  print('    → S/ 1,605,000: ${(tasaMyPE2 * 100).toStringAsFixed(2)}%');
  
  print('  💸 MYPE - Casos fuera del límite (> S/ 1,605,000):');
  final tasaMyPE3 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 2000000);
  final tasaMyPE4 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 2000000, coeficiente: 0.012);
  final tasaMyPE5 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 2000000, coeficiente: 0.020);
  print('    → S/ 2,000,000 sin coeficiente: ${(tasaMyPE3 * 100).toStringAsFixed(2)}%');
  print('    → S/ 2,000,000 coef. 1.2%: ${(tasaMyPE4 * 100).toStringAsFixed(2)}%');
  print('    → S/ 2,000,000 coef. 2.0% (limitado): ${(tasaMyPE5 * 100).toStringAsFixed(2)}%');
  
  print('  🎯 MYPE - Casos límite y especiales:');
  final tasaMyPE6 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 1605001); // 1 sol más
  final tasaMyPE7 = calcularTasaRenta(RegimenTributarioEnum.mype, monto: 3000000, coeficiente: 0.005);
  print('    → S/ 1,605,001 (1 sol más del límite): ${(tasaMyPE6 * 100).toStringAsFixed(2)}%');
  print('    → S/ 3,000,000 coef. 0.5%: ${(tasaMyPE7 * 100).toStringAsFixed(2)}%');
}

Future<void> demoUtilidades() async {
  print('  🧮 Cálculo de impuesto directo:');
  final impuestoMyPE = RegimenTributarioEnum.mype.calcularImpuestoRenta(
    baseImponible: 800000,
    monto: 1200000,
  );
  print('    → MYPE: Base S/ 800,000, Ingresos S/ 1,200,000');
  print('    → Impuesto: S/ ${impuestoMyPE.toStringAsFixed(2)}');
  
  print('  📋 Detalle completo de cálculo:');
  final detalle = RegimenTributarioEnum.mype.obtenerDetalleCalculo(
    monto: 2500000,
    coeficiente: 0.008,
  );
  print('    → ${detalle['regimen']}: ${detalle['tasa_porcentaje']}');
  print('    → ${detalle['explicacion']}');
  
  print('  🎛️ Propiedades de regímenes:');
  for (final regimen in RegimenTributarioEnum.values) {
    print('    → ${regimen.nombre}:');
    print('      - Permite coeficiente: ${regimen.permiteCoeficiente}');
    print('      - Límite especial: ${regimen.limiteMontoEspecial != null ? 'S/ ${regimen.limiteMontoEspecial!.toStringAsFixed(0)}' : 'N/A'}');
  }
}

Future<void> demoComparacion() async {
  final casos = [
    {'regimen': RegimenTributarioEnum.general, 'monto': 1000000.0, 'coef': null},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 1500000.0, 'coef': null},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 2000000.0, 'coef': 0.012},
    {'regimen': RegimenTributarioEnum.especial, 'monto': 800000.0, 'coef': null},
    {'regimen': RegimenTributarioEnum.rus, 'monto': 500000.0, 'coef': null},
  ];
  
  print('  ⚡ Midiendo rendimiento (${casos.length} cálculos):');
  final stopwatch = Stopwatch()..start();
  
  for (final caso in casos) {
    final regimen = caso['regimen'] as RegimenTributarioEnum;
    final monto = caso['monto'] as double;
    final coeficiente = caso['coef'] as double?;
    
    final tasa = calcularTasaRenta(regimen, monto: monto, coeficiente: coeficiente);
    final impuesto = regimen.calcularImpuestoRenta(
      baseImponible: monto * 0.8, // Asumiendo 80% de renta neta
      monto: monto,
      coeficiente: coeficiente,
    );
    
    print('    → ${regimen.nombre}: ${(tasa * 100).toStringAsFixed(2)}% | Impuesto: S/ ${impuesto.toStringAsFixed(2)}');
  }
  
  stopwatch.stop();
  print('    ⏱️  Tiempo total: ${stopwatch.elapsedMicroseconds} μs');
  print('    📊 Promedio por cálculo: ${(stopwatch.elapsedMicroseconds / casos.length).toStringAsFixed(1)} μs');
}

// 🎯 Función de validación exhaustiva
void validarFuncion() {
  print('🔍 === VALIDACIÓN EXHAUSTIVA ===\n');
  
  final testCases = [
    // Casos válidos
    {'regimen': RegimenTributarioEnum.general, 'monto': 1000000.0, 'coef': null, 'expected': 0.015, 'descripcion': 'General básico'},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 1000000.0, 'coef': null, 'expected': 0.01, 'descripcion': 'MYPE dentro límite'},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 2000000.0, 'coef': null, 'expected': 0.015, 'descripcion': 'MYPE fuera límite sin coef'},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 2000000.0, 'coef': 0.012, 'expected': 0.012, 'descripcion': 'MYPE con coef menor'},
    {'regimen': RegimenTributarioEnum.mype, 'monto': 2000000.0, 'coef': 0.020, 'expected': 0.015, 'descripcion': 'MYPE con coef limitado'},
    {'regimen': RegimenTributarioEnum.rus, 'monto': 500000.0, 'coef': null, 'expected': 0.0, 'descripcion': 'RUS básico'},
  ];
  
  int passed = 0;
  int total = testCases.length;
  
  for (final testCase in testCases) {
    final regimen = testCase['regimen'] as RegimenTributarioEnum;
    final monto = testCase['monto'] as double;
    final coeficiente = testCase['coef'] as double?;
    final expected = testCase['expected'] as double;
    final descripcion = testCase['descripcion'] as String;
    
    try {
      final resultado = calcularTasaRenta(regimen, monto: monto, coeficiente: coeficiente);
      
      if ((resultado - expected).abs() < 0.0001) { // Tolerancia para decimales
        print('✅ $descripcion: PASÓ');
        passed++;
      } else {
        print('❌ $descripcion: FALLÓ (esperado: $expected, obtuvo: $resultado)');
      }
    } catch (e) {
      print('💥 $descripcion: ERROR - $e');
    }
  }
  
  print('\n🎯 Resultado: $passed/$total pruebas pasaron (${(passed/total*100).toStringAsFixed(1)}%)');
}