import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/infraction_model.dart';
import '../models/charge_model.dart';
import 'auth_service.dart';

class PaymentService extends ChangeNotifier {
  static const String baseUrl = 'https://backend-condo-production.up.railway.app';
  static const String infractionsEndpoint = '/api/finances/api/infracciones/';
  static const String chargesEndpoint = '/api/finances/api/cargos/';

  final AuthService _authService;
  bool _isLoading = false;
  List<Infraction> _infractions = [];
  List<Charge> _charges = [];
  String? _error;

  PaymentService(this._authService);

  bool get isLoading => _isLoading;
  List<Infraction> get infractions => _infractions;
  List<Charge> get charges => _charges;
  String? get error => _error;

  // Obtener infracciones del propietario actual
  Future<bool> fetchInfractions() async {
    if (_authService.accessToken == null) {
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl$infractionsEndpoint'),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final infractionsData = data['results'] ?? data;
        _infractions = (infractionsData as List)
            .map((item) => Infraction.fromJson(item))
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al cargar infracciones';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error fetching infractions: $e');
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener cargos del propietario actual
  Future<bool> fetchCharges() async {
    if (_authService.accessToken == null) {
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl$chargesEndpoint'),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chargesData = data['results'] ?? data;
        _charges = (chargesData as List)
            .map((item) => Charge.fromJson(item))
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al cargar cargos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error fetching charges: $e');
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Confirmar pago de infracción
  Future<Map<String, dynamic>> confirmInfractionPayment(int infractionId) async {
    if (_authService.accessToken == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl$infractionsEndpoint$infractionId/confirmar_pago/'),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Actualizar la infracción en la lista local
        final index = _infractions.indexWhere((inf) => inf.id == infractionId);
        if (index != -1) {
          _infractions[index] = Infraction.fromJson(data['infraccion']);
          notifyListeners();
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Pago confirmado exitosamente'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Error al confirmar el pago'
        };
      }
    } catch (e) {
      print('Error confirming infraction payment: $e');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error de conexión. Intente más tarde'
      };
    }
  }

  // Confirmar pago de cargo
  Future<Map<String, dynamic>> confirmChargePayment(int chargeId) async {
    if (_authService.accessToken == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl$chargesEndpoint$chargeId/confirmar_pago/'),
        headers: {
          'Authorization': 'Bearer ${_authService.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Actualizar el cargo en la lista local
        final index = _charges.indexWhere((charge) => charge.id == chargeId);
        if (index != -1) {
          _charges[index] = Charge.fromJson(data['cargo']);
          notifyListeners();
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Pago confirmado exitosamente'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Error al confirmar el pago'
        };
      }
    } catch (e) {
      print('Error confirming charge payment: $e');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error de conexión. Intente más tarde'
      };
    }
  }

  // Obtener infracciones que pueden ser pagadas
  List<Infraction> get payableInfractions =>
      _infractions.where((inf) => inf.canPay).toList();

  // Obtener cargos que pueden ser pagados
  List<Charge> get payableCharges =>
      _charges.where((charge) => charge.canPay).toList();

  // Obtener infracciones pendientes de revisión
  List<Infraction> get pendingReviewInfractions =>
      _infractions.where((inf) => inf.isPaidPending).toList();

  // Obtener cargos pendientes de revisión
  List<Charge> get pendingReviewCharges =>
      _charges.where((charge) => charge.isPaidPending).toList();

  // Limpiar datos
  void clearData() {
    _infractions.clear();
    _charges.clear();
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refreshData() async {
    await Future.wait([
      fetchInfractions(),
      fetchCharges(),
    ]);
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}