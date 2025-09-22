import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/area_model.dart';
import '../models/reservation_model.dart';

class ReservationService extends ChangeNotifier {
  static const String baseUrl = 'https://backend-condo-production.up.railway.app';
  static const String areasEndpoint = '/api/areas-comunes/areas/';
  static const String reservasEndpoint = '/api/areas-comunes/reservas/';

  List<Area> _areas = [];
  List<Reservation> _userReservations = [];
  bool _isLoading = false;
  String? _error;

  List<Area> get areas => _areas;
  List<Reservation> get userReservations => _userReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Area> get availableAreas => _areas.where((area) => area.estaDisponible).toList();

  Future<bool> loadAreas(String accessToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl$areasEndpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final areasData = data['results'] ?? data;

        _areas = (areasData as List)
            .map((areaJson) => Area.fromJson(areaJson))
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al cargar áreas comunes';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadUserReservations(String accessToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl$reservasEndpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reservasData = data['results'] ?? data;

        _userReservations = (reservasData as List)
            .map((reservaJson) => Reservation.fromJson(reservaJson))
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al cargar reservas';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createReservation(Reservation reservation, String accessToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl$reservasEndpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reservation.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Recargar las reservas del usuario
        await loadUserReservations(accessToken);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _error = _extractErrorMessage(errorData);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(int reservationId, String accessToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.patch(
        Uri.parse('$baseUrl$reservasEndpoint$reservationId/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'estado': 'cancelada'}),
      );

      if (response.statusCode == 200) {
        // Recargar las reservas del usuario
        await loadUserReservations(accessToken);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al cancelar la reserva';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkAvailability(int areaId, DateTime fechaInicio, DateTime fechaFin, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$areasEndpoint$areaId/verificar_disponibilidad/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fecha_inicio': fechaInicio.toIso8601String(),
          'fecha_fin': fechaFin.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['disponible'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Area? getAreaById(int areaId) {
    try {
      return _areas.firstWhere((area) => area.id == areaId);
    } catch (e) {
      return null;
    }
  }

  double calculateTotalPrice(Area area, DateTime fechaInicio, DateTime fechaFin) {
    final duration = fechaFin.difference(fechaInicio);
    final hours = duration.inMinutes / 60.0;
    return area.precioBaseNumerico * hours;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractErrorMessage(Map<String, dynamic> errorData) {
    if (errorData.containsKey('detail')) {
      return errorData['detail'];
    }

    if (errorData.containsKey('non_field_errors')) {
      final errors = errorData['non_field_errors'] as List;
      return errors.isNotEmpty ? errors.first.toString() : 'Error desconocido';
    }

    // Buscar el primer error en los campos
    for (final key in errorData.keys) {
      if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
        return '${key}: ${(errorData[key] as List).first}';
      }
    }

    return 'Error al procesar la solicitud';
  }
}