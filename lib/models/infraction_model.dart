class Infraction {
  final int id;
  final int propietario;
  final int unidad;
  final int tipoInfraccion;
  final String descripcion;
  final DateTime fechaInfraccion;
  final String? evidenciaUrl;
  final int? reportadoPor;
  final double? montoMulta;
  final DateTime? fechaLimitePago;
  final String estado;
  final String? observacionesAdmin;
  final bool esReincidente;
  final double? montoCalculado;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos adicionales para mostrar información
  final String? propietarioNombre;
  final String? unidadNumero;
  final String? bloqueNombre;
  final String? tipoInfraccionNombre;
  final String? estadoDisplay;
  final int? diasParaPago;
  final bool? puedeAplicarMulta;
  final bool? estaVencida;

  Infraction({
    required this.id,
    required this.propietario,
    required this.unidad,
    required this.tipoInfraccion,
    required this.descripcion,
    required this.fechaInfraccion,
    this.evidenciaUrl,
    this.reportadoPor,
    this.montoMulta,
    this.fechaLimitePago,
    required this.estado,
    this.observacionesAdmin,
    required this.esReincidente,
    this.montoCalculado,
    required this.createdAt,
    required this.updatedAt,
    this.propietarioNombre,
    this.unidadNumero,
    this.bloqueNombre,
    this.tipoInfraccionNombre,
    this.estadoDisplay,
    this.diasParaPago,
    this.puedeAplicarMulta,
    this.estaVencida,
  });

  factory Infraction.fromJson(Map<String, dynamic> json) {
    return Infraction(
      id: json['id'] ?? 0,
      propietario: json['propietario'] ?? 0,
      unidad: json['unidad'] ?? 0,
      tipoInfraccion: json['tipo_infraccion'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      fechaInfraccion: DateTime.parse(json['fecha_infraccion'] ?? DateTime.now().toIso8601String()),
      evidenciaUrl: json['evidencia_url'],
      reportadoPor: json['reportado_por'],
      montoMulta: _parseDoubleNullable(json['monto_multa']),
      fechaLimitePago: json['fecha_limite_pago'] != null
          ? DateTime.parse(json['fecha_limite_pago'])
          : null,
      estado: json['estado'] ?? '',
      observacionesAdmin: json['observaciones_admin'],
      esReincidente: json['es_reincidente'] ?? false,
      montoCalculado: _parseDoubleNullable(json['monto_calculado']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      propietarioNombre: json['propietario_nombre'],
      unidadNumero: json['unidad_numero'],
      bloqueNombre: json['bloque_nombre'],
      tipoInfraccionNombre: json['tipo_infraccion_nombre'],
      estadoDisplay: json['estado_display'],
      diasParaPago: json['dias_para_pago'],
      puedeAplicarMulta: json['puede_aplicar_multa'],
      estaVencida: json['esta_vencida'],
    );
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propietario': propietario,
      'unidad': unidad,
      'tipo_infraccion': tipoInfraccion,
      'descripcion': descripcion,
      'fecha_infraccion': fechaInfraccion.toIso8601String(),
      'evidencia_url': evidenciaUrl,
      'reportado_por': reportadoPor,
      'monto_multa': montoMulta,
      'fecha_limite_pago': fechaLimitePago?.toIso8601String(),
      'estado': estado,
      'observaciones_admin': observacionesAdmin,
      'es_reincidente': esReincidente,
      'monto_calculado': montoCalculado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get canPay => estado == 'multa_aplicada' || estado == 'registrada';
  bool get isPaidPending => estado == 'en_revision';
  bool get isPaid => estado == 'pagada';
}

enum InfractionState {
  registrada,
  enRevision,
  confirmada,
  rechazada,
  multaAplicada,
  pagada,
}

extension InfractionStateExtension on InfractionState {
  String get displayName {
    switch (this) {
      case InfractionState.registrada:
        return 'Registrada';
      case InfractionState.enRevision:
        return 'En Revisión';
      case InfractionState.confirmada:
        return 'Confirmada';
      case InfractionState.rechazada:
        return 'Rechazada';
      case InfractionState.multaAplicada:
        return 'Multa Aplicada';
      case InfractionState.pagada:
        return 'Pagada';
    }
  }

  String get value {
    switch (this) {
      case InfractionState.registrada:
        return 'registrada';
      case InfractionState.enRevision:
        return 'en_revision';
      case InfractionState.confirmada:
        return 'confirmada';
      case InfractionState.rechazada:
        return 'rechazada';
      case InfractionState.multaAplicada:
        return 'multa_aplicada';
      case InfractionState.pagada:
        return 'pagada';
    }
  }

  static InfractionState fromString(String value) {
    switch (value) {
      case 'registrada':
        return InfractionState.registrada;
      case 'en_revision':
        return InfractionState.enRevision;
      case 'confirmada':
        return InfractionState.confirmada;
      case 'rechazada':
        return InfractionState.rechazada;
      case 'multa_aplicada':
        return InfractionState.multaAplicada;
      case 'pagada':
        return InfractionState.pagada;
      default:
        return InfractionState.registrada;
    }
  }
}