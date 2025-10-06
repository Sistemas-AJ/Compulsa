class RegimenTributario {
  final int id;
  final String nombre;
  final String? descripcion;
  final double tasaRenta;
  final double? limiteIngresos;
  final bool activo;

  RegimenTributario({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tasaRenta,
    this.limiteIngresos,
    this.activo = true,
  });

  factory RegimenTributario.fromJson(Map<String, dynamic> json) {
    return RegimenTributario(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      tasaRenta: (json['tasa_renta'] ?? 0.0).toDouble(),
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
      'limite_ingresos': limiteIngresos,
      'activo': activo,
    };
  }

  String get tasaRentaFormateada {
    return '${(tasaRenta * 100).toStringAsFixed(1)}%';
  }

  bool get pagaIGV {
    // RUS no paga IGV
    return !nombre.toLowerCase().contains('rus');
  }
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