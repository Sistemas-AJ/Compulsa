import '../core/constants/api_config.dart';
import 'regimen_tributario_service.dart';

class CalculoService {
  static const double _igvRate = 0.18; // 18%

  static Future<Map<String, dynamic>> calcularIgv({
    required double ingresosGravados,
    double igvCompras = 0.0,
  }) async {
    // Simular llamada asíncrona
    await Future.delayed(AppConfig.simulatedDelay);

    final double igvVentas = ingresosGravados * _igvRate;
    final double igvPorPagar = igvVentas - igvCompras;
    final double saldoAFavor = igvPorPagar < 0 ? igvPorPagar.abs() : 0.0;
    final double igvAPagar = igvPorPagar > 0 ? igvPorPagar : 0.0;

    return {
      'ingresos_gravados': ingresosGravados,
      'igv_ventas': igvVentas,
      'igv_compras': igvCompras,
      'igv_por_pagar': igvAPagar,
      'saldo_a_favor': saldoAFavor,
      'tasa_igv': _igvRate,
      'fecha_calculo': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> calcularRenta({
    required double ingresos,
    required double gastos,
    required int regimenId,
  }) async {
    // Simular llamada asíncrona
    await Future.delayed(AppConfig.simulatedDelay);

    // Obtener información del régimen
    final regimen = await RegimenTributarioService.getRegimenById(regimenId);
    if (regimen == null) {
      throw Exception('Régimen tributario no encontrado');
    }

    final double rentaNeta = ingresos - gastos;
    final double impuestoRenta = rentaNeta > 0 ? rentaNeta * regimen.tasaRenta : 0.0;
    final double rentaPorPagar = impuestoRenta > 0 ? impuestoRenta : 0.0;
    final double perdida = rentaNeta < 0 ? rentaNeta.abs() : 0.0;

    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'renta_neta': rentaNeta,
      'impuesto_renta': impuestoRenta,
      'renta_por_pagar': rentaPorPagar,
      'perdida': perdida,
      'tasa_renta': regimen.tasaRenta,
      'regimen_nombre': regimen.nombre,
      'fecha_calculo': DateTime.now().toIso8601String(),
      'tiene_perdida': rentaNeta < 0,
      'debe_pagar': rentaPorPagar > 0,
    };
  }

  static Future<Map<String, dynamic>> calcularLiquidacion({
    required double ingresos,
    required double gastos,
    required double ingresosGravados,
    required double igvCompras,
    required int regimenId,
  }) async {
    // Calcular IGV e Impuesto a la Renta
    final igv = await calcularIgv(
      ingresosGravados: ingresosGravados,
      igvCompras: igvCompras,
    );

    final renta = await calcularRenta(
      ingresos: ingresos,
      gastos: gastos,
      regimenId: regimenId,
    );

    return {
      'igv': igv,
      'renta': renta,
      'total_por_pagar': (igv['igv_por_pagar'] as double) + (renta['renta_por_pagar'] as double),
      'fecha_calculo': DateTime.now().toIso8601String(),
    };
  }
}