import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/empresa.dart';

class EmpresaService {
  static Future<List<Empresa>> getAllEmpresas() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.empresas}/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Empresa.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar empresas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Empresa> createEmpresa(Empresa empresa) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.empresas}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(empresa.toJson()),
      );

      if (response.statusCode == 200) {
        return Empresa.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear empresa');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Empresa> updateEmpresa(int id, Empresa empresa) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.empresas}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(empresa.toJson()),
      );

      if (response.statusCode == 200) {
        return Empresa.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar empresa');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> deleteEmpresa(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.empresas}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar empresa');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Empresa> getEmpresaByRuc(String ruc) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.empresas}/ruc/$ruc'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Empresa.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Empresa no encontrada');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}