import '../core/constants/api_config.dart';
import 'database_service.dart';
import '../models/historial_igv.dart';
import 'historial_igv_service.dart';

class CalculoService {
  static const double _igvRate = 0.18; // 18%

  // Obtener el saldo anterior del último cálculo
  static Future<double> obtenerSaldoAnterior() async {
    return await HistorialIGVService.obtenerUltimoSaldo();
  }

  static Future<Map<String, dynamic>> calcularIgv({
    required double ventasGravadas,
    required double compras18,
    double compras10 = 0.0,
    double saldoAnterior = 0.0,
  }) async {
    // Simular llamada asíncrona
    await Future.delayed(AppConfig.simulatedDelay);

    // Calcular IGV según la estructura del Excel
    final double igvVentas = ventasGravadas * _igvRate; // IGV de ventas (18%)
    final double igvCompras18 = compras18 * _igvRate; // IGV de compras al 18%
    final double igvCompras10 = compras10 * 0.10; // IGV de compras al 10%
    final double totalIgvCompras = igvCompras18 + igvCompras10;
    
    // Cálculo del IGV (IGV Ventas - IGV Compras)
    final double calculoIgv = igvVentas - totalIgvCompras;
    
    // IGV por cancelar considerando saldo anterior
    final double igvPorCancelar = calculoIgv - saldoAnterior;
    
    // Determinar si hay saldo a favor o IGV por pagar
    final bool tieneSaldoAFavor = igvPorCancelar < 0;
    final double saldoAFavor = tieneSaldoAFavor ? igvPorCancelar.abs() : 0.0;
    final double igvPorPagar = tieneSaldoAFavor ? 0.0 : igvPorCancelar;

    return {
      'ventas_gravadas': ventasGravadas,
      'igv_ventas': igvVentas,
      'compras_18': compras18,
      'igv_compras_18': igvCompras18,
      'compras_10': compras10,
      'igv_compras_10': igvCompras10,
      'total_igv_compras': totalIgvCompras,
      'calculo_igv': calculoIgv,
      'saldo_anterior': saldoAnterior,
      'igv_por_cancelar': igvPorCancelar,
      'tiene_saldo_a_favor': tieneSaldoAFavor,
      'saldo_a_favor': saldoAFavor,
      'igv_por_pagar': igvPorPagar,
      'tasa_igv': _igvRate,
      'fecha_calculo': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> calcularIgvPorTipo({
    required double ventasGravadas,
    required double compras18,
    double compras10 = 0.0,
    double saldoAnterior = 0.0,
    required dynamic tipoNegocio, // Acepta el enum del screen
    bool guardarEnHistorial = true, // Nuevo parámetro para controlar si se guarda
  }) async {
    // Simular llamada asíncrona
    await Future.delayed(AppConfig.simulatedDelay);

    // Determinar la tasa de IGV según el tipo de negocio
    final bool esRestauranteHotel = tipoNegocio.toString().contains('restauranteHotel');
    final double tasaVentas = esRestauranteHotel ? 0.10 : _igvRate;
    
    // Calcular IGV según el tipo de negocio
    final double igvVentas = ventasGravadas * tasaVentas;
    final double igvCompras18 = compras18 * _igvRate;
    final double igvCompras10 = compras10 * 0.10;
    final double totalIgvCompras = igvCompras18 + igvCompras10;
    
    // Cálculo del IGV (IGV Ventas - IGV Compras)
    final double calculoIgv = igvVentas - totalIgvCompras;
    
    // IGV por cancelar considerando saldo anterior
    final double igvPorCancelar = calculoIgv - saldoAnterior;
    
    // Determinar si hay saldo a favor o IGV por pagar
    final bool tieneSaldoAFavor = igvPorCancelar < 0;
    final double saldoAFavor = tieneSaldoAFavor ? igvPorCancelar.abs() : 0.0;
    final double igvPorPagar = tieneSaldoAFavor ? 0.0 : igvPorCancelar;

    final Map<String, dynamic> resultado = {
      'ventas_gravadas': ventasGravadas,
      'igv_ventas': igvVentas,
      'compras_18': compras18,
      'igv_compras_18': igvCompras18,
      'compras_10': compras10,
      'igv_compras_10': igvCompras10,
      'total_igv_compras': totalIgvCompras,
      'calculo_igv': calculoIgv,
      'saldo_anterior': saldoAnterior,
      'igv_por_cancelar': igvPorCancelar,
      'tiene_saldo_a_favor': tieneSaldoAFavor,
      'saldo_a_favor': saldoAFavor,
      'igv_por_pagar': igvPorPagar,
      'tasa_igv_ventas': tasaVentas,
      'tipo_negocio': esRestauranteHotel ? 'Restaurante/Hotel' : 'General',
      'fecha_calculo': DateTime.now().toIso8601String(),
    };

    // Guardar en historial si está habilitado
    if (guardarEnHistorial) {
      try {
        final tipoNegocioStr = esRestauranteHotel ? 'restaurante_hotel' : 'general';
        final historial = HistorialIGV.fromCalculoResult(
          calculoResult: resultado,
          tipoNegocio: tipoNegocioStr,
          observaciones: 'Cálculo automático desde ${resultado['tipo_negocio']}',
        );
        await HistorialIGVService.guardarCalculo(historial);
      } catch (e) {
        // En caso de error al guardar, no afectar el cálculo
        print('Error al guardar en historial: $e');
      }
    }

    return resultado;
  }

  static Future<Map<String, dynamic>> calcularRenta({
    required double ingresos,
    required double gastos,
    required int regimenId,
  }) async {
    // Simular llamada asíncrona
    await Future.delayed(AppConfig.simulatedDelay);

    // Obtener información del régimen
    final regimen = await DatabaseService().obtenerRegimenPorId(regimenId);
    if (regimen == null) {
      throw Exception('Régimen tributario no encontrado');
    }

    double impuestoRenta = 0.0;
    double rentaNeta = 0.0;
    double baseImponible = 0.0;
    String tipoCalculo = '';

    // Determinar el tipo de cálculo según el régimen
    final nombreRegimen = regimen.nombre.toUpperCase();
    
    if (nombreRegimen.contains('NRUS')) {
      // NRUS: No paga impuesto a la renta
      baseImponible = ingresos;
      rentaNeta = ingresos - gastos;
      impuestoRenta = 0.0;
      tipoCalculo = 'NRUS - Sin impuesto a la renta';
    } else if (nombreRegimen.contains('RER')) {
      // RER: 1.0% sobre ingresos netos (ventas)
      baseImponible = ingresos;
      rentaNeta = ingresos - gastos;
      impuestoRenta = ingresos * (regimen.tasaRenta / 100); // 1.0% sobre ventas
      tipoCalculo = 'RER - ${regimen.tasaRenta}% sobre ingresos netos';
    } else if (nombreRegimen.contains('MYPE')) {
      // MYPE: 10% sobre renta neta (después de gastos)
      rentaNeta = ingresos - gastos;
      baseImponible = rentaNeta > 0 ? rentaNeta : 0.0;
      impuestoRenta = rentaNeta > 0 ? rentaNeta * (regimen.tasaRenta / 100) : 0.0;
      tipoCalculo = 'MYPE - ${regimen.tasaRenta}% sobre renta neta';
    } else {
      // Régimen General: 29.5% sobre renta neta
      rentaNeta = ingresos - gastos;
      baseImponible = rentaNeta > 0 ? rentaNeta : 0.0;
      impuestoRenta = rentaNeta > 0 ? rentaNeta * (regimen.tasaRenta / 100) : 0.0;
      tipoCalculo = 'General - ${regimen.tasaRenta}% sobre renta neta';
    }

    final double rentaPorPagar = impuestoRenta > 0 ? impuestoRenta : 0.0;
    final double perdida = rentaNeta < 0 ? rentaNeta.abs() : 0.0;

    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'renta_neta': rentaNeta,
      'base_imponible': baseImponible,
      'impuesto_renta': impuestoRenta,
      'renta_por_pagar': rentaPorPagar,
      'perdida': perdida,
      'tasa_renta': regimen.tasaRenta,
      'regimen_nombre': regimen.nombre,
      'tipo_calculo': tipoCalculo,
      'fecha_calculo': DateTime.now().toIso8601String(),
      'tiene_perdida': rentaNeta < 0,
      'debe_pagar': rentaPorPagar > 0,
    };
  }

  static Future<Map<String, dynamic>> calcularLiquidacion({
    required double ingresos,
    required double gastos,
    required double ventasGravadas,
    required double compras18,
    double compras10 = 0.0,
    double saldoAnterior = 0.0,
    required int regimenId,
  }) async {
    // Calcular IGV e Impuesto a la Renta
    final igv = await calcularIgv(
      ventasGravadas: ventasGravadas,
      compras18: compras18,
      compras10: compras10,
      saldoAnterior: saldoAnterior,
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