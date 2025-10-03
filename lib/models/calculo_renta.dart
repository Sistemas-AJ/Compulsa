import 'empresa.dart';

class CalculoRenta {
  final String id;
  final String empresaId;
  final DateTime periodo;
  final double ingresos;
  final double gastosDeducibles;
  final double gastosNoDeducibles;
  final double rentaNeta;
  final double impuestoRenta;
  final double pagosCuenta;
  final double rentaPorPagar;
  final DateTime fechaCalculo;
  final RegimenTributario regimen;
  final bool finalizado;

  CalculoRenta({
    required this.id,
    required this.empresaId,
    required this.periodo,
    required this.ingresos,
    required this.gastosDeducibles,
    this.gastosNoDeducibles = 0.0,
    required this.rentaNeta,
    required this.impuestoRenta,
    this.pagosCuenta = 0.0,
    required this.rentaPorPagar,
    required this.fechaCalculo,
    required this.regimen,
    this.finalizado = false,
  });

  factory CalculoRenta.calcular({
    required String id,
    required String empresaId,
    required DateTime periodo,
    required double ingresos,
    required double gastosDeducibles,
    double gastosNoDeducibles = 0.0,
    double pagosCuenta = 0.0,
    required RegimenTributario regimen,
  }) {
    final rentaNeta = ingresos - gastosDeducibles - gastosNoDeducibles;
    final impuestoRenta = rentaNeta > 0 ? rentaNeta * regimen.tasaRenta : 0.0;
    final rentaPorPagar = impuestoRenta - pagosCuenta > 0 ? impuestoRenta - pagosCuenta : 0.0;

    return CalculoRenta(
      id: id,
      empresaId: empresaId,
      periodo: periodo,
      ingresos: ingresos,
      gastosDeducibles: gastosDeducibles,
      gastosNoDeducibles: gastosNoDeducibles,
      rentaNeta: rentaNeta,
      impuestoRenta: impuestoRenta,
      pagosCuenta: pagosCuenta,
      rentaPorPagar: rentaPorPagar,
      fechaCalculo: DateTime.now(),
      regimen: regimen,
    );
  }

  double get totalGastos => gastosDeducibles + gastosNoDeducibles;
  
  bool get tienePerdida => rentaNeta < 0;
  bool get debePagar => rentaPorPagar > 0;
  
  double get tasaEfectiva => ingresos > 0 ? (impuestoRenta / ingresos) * 100 : 0.0;
  
  String get periodoFormatted {
    final meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[periodo.month]} ${periodo.year}';
  }

  String get regimenNombre => regimen.nombre;
  
  double get tasaAplicada => regimen.tasaRenta * 100;
}