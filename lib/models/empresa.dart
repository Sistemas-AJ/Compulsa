class Empresa {
  final String id;
  final String ruc;
  final String razonSocial;
  final RegimenTributario regimen;
  final bool activo;
  final DateTime fechaRegistro;
  final String? direccion;
  final String? telefono;
  final String? email;

  Empresa({
    required this.id,
    required this.ruc,
    required this.razonSocial,
    required this.regimen,
    this.activo = true,
    required this.fechaRegistro,
    this.direccion,
    this.telefono,
    this.email,
  });

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      id: map['id'] ?? '',
      ruc: map['ruc'] ?? '',
      razonSocial: map['razonSocial'] ?? '',
      regimen: RegimenTributario.values.firstWhere(
        (r) => r.toString().split('.').last == map['regimen'],
        orElse: () => RegimenTributario.general,
      ),
      activo: map['activo'] ?? true,
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
      direccion: map['direccion'],
      telefono: map['telefono'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ruc': ruc,
      'razonSocial': razonSocial,
      'regimen': regimen.toString().split('.').last,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
    };
  }

  Empresa copyWith({
    String? id,
    String? ruc,
    String? razonSocial,
    RegimenTributario? regimen,
    bool? activo,
    DateTime? fechaRegistro,
    String? direccion,
    String? telefono,
    String? email,
  }) {
    return Empresa(
      id: id ?? this.id,
      ruc: ruc ?? this.ruc,
      razonSocial: razonSocial ?? this.razonSocial,
      regimen: regimen ?? this.regimen,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }
}

enum RegimenTributario {
  general,
  mype,
  especial,
  rus,
}

extension RegimenTributarioExtension on RegimenTributario {
  String get nombre {
    switch (this) {
      case RegimenTributario.general:
        return 'Régimen General';
      case RegimenTributario.mype:
        return 'Régimen MYPE';
      case RegimenTributario.especial:
        return 'Régimen Especial';
      case RegimenTributario.rus:
        return 'RUS';
    }
  }

  double get tasaRenta {
    switch (this) {
      case RegimenTributario.general:
        return 0.295; // 29.5%
      case RegimenTributario.mype:
        return 0.10; // 10%
      case RegimenTributario.especial:
        return 0.15; // 15%
      case RegimenTributario.rus:
        return 0.0; // No paga renta
    }
  }

  bool get pagaIGV {
    return this != RegimenTributario.rus;
  }
}