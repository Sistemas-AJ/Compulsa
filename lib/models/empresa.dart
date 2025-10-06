class Empresa {
  final int? id;
  final String ruc;
  final String razonSocial;
  final String? nombreComercial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final int regimenTributarioId;
  final bool activo;
  final DateTime? fechaInscripcion;

  Empresa({
    this.id,
    required this.ruc,
    required this.razonSocial,
    this.nombreComercial,
    this.direccion,
    this.telefono,
    this.email,
    required this.regimenTributarioId,
    this.activo = true,
    this.fechaInscripcion,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      ruc: json['ruc'] ?? '',
      razonSocial: json['razon_social'] ?? '',
      nombreComercial: json['nombre_comercial'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
      regimenTributarioId: json['regimen_tributario_id'] ?? 1,
      activo: json['activo'] ?? true,
      fechaInscripcion: json['fecha_inscripcion'] != null 
          ? DateTime.parse(json['fecha_inscripcion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ruc': ruc,
      'razon_social': razonSocial,
      'nombre_comercial': nombreComercial,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'regimen_tributario_id': regimenTributarioId,
      'activo': activo,
      if (fechaInscripcion != null) 'fecha_inscripcion': fechaInscripcion!.toIso8601String(),
    };
  }

  // Mantener compatibilidad con el código existente
  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  Empresa copyWith({
    int? id,
    String? ruc,
    String? razonSocial,
    String? nombreComercial,
    String? direccion,
    String? telefono,
    String? email,
    int? regimenTributarioId,
    bool? activo,
    DateTime? fechaInscripcion,
  }) {
    return Empresa(
      id: id ?? this.id,
      ruc: ruc ?? this.ruc,
      razonSocial: razonSocial ?? this.razonSocial,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      regimenTributarioId: regimenTributarioId ?? this.regimenTributarioId,
      activo: activo ?? this.activo,
      fechaInscripcion: fechaInscripcion ?? this.fechaInscripcion,
    );
  }
}