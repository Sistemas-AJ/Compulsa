// 🧪 Archivo de pruebas para la función calcularTasaRenta
// Este archivo demuestra el funcionamiento correcto de la lógica implementada

import 'lib/models/regimen_tributario.dart';

void main() {
  print('🎯 === PRUEBAS DE CALCULADORA DE TASA RENTA ===\n');
  
  // 🔹 PRUEBAS PARA RÉGIMEN GENERAL
  print('📊 RÉGIMEN GENERAL:');
  testRegimen('General con S/ 500,000', 
    RegimenTributarioEnum.general, 500000, null, 0.015);
  testRegimen('General con S/ 5,000,000', 
    RegimenTributarioEnum.general, 5000000, null, 0.015);
  print('');

  // 🔹 PRUEBAS PARA RÉGIMEN MYPE
  print('📊 RÉGIMEN MYPE:');
  
  // Casos dentro del límite (≤ S/ 1,605,000)
  testRegimen('MYPE - S/ 1,000,000 (dentro del límite)', 
    RegimenTributarioEnum.mype, 1000000, null, 0.01);
  testRegimen('MYPE - S/ 1,605,000 (exactamente el límite)', 
    RegimenTributarioEnum.mype, 1605000, null, 0.01);
  
  // Casos fuera del límite (> S/ 1,605,000)
  testRegimen('MYPE - S/ 1,800,000 sin coeficiente', 
    RegimenTributarioEnum.mype, 1800000, null, 0.015);
  testRegimen('MYPE - S/ 1,800,000 con coeficiente 1.2%', 
    RegimenTributarioEnum.mype, 1800000, 0.012, 0.012);
  testRegimen('MYPE - S/ 1,800,000 con coeficiente 1.8% (limitado)', 
    RegimenTributarioEnum.mype, 1800000, 0.018, 0.015);
  testRegimen('MYPE - S/ 2,500,000 con coeficiente 0.5%', 
    RegimenTributarioEnum.mype, 2500000, 0.005, 0.005);
  print('');

  // 🔹 PRUEBAS PARA RÉGIMEN ESPECIAL
  print('📊 RÉGIMEN ESPECIAL:');
  testRegimen('Especial con S/ 800,000', 
    RegimenTributarioEnum.especial, 800000, null, 0.015);
  testRegimen('Especial con S/ 3,000,000', 
    RegimenTributarioEnum.especial, 3000000, null, 0.015);
  print('');

  // 🔹 PRUEBAS PARA RUS
  print('📊 RUS:');
  testRegimen('RUS con S/ 500,000', 
    RegimenTributarioEnum.rus, 500000, null, 0.0);
  testRegimen('RUS con S/ 2,000,000', 
    RegimenTributarioEnum.rus, 2000000, null, 0.0);
  print('');

  // 🔹 PRUEBAS DE VALIDACIÓN DE ERRORES
  print('🔒 PRUEBAS DE VALIDACIÓN:');
  testErrorHandling();
  print('');

  // 🔹 PRUEBAS DE UTILIDADES ADICIONALES
  print('🧮 PRUEBAS DE UTILIDADES:');
  testUtilidades();
}

void testRegimen(String descripcion, RegimenTributarioEnum regimen, 
    double monto, double? coeficiente, double expected) {
  try {
    final resultado = calcularTasaRenta(regimen, monto: monto, coeficiente: coeficiente);
    final porcentaje = (resultado * 100).toStringAsFixed(2);
    final expectedPorcentaje = (expected * 100).toStringAsFixed(2);
    
    final status = (resultado == expected) ? '✅' : '❌';
    final coefStr = coeficiente != null ? ', coef: ${(coeficiente * 100).toStringAsFixed(2)}%' : '';
    
    print('  $status $descripcion$coefStr → $porcentaje% (esperado: $expectedPorcentaje%)');
    
    if (resultado != expected) {
      print('    ⚠️  ERROR: Se esperaba $expected pero se obtuvo $resultado');
    }
  } catch (e) {
    print('  ❌ $descripcion → ERROR: $e');
  }
}

void testErrorHandling() {
  print('  🔍 Probando validación de monto negativo...');
  try {
    calcularTasaRenta(RegimenTributarioEnum.mype, monto: -1000);
    print('    ❌ ERROR: Debería haber lanzado excepción');
  } catch (e) {
    print('    ✅ Excepción correcta capturada: $e');
  }

  print('  🔍 Probando validación de coeficiente negativo...');
  try {
    calcularTasaRenta(RegimenTributarioEnum.mype, monto: 2000000, coeficiente: -0.01);
    print('    ❌ ERROR: Debería haber lanzado excepción');
  } catch (e) {
    print('    ✅ Excepción correcta capturada: $e');
  }
}

void testUtilidades() {
  // Probar cálculo de impuesto
  print('  💰 Calculando impuesto MYPE (S/ 800,000 base, S/ 1,200,000 monto):');
  final impuesto = RegimenTributarioEnum.mype.calcularImpuestoRenta(
    baseImponible: 800000, 
    monto: 1200000
  );
  print('    → S/ ${impuesto.toStringAsFixed(2)} (esperado: S/ 8,000.00)');
  
  // Probar detalle de cálculo
  print('  📋 Obteniendo detalle de cálculo MYPE:');
  final detalle = RegimenTributarioEnum.mype.obtenerDetalleCalculo(
    monto: 1800000, 
    coeficiente: 0.012
  );
  print('    → ${detalle['regimen']}: ${detalle['tasa_porcentaje']}');
  print('    → ${detalle['explicacion']}');
  
  // Probar propiedades de utilidad
  print('  🎛️ Propiedades de utilidad:');
  print('    → MYPE permite coeficiente: ${RegimenTributarioEnum.mype.permiteCoeficiente}');
  print('    → MYPE límite especial: S/ ${RegimenTributarioEnum.mype.limiteMontoEspecial?.toStringAsFixed(0)}');
  print('    → General permite coeficiente: ${RegimenTributarioEnum.general.permiteCoeficiente}');
}