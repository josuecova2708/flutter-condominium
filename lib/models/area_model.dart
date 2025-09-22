class Area {
  final int id;
  final String nombre;
  final String estado;
  final String estadoDisplay;
  final String precioBase;
  final String moneda;
  final bool estaDisponible;
  final String createdAt;
  final String updatedAt;

  Area({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.estadoDisplay,
    required this.precioBase,
    required this.moneda,
    required this.estaDisponible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      estado: json['estado'] ?? '',
      estadoDisplay: json['estado_display'] ?? '',
      precioBase: json['precio_base']?.toString() ?? '0',
      moneda: json['moneda'] ?? 'BOB',
      estaDisponible: json['esta_disponible'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'estado_display': estadoDisplay,
      'precio_base': precioBase,
      'moneda': moneda,
      'esta_disponible': estaDisponible,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  double get precioBaseNumerico {
    return double.tryParse(precioBase) ?? 0.0;
  }

  String get precioFormateado {
    final symbol = moneda == 'BOB' ? 'Bs.' : '\$';
    return '$symbol ${precioBaseNumerico.toStringAsFixed(2)}';
  }
}