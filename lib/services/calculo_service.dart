import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class CalculoService {
  static Future<Map<String, dynamic>> calcularIgv({
    required double ingresosGravados,
    double igvCompras = 0.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.calculosIGV}/?ingresos_gravados=$ingresosGravados&igv_compras=$igvCompras'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al calcular IGV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> calcularRenta({
    required double ingresos,
    required double gastos,
    required int regimenId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.calculosRenta}/?ingresos=$ingresos&gastos=$gastos&regimen_id=$regimenId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al calcular renta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}