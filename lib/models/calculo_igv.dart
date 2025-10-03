class CalculoIGV {
  final String id;
  final String empresaId;
  final DateTime periodo;
  final double ventasGravadas;
  final double ventasExoneradas;
  final double comprasGravadas;
  final double comprasNoDeducibles;
  final double igvVentas;
  final double igvCompras;
  final double igvPorPagar;
  final double saldoAnterior;
  final double saldoFinal;
  final DateTime fechaCalculo;
  final bool finalizado;

  CalculoIGV({
    required this.id,
    required this.empresaId,
    required this.periodo,
    required this.ventasGravadas,
    this.ventasExoneradas = 0.0,
    required this.comprasGravadas,
    this.comprasNoDeducibles = 0.0,
    required this.igvVentas,
    required this.igvCompras,
    required this.igvPorPagar,
    this.saldoAnterior = 0.0,
    required this.saldoFinal,
    required this.fechaCalculo,
    this.finalizado = false,
  });

  factory CalculoIGV.calcular({
    required String id,
    required String empresaId,
    required DateTime periodo,
    required double ventasGravadas,
    double ventasExoneradas = 0.0,
    required double comprasGravadas,
    double comprasNoDeducibles = 0.0,
    double saldoAnterior = 0.0,
  }) {
    const double tasaIGV = 0.18;
    
    final igvVentas = ventasGravadas * tasaIGV;
    final igvCompras = comprasGravadas * tasaIGV;
    final igvCalculado = igvVentas - igvCompras - saldoAnterior;
    final igvPorPagar = igvCalculado > 0 ? igvCalculado : 0.0;
    final saldoFinal = igvCalculado < 0 ? igvCalculado.abs() : 0.0;

    return CalculoIGV(
      id: id,
      empresaId: empresaId,
      periodo: periodo,
      ventasGravadas: ventasGravadas,
      ventasExoneradas: ventasExoneradas,
      comprasGravadas: comprasGravadas,
      comprasNoDeducibles: comprasNoDeducibles,
      igvVentas: igvVentas,
      igvCompras: igvCompras,
      igvPorPagar: igvPorPagar,
      saldoAnterior: saldoAnterior,
      saldoFinal: saldoFinal,
      fechaCalculo: DateTime.now(),
    );
  }

  factory CalculoIGV.fromMap(Map<String, dynamic> map) {
    return CalculoIGV(
      id: map['id'],
      empresaId: map['empresaId'],
      periodo: DateTime.parse(map['periodo']),
      ventasGravadas: map['ventasGravadas'].toDouble(),
      ventasExoneradas: map['ventasExoneradas']?.toDouble() ?? 0.0,
      comprasGravadas: map['comprasGravadas'].toDouble(),
      comprasNoDeducibles: map['comprasNoDeducibles']?.toDouble() ?? 0.0,
      igvVentas: map['igvVentas'].toDouble(),
      igvCompras: map['igvCompras'].toDouble(),
      igvPorPagar: map['igvPorPagar'].toDouble(),
      saldoAnterior: map['saldoAnterior']?.toDouble() ?? 0.0,
      saldoFinal: map['saldoFinal'].toDouble(),
      fechaCalculo: DateTime.parse(map['fechaCalculo']),
      finalizado: map['finalizado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresaId': empresaId,
      'periodo': periodo.toIso8601String(),
      'ventasGravadas': ventasGravadas,
      'ventasExoneradas': ventasExoneradas,
      'comprasGravadas': comprasGravadas,
      'comprasNoDeducibles': comprasNoDeducibles,
      'igvVentas': igvVentas,
      'igvCompras': igvCompras,
      'igvPorPagar': igvPorPagar,
      'saldoAnterior': saldoAnterior,
      'saldoFinal': saldoFinal,
      'fechaCalculo': fechaCalculo.toIso8601String(),
      'finalizado': finalizado,
    };
  }

  double get totalVentas => ventasGravadas + ventasExoneradas;
  double get totalCompras => comprasGravadas + comprasNoDeducibles;
  
  bool get tieneSaldoFavor => saldoFinal > 0;
  bool get debePagar => igvPorPagar > 0;
  
  String get periodoFormatted {
    final meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[periodo.month]} ${periodo.year}';
  }
}