class RegimenTributario {
  final int id;
  final String nombre;
  final String? descripcion;
  final double tasaRenta;
  final double tasaIGV;
  final double? limiteIngresos;
  final bool activo;

  RegimenTributario({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tasaRenta,
    this.tasaIGV = 18.0, // IGV por defecto 18%
    this.limiteIngresos,
    this.activo = true,
  });

  factory RegimenTributario.fromJson(Map<String, dynamic> json) {
    return RegimenTributario(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      tasaRenta: (json['tasa_renta'] ?? 0.0).toDouble(),
      tasaIGV: (json['tasa_igv'] ?? 18.0).toDouble(),
      limiteIngresos: json['limite_ingresos']?.toDouble(),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tasa_renta': tasaRenta,
      'tasa_igv': tasaIGV,
      'limite_ingresos': limiteIngresos,
      'activo': activo,
    };
  }

  String get tasaRentaFormateada {
    return '${tasaRenta.toStringAsFixed(1)}%';
  }

  String get tasaIGVFormateada {
    return '${tasaIGV.toStringAsFixed(1)}%';
  }

  bool get pagaIGV {
    // RUS no paga IGV (tasa IGV = 0%)
    return tasaIGV > 0;
  }

  RegimenTributario copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? tasaRenta,
    double? tasaIGV,
    double? limiteIngresos,
    bool? activo,
  }) {
    return RegimenTributario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tasaRenta: tasaRenta ?? this.tasaRenta,
      tasaIGV: tasaIGV ?? this.tasaIGV,
      limiteIngresos: limiteIngresos ?? this.limiteIngresos,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'RegimenTributario(id: $id, nombre: $nombre, tasaRenta: $tasaRentaFormateada, tasaIGV: $tasaIGVFormateada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegimenTributario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum para compatibilidad con código existente
enum RegimenTributarioEnum {
  general,
  mype,
  especial,
  rus,
}

extension RegimenTributarioEnumExtension on RegimenTributarioEnum {
  String get nombre {
    switch (this) {
      case RegimenTributarioEnum.general:
        return 'Régimen General';
      case RegimenTributarioEnum.mype:
        return 'Régimen MYPE';
      case RegimenTributarioEnum.especial:
        return 'Régimen Especial';
      case RegimenTributarioEnum.rus:
        return 'RUS';
    }
  }

  double get tasaRenta {
    switch (this) {
      case RegimenTributarioEnum.general:
        return 0.295; // 29.5%
      case RegimenTributarioEnum.mype:
        return 0.10; // 10%
      case RegimenTributarioEnum.especial:
        return 0.015; // 1.5%
      case RegimenTributarioEnum.rus:
        return 0.0; // No paga renta
    }
  }

  bool get pagaIGV {
    return this != RegimenTributarioEnum.rus;
  }
}