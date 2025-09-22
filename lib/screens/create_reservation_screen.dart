import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../models/area_model.dart';
import '../models/reservation_model.dart';

class CreateReservationScreen extends StatefulWidget {
  @override
  _CreateReservationScreenState createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  Area? _selectedArea;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAreas();
    });
  }

  Future<void> _loadAreas() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final reservationService = Provider.of<ReservationService>(context, listen: false);

    if (authService.isAuthenticated) {
      final token = authService.accessToken;
      if (token != null) {
        await reservationService.loadAreas(token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<ReservationService, AuthService>(
        builder: (context, reservationService, authService, child) {
          if (reservationService.isLoading && reservationService.availableAreas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Area selection
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar Área Común',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Area>(
                          value: _selectedArea,
                          decoration: InputDecoration(
                            labelText: 'Área Común',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.place),
                          ),
                          items: reservationService.availableAreas.map((area) {
                            return DropdownMenuItem<Area>(
                              value: area,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(area.nombre),
                                  Text(
                                    area.precioFormateado + '/hora',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (Area? newValue) {
                            setState(() {
                              _selectedArea = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona un área común';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Date and time selection
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha y Horario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date picker
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(_selectedDate == null
                            ? 'Seleccionar fecha'
                            : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.year}'),
                          subtitle: _selectedDate == null ? const Text('Toca para seleccionar') : null,
                          onTap: _selectDate,
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),

                        const Divider(),

                        // Start time picker
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(_startTime == null
                            ? 'Hora de inicio'
                            : 'Inicio: ${_startTime!.format(context)}'),
                          subtitle: _startTime == null ? const Text('Toca para seleccionar') : null,
                          onTap: () => _selectTime(true),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),

                        const Divider(),

                        // End time picker
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(_endTime == null
                            ? 'Hora de fin'
                            : 'Fin: ${_endTime!.format(context)}'),
                          subtitle: _endTime == null ? const Text('Toca para seleccionar') : null,
                          onTap: () => _selectTime(false),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Summary card
                if (_selectedArea != null && _selectedDate != null && _startTime != null && _endTime != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.blue[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de la Reserva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(Icons.place, 'Área', _selectedArea!.nombre),
                            _buildSummaryRow(Icons.calendar_today, 'Fecha',
                              '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate!.year}'),
                            _buildSummaryRow(Icons.access_time, 'Horario',
                              '${_startTime!.format(context)} - ${_endTime!.format(context)}'),
                            _buildSummaryRow(Icons.timer, 'Duración', '${_calculateDuration().toStringAsFixed(1)} horas'),
                            const Divider(),
                            _buildSummaryRow(Icons.attach_money, 'Total', _calculateTotal(), isTotal: true),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitReservation,
                    icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Creando...' : 'Crear Reserva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tu reserva será creada con estado "Pendiente" y debe ser confirmada por el administrador.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isTotal ? Colors.blue[800] : Colors.grey[800],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Reset end time if it's before start time
          if (_endTime != null && _endTime!.hour < picked.hour) {
            _endTime = null;
          }
        } else {
          // Validate that end time is after start time
          if (_startTime != null) {
            final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
            final endMinutes = picked.hour * 60 + picked.minute;

            if (endMinutes <= startMinutes) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La hora de fin debe ser posterior a la hora de inicio'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
          }
          _endTime = picked;
        }
      });
    }
  }

  double _calculateDuration() {
    if (_startTime == null || _endTime == null) return 0.0;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    return (endMinutes - startMinutes) / 60.0;
  }

  String _calculateTotal() {
    if (_selectedArea == null) return 'Bs. 0.00';

    final duration = _calculateDuration();
    final total = _selectedArea!.precioBaseNumerico * duration;
    final symbol = _selectedArea!.moneda == 'BOB' ? 'Bs.' : '\$';

    return '$symbol ${total.toStringAsFixed(2)}';
  }

  bool _validateForm() {
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un área común'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona horario de inicio y fin'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_calculateDuration() <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La duración de la reserva debe ser mayor a 0 horas'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitReservation() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final reservationService = Provider.of<ReservationService>(context, listen: false);

    try {
      // Create DateTime objects
      final fechaInicio = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final fechaFin = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Check availability first
      final token = authService.accessToken;
      if (token != null) {
        // Verificar que el usuario tiene propietario_id
        if (authService.user?.propietarioId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario no tiene perfil de propietario configurado'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final isAvailable = await reservationService.checkAvailability(
          _selectedArea!.id,
          fechaInicio,
          fechaFin,
          token,
        );

        if (!isAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El área no está disponible en el horario seleccionado'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Create reservation
        final reservation = Reservation(
          area: _selectedArea!.id,
          propietario: authService.user!.propietarioId!,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          estado: 'pendiente',
        );

        final success = await reservationService.createReservation(reservation, token);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reservationService.error ?? 'Error al crear la reserva'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}