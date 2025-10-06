import '../core/constants/api_config.dart';
import '../models/regimen_tributario.dart';

class RegimenTributarioService {
  // Datos locales de regímenes tributarios
  static final List<RegimenTributario> _regimenes = [
    RegimenTributario(
      id: 1,
      nombre: 'Régimen General',
      descripcion: 'Régimen para empresas grandes con facturación anual superior a 1,700 UIT',
      tasaRenta: 0.29,
      limiteIngresos: null, // Sin límite
      activo: true,
    ),
    RegimenTributario(
      id: 2,
      nombre: 'Régimen MYPE Tributario',
      descripcion: 'Régimen para micro y pequeñas empresas con ingresos hasta 1,700 UIT',
      tasaRenta: 0.10,
      limiteIngresos: 1700,
      activo: true,
    ),
    RegimenTributario(
      id: 3,
      nombre: 'Régimen Especial de Renta',
      descripcion: 'Régimen para empresas con ingresos hasta 525 UIT',
      tasaRenta: 0.015,
      limiteIngresos: 525,
      activo: true,
    ),
    RegimenTributario(
      id: 4,
      nombre: 'Nuevo RUS',
      descripcion: 'Régimen Único Simplificado para pequeños contribuyentes',
      tasaRenta: 0.0,
      limiteIngresos: 96,
      activo: true,
    ),
  ];

  static Future<List<RegimenTributario>> getAllRegimenes() async {
    await Future.delayed(AppConfig.simulatedDelay);
    return List<RegimenTributario>.from(_regimenes.where((r) => r.activo));
  }

  static Future<RegimenTributario?> getRegimenById(int id) async {
    await Future.delayed(AppConfig.simulatedDelay);
    
    try {
      return _regimenes.firstWhere((regimen) => regimen.id == id && regimen.activo);
    } catch (e) {
      return null;
    }
  }

  static Future<RegimenTributario> createRegimen(RegimenTributario regimen) async {
    await Future.delayed(AppConfig.simulatedDelay);
    
    // Validar nombre único
    if (_regimenes.any((r) => r.nombre == regimen.nombre)) {
      throw Exception('Ya existe un régimen con este nombre');
    }
    
    final newRegimen = regimen.copyWith(
      id: _regimenes.length + 1,
    );
    
    _regimenes.add(newRegimen);
    return newRegimen;
  }

  static Future<RegimenTributario> updateRegimen(int id, RegimenTributario regimen) async {
    await Future.delayed(AppConfig.simulatedDelay);
    
    final index = _regimenes.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Régimen no encontrado');
    }
    
    // Validar nombre único (excluyendo el régimen actual)
    if (_regimenes.any((r) => r.nombre == regimen.nombre && r.id != id)) {
      throw Exception('Ya existe otro régimen con este nombre');
    }
    
    final updatedRegimen = regimen.copyWith(id: id);
    _regimenes[index] = updatedRegimen;
    return updatedRegimen;
  }

  static Future<bool> deleteRegimen(int id) async {
    await Future.delayed(AppConfig.simulatedDelay);
    
    final index = _regimenes.indexWhere((r) => r.id == id);
    if (index == -1) {
      return false;
    }
    
    // Marcar como inactivo en lugar de eliminar
    _regimenes[index] = _regimenes[index].copyWith(activo: false);
    return true;
  }
}