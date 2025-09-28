class Charge {
  final int id;
  final int propietario;
  final int unidad;
  final String concepto;
  final String tipoCargo;
  final double monto;
  final String moneda;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final String estado;
  final bool esRecurrente;
  final String? periodo;
  final int? infraccion;
  final double montoPagado;
  final double tasaInteresMora;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos adicionales para mostrar información
  final String? propietarioNombre;
  final String? unidadNumero;
  final String? bloqueNombre;
  final String? tipoCargoDisplay;
  final String? estadoDisplay;
  final double? saldoPendiente;
  final bool? estaVencido;
  final int? diasVencido;
  final double? intereseMoraCalculado;
  final double? montoTotalConIntereses;

  Charge({
    required this.id,
    required this.propietario,
    required this.unidad,
    required this.concepto,
    required this.tipoCargo,
    required this.monto,
    required this.moneda,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.estado,
    required this.esRecurrente,
    this.periodo,
    this.infraccion,
    required this.montoPagado,
    required this.tasaInteresMora,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
    this.propietarioNombre,
    this.unidadNumero,
    this.bloqueNombre,
    this.tipoCargoDisplay,
    this.estadoDisplay,
    this.saldoPendiente,
    this.estaVencido,
    this.diasVencido,
    this.intereseMoraCalculado,
    this.montoTotalConIntereses,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      id: json['id'] ?? 0,
      propietario: json['propietario'] ?? 0,
      unidad: json['unidad'] ?? 0,
      concepto: json['concepto'] ?? '',
      tipoCargo: json['tipo_cargo'] ?? '',
      monto: _parseDouble(json['monto']),
      moneda: json['moneda'] ?? 'BOB',
      fechaEmision: DateTime.parse(json['fecha_emision'] ?? DateTime.now().toIso8601String()),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? '',
      esRecurrente: json['es_recurrente'] ?? false,
      periodo: json['periodo'],
      infraccion: json['infraccion'],
      montoPagado: _parseDouble(json['monto_pagado']),
      tasaInteresMora: _parseDouble(json['tasa_interes_mora']),
      observaciones: json['observaciones'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      propietarioNombre: json['propietario_nombre'],
      unidadNumero: json['unidad_numero'],
      bloqueNombre: json['bloque_nombre'],
      tipoCargoDisplay: json['tipo_cargo_display'],
      estadoDisplay: json['estado_display'],
      saldoPendiente: _parseDoubleNullable(json['saldo_pendiente']),
      estaVencido: json['esta_vencido'],
      diasVencido: json['dias_vencido'],
      intereseMoraCalculado: _parseDoubleNullable(json['interes_mora_calculado']),
      montoTotalConIntereses: _parseDoubleNullable(json['monto_total_con_intereses']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      'concepto': concepto,
      'tipo_cargo': tipoCargo,
      'monto': monto,
      'moneda': moneda,
      'fecha_emision': fechaEmision.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'estado': estado,
      'es_recurrente': esRecurrente,
      'periodo': periodo,
      'infraccion': infraccion,
      'monto_pagado': montoPagado,
      'tasa_interes_mora': tasaInteresMora,
      'observaciones': observaciones,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get canPay => estado == 'pendiente' || estado == 'parcialmente_pagado' || estado == 'vencido';
  bool get isPaidPending => estado == 'en_revision';
  bool get isPaid => estado == 'pagado';
  bool get hasBalance => (saldoPendiente ?? (monto - montoPagado)) > 0;
}

enum ChargeState {
  pendiente,
  parcialmentePagado,
  pagado,
  vencido,
  cancelado,
  enRevision,
}

extension ChargeStateExtension on ChargeState {
  String get displayName {
    switch (this) {
      case ChargeState.pendiente:
        return 'Pendiente';
      case ChargeState.parcialmentePagado:
        return 'Parcialmente Pagado';
      case ChargeState.pagado:
        return 'Pagado';
      case ChargeState.vencido:
        return 'Vencido';
      case ChargeState.cancelado:
        return 'Cancelado';
      case ChargeState.enRevision:
        return 'En Revisión';
    }
  }

  String get value {
    switch (this) {
      case ChargeState.pendiente:
        return 'pendiente';
      case ChargeState.parcialmentePagado:
        return 'parcialmente_pagado';
      case ChargeState.pagado:
        return 'pagado';
      case ChargeState.vencido:
        return 'vencido';
      case ChargeState.cancelado:
        return 'cancelado';
      case ChargeState.enRevision:
        return 'en_revision';
    }
  }

  static ChargeState fromString(String value) {
    switch (value) {
      case 'pendiente':
        return ChargeState.pendiente;
      case 'parcialmente_pagado':
        return ChargeState.parcialmentePagado;
      case 'pagado':
        return ChargeState.pagado;
      case 'vencido':
        return ChargeState.vencido;
      case 'cancelado':
        return ChargeState.cancelado;
      case 'en_revision':
        return ChargeState.enRevision;
      default:
        return ChargeState.pendiente;
    }
  }
}

enum ChargeType {
  cuotaMensual,
  expensaExtraordinaria,
  multa,
  interesMora,
  otros,
}

extension ChargeTypeExtension on ChargeType {
  String get displayName {
    switch (this) {
      case ChargeType.cuotaMensual:
        return 'Cuota Mensual';
      case ChargeType.expensaExtraordinaria:
        return 'Expensa Extraordinaria';
      case ChargeType.multa:
        return 'Multa';
      case ChargeType.interesMora:
        return 'Interés por Mora';
      case ChargeType.otros:
        return 'Otros';
    }
  }

  String get value {
    switch (this) {
      case ChargeType.cuotaMensual:
        return 'cuota_mensual';
      case ChargeType.expensaExtraordinaria:
        return 'expensa_extraordinaria';
      case ChargeType.multa:
        return 'multa';
      case ChargeType.interesMora:
        return 'interes_mora';
      case ChargeType.otros:
        return 'otros';
    }
  }

  static ChargeType fromString(String value) {
    switch (value) {
      case 'cuota_mensual':
        return ChargeType.cuotaMensual;
      case 'expensa_extraordinaria':
        return ChargeType.expensaExtraordinaria;
      case 'multa':
        return ChargeType.multa;
      case 'interes_mora':
        return ChargeType.interesMora;
      case 'otros':
        return ChargeType.otros;
      default:
        return ChargeType.otros;
    }
  }
}