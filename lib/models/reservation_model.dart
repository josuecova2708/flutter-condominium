class Reservation {
  final int? id;
  final int area;
  final String? areaNombre;
  final int propietario;
  final String? propietarioNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final String? estadoDisplay;
  final String precioTotal;
  final String moneda;
  final double duracionHoras;
  final String? createdAt;
  final String? updatedAt;

  Reservation({
    this.id,
    required this.area,
    this.areaNombre,
    required this.propietario,
    this.propietarioNombre,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado = 'pendiente',
    this.estadoDisplay,
    this.precioTotal = '0',
    this.moneda = 'BOB',
    this.duracionHoras = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      area: json['area'] ?? 0,
      areaNombre: json['area_nombre'],
      propietario: json['propietario'] ?? 0,
      propietarioNombre: json['propietario_nombre'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      estado: json['estado'] ?? 'pendiente',
      estadoDisplay: json['estado_display'],
      precioTotal: json['precio_total']?.toString() ?? '0',
      moneda: json['moneda'] ?? 'BOB',
      duracionHoras: (json['duracion_horas'] ?? 0.0).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'area': area,
      'propietario': propietario,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'estado': estado,
    };
  }

  double get precioTotalNumerico {
    return double.tryParse(precioTotal) ?? 0.0;
  }

  String get precioFormateado {
    final symbol = moneda == 'BOB' ? 'Bs.' : '\$';
    return '$symbol ${precioTotalNumerico.toStringAsFixed(2)}';
  }

  String get estadoColor {
    switch (estado) {
      case 'pendiente':
        return 'warning';
      case 'confirmada':
        return 'success';
      case 'cancelada':
        return 'error';
      default:
        return 'default';
    }
  }

  String get fechaFormateada {
    return '${fechaInicio.day.toString().padLeft(2, '0')}/'
        '${fechaInicio.month.toString().padLeft(2, '0')}/'
        '${fechaInicio.year}';
  }

  String get horaFormateada {
    return '${fechaInicio.hour.toString().padLeft(2, '0')}:'
        '${fechaInicio.minute.toString().padLeft(2, '0')} - '
        '${fechaFin.hour.toString().padLeft(2, '0')}:'
        '${fechaFin.minute.toString().padLeft(2, '0')}';
  }

  bool get puedeEditar {
    return estado == 'pendiente';
  }

  bool get puedeCancelar {
    return estado == 'pendiente' || estado == 'confirmada';
  }
}