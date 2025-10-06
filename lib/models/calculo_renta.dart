import 'regimen_tributario.dart';

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

  factory CalculoRenta.fromJson(Map<String, dynamic> json) {
    return CalculoRenta(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      periodo: DateTime.parse(json['periodo']),
      ingresos: (json['ingresos'] ?? 0.0).toDouble(),
      gastosDeducibles: (json['gastos_deducibles'] ?? 0.0).toDouble(),
      gastosNoDeducibles: (json['gastos_no_deducibles'] ?? 0.0).toDouble(),
      rentaNeta: (json['renta_neta'] ?? 0.0).toDouble(),
      impuestoRenta: (json['impuesto_renta'] ?? 0.0).toDouble(),
      pagosCuenta: (json['pagos_cuenta'] ?? 0.0).toDouble(),
      rentaPorPagar: (json['renta_por_pagar'] ?? 0.0).toDouble(),
      fechaCalculo: DateTime.parse(json['fecha_calculo']),
      regimen: RegimenTributario.fromJson(json['regimen']),
      finalizado: json['finalizado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'periodo': periodo.toIso8601String(),
      'ingresos': ingresos,
      'gastos_deducibles': gastosDeducibles,
      'gastos_no_deducibles': gastosNoDeducibles,
      'renta_neta': rentaNeta,
      'impuesto_renta': impuestoRenta,
      'pagos_cuenta': pagosCuenta,
      'renta_por_pagar': rentaPorPagar,
      'fecha_calculo': fechaCalculo.toIso8601String(),
      'regimen_id': regimen.id,
      'finalizado': finalizado,
    };
  }

  CalculoRenta copyWith({
    String? id,
    String? empresaId,
    DateTime? periodo,
    double? ingresos,
    double? gastosDeducibles,
    double? gastosNoDeducibles,
    double? rentaNeta,
    double? impuestoRenta,
    double? pagosCuenta,
    double? rentaPorPagar,
    DateTime? fechaCalculo,
    RegimenTributario? regimen,
    bool? finalizado,
  }) {
    return CalculoRenta(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      periodo: periodo ?? this.periodo,
      ingresos: ingresos ?? this.ingresos,
      gastosDeducibles: gastosDeducibles ?? this.gastosDeducibles,
      gastosNoDeducibles: gastosNoDeducibles ?? this.gastosNoDeducibles,
      rentaNeta: rentaNeta ?? this.rentaNeta,
      impuestoRenta: impuestoRenta ?? this.impuestoRenta,
      pagosCuenta: pagosCuenta ?? this.pagosCuenta,
      rentaPorPagar: rentaPorPagar ?? this.rentaPorPagar,
      fechaCalculo: fechaCalculo ?? this.fechaCalculo,
      regimen: regimen ?? this.regimen,
      finalizado: finalizado ?? this.finalizado,
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

  @override
  String toString() {
    return 'CalculoRenta(id: $id, empresaId: $empresaId, periodo: $periodoFormatted, rentaPorPagar: S/ ${rentaPorPagar.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculoRenta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}