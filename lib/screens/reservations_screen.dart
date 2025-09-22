import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../models/reservation_model.dart';
import 'create_reservation_screen.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final reservationService = Provider.of<ReservationService>(context, listen: false);

    print('Debug - Loading reservations...');
    if (authService.isAuthenticated) {
      final token = authService.accessToken;
      if (token != null) {
        print('Debug - Token exists, calling loadUserReservations');
        final success = await reservationService.loadUserReservations(token);
        print('Debug - loadUserReservations success: $success');
      } else {
        print('Debug - No token available');
      }
    } else {
      print('Debug - User not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<ReservationService, AuthService>(
        builder: (context, reservationService, authService, child) {
          if (reservationService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reservationService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reservationService.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReservations,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final allReservations = reservationService.allReservations;
          final currentUserName = authService.user?.fullName.trim();

          print('Debug - currentUserName: $currentUserName');
          print('Debug - allReservations count: ${allReservations.length}');
          if (allReservations.isNotEmpty) {
            print('Debug - first reservation propietario_nombre: ${allReservations.first.propietarioNombre}');
          }

          // Dividir reservas en "Mis Reservas" y "Otras Reservas" usando el nombre
          final myReservations = allReservations.where((r) =>
            r.propietarioNombre?.trim() == currentUserName).toList();
          final otherReservations = allReservations.where((r) =>
            r.propietarioNombre?.trim() != currentUserName).toList();

          print('Debug - myReservations count: ${myReservations.length}');
          print('Debug - otherReservations count: ${otherReservations.length}');

          if (allReservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reservas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea la primera reserva tocando el botón +',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReservations,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección "Mis Reservas"
                if (myReservations.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Mis Reservas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${myReservations.length}'),
                          backgroundColor: Colors.blue[100],
                          labelStyle: TextStyle(color: Colors.blue[800]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...myReservations.map((reservation) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReservationCard(reservation, authService, isMyReservation: true),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Sección "Otras Reservas"
                if (otherReservations.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Otras Reservas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${otherReservations.length}'),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...otherReservations.map((reservation) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReservationCard(reservation, authService, isMyReservation: false),
                    ),
                  ),
                ],

                // Si solo hay reservas de otros y ninguna propia
                if (myReservations.isEmpty && otherReservations.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tienes reservas aún. ¡Crea tu primera reserva!',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateReservationScreen(),
            ),
          ).then((_) => _loadReservations());
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation, AuthService authService, {bool isMyReservation = true}) {
    Color statusColor;
    IconData statusIcon;

    switch (reservation.estado) {
      case 'pendiente':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'confirmada':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelada':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: isMyReservation ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMyReservation ? BorderSide(color: Colors.blue[200]!, width: 1) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isMyReservation ? () => _showReservationDetails(reservation, authService) : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isMyReservation ? null : Colors.grey[50],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.areaNombre ?? 'Área ${reservation.area}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          reservation.estadoDisplay ?? reservation.estado,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    reservation.fechaFormateada,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    reservation.horaFormateada,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${reservation.duracionHoras.toStringAsFixed(1)} horas',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  if (isMyReservation)
                    Text(
                      reservation.precioFormateado,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    )
                  else
                    Text(
                      'Ocupado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),

              // Mostrar información adicional para reservas de otros
              if (!isMyReservation && reservation.propietarioNombre != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        reservation.propietarioNombre!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showReservationDetails(Reservation reservation, AuthService authService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Detalles de la Reserva',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),

                // Reservation details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildDetailRow(Icons.place, 'Área', reservation.areaNombre ?? 'Área ${reservation.area}'),
                      _buildDetailRow(Icons.calendar_today, 'Fecha', reservation.fechaFormateada),
                      _buildDetailRow(Icons.access_time, 'Horario', reservation.horaFormateada),
                      _buildDetailRow(Icons.timer, 'Duración', '${reservation.duracionHoras.toStringAsFixed(1)} horas'),
                      _buildDetailRow(Icons.attach_money, 'Precio', reservation.precioFormateado),
                      _buildDetailRow(Icons.info, 'Estado', reservation.estadoDisplay ?? reservation.estado),
                      if (reservation.createdAt != null)
                        _buildDetailRow(Icons.schedule, 'Creada', _formatDateTime(reservation.createdAt!)),
                    ],
                  ),
                ),

                // Action buttons
                if (reservation.puedeCancelar) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelReservation(reservation, authService),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar Reserva'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _cancelReservation(Reservation reservation, AuthService authService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && reservation.id != null) {
      final reservationService = Provider.of<ReservationService>(context, listen: false);
      final token = authService.accessToken;

      if (token != null) {
        final success = await reservationService.cancelReservation(reservation.id!, token);

        if (success) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva cancelada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reservationService.error ?? 'Error al cancelar la reserva'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}