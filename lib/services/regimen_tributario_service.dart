import '../core/constants/api_config.dart';
import '../models/regimen_tributario.dart';
import 'database_service.dart';

class RegimenTributarioService {


  static final DatabaseService _databaseService = DatabaseService();

  static Future<List<RegimenTributario>> getAllRegimenes() async {
    await Future.delayed(AppConfig.simulatedDelay);
    return await _databaseService.obtenerRegimenes();
  }

  static Future<RegimenTributario?> getRegimenById(int id) async {
    await Future.delayed(AppConfig.simulatedDelay);
    return await _databaseService.obtenerRegimenPorId(id);
  }

  static Future<int> createRegimen(RegimenTributario regimen) async {
    await Future.delayed(AppConfig.simulatedDelay);
    return await _databaseService.insertarRegimen(regimen);
  }

  static Future<int> updateRegimen(RegimenTributario regimen) async {
    await Future.delayed(AppConfig.simulatedDelay);
    return await _databaseService.actualizarRegimen(regimen);
  }

  static Future<int> deleteRegimen(int id) async {
    await Future.delayed(AppConfig.simulatedDelay);
    return await _databaseService.eliminarRegimen(id);
  }
}