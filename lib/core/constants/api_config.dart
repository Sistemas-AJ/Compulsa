class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8001/api/v1'; // Cambiar puerto
  
  // Endpoints
  static const String regimenes = '/regimenes';
  static const String empresas = '/empresas';
  static const String calculosIGV = '/calculos/igv';
  static const String calculosRenta = '/calculos/renta';
  static const String liquidaciones = '/liquidaciones';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}