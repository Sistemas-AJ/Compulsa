import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/regimen_tributario.dart';

class RegimenTributarioService {
  static Future<List<RegimenTributario>> getAllRegimenes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.regimenes}/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RegimenTributario.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar regímenes tributarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<RegimenTributario> getRegimenById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.regimenes}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return RegimenTributario.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Régimen tributario no encontrado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}