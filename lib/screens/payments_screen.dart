import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../models/infraction_model.dart';
import '../models/charge_model.dart';
import 'payment_form_screen.dart';

class PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paymentService = PaymentService(context.read<AuthService>());
    _loadData();
  }

  Future<void> _loadData() async {
    await _paymentService.refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _paymentService,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pagos'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Infracciones'),
              Tab(text: 'Cargos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfractionsTab(),
            _buildChargesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfractionsTab() {
    return Consumer<PaymentService>(
      builder: (context, paymentService, child) {
        if (paymentService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final payableInfractions = paymentService.payableInfractions;
        final pendingReviewInfractions = paymentService.pendingReviewInfractions;

        return RefreshIndicator(
          onRefresh: () => paymentService.fetchInfractions(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payableInfractions.isNotEmpty) ...[
                  Text(
                    'Infracciones por Pagar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...payableInfractions.map((infraction) =>
                      _buildInfractionCard(infraction, true)),
                  SizedBox(height: 24),
                ],
                if (pendingReviewInfractions.isNotEmpty) ...[
                  Text(
                    'Pagos en Revisión',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...pendingReviewInfractions.map((infraction) =>
                      _buildInfractionCard(infraction, false)),
                ],
                if (payableInfractions.isEmpty && pendingReviewInfractions.isEmpty)
                  _buildEmptyState('No tienes infracciones pendientes'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChargesTab() {
    return Consumer<PaymentService>(
      builder: (context, paymentService, child) {
        if (paymentService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final payableCharges = paymentService.payableCharges;
        final pendingReviewCharges = paymentService.pendingReviewCharges;

        return RefreshIndicator(
          onRefresh: () => paymentService.fetchCharges(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payableCharges.isNotEmpty) ...[
                  Text(
                    'Cargos por Pagar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...payableCharges.map((charge) =>
                      _buildChargeCard(charge, true)),
                  SizedBox(height: 24),
                ],
                if (pendingReviewCharges.isNotEmpty) ...[
                  Text(
                    'Pagos en Revisión',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...pendingReviewCharges.map((charge) =>
                      _buildChargeCard(charge, false)),
                ],
                if (payableCharges.isEmpty && pendingReviewCharges.isEmpty)
                  _buildEmptyState('No tienes cargos pendientes'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfractionCard(Infraction infraction, bool canPay) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    infraction.tipoInfraccionNombre ?? 'Infracción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(infraction.estado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    infraction.estadoDisplay ?? infraction.estado,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              infraction.descripcion,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Fecha: ${_formatDate(infraction.fechaInfraccion)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (infraction.montoMulta != null || infraction.montoCalculado != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text(
                    'Monto: \$${(infraction.montoMulta ?? infraction.montoCalculado ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
            if (canPay) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPayment('infraction', infraction.id),
                  icon: Icon(Icons.payment),
                  label: Text('Pagar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargeCard(Charge charge, bool canPay) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    charge.concepto,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(charge.estado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    charge.estadoDisplay ?? charge.estado,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (charge.tipoCargoDisplay != null) ...[
              Text(
                charge.tipoCargoDisplay!,
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Vencimiento: ${_formatDate(charge.fechaVencimiento)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Monto: \$${charge.monto.toStringAsFixed(2)} ${charge.moneda}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (charge.montoPagado > 0) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Pagado: \$${charge.montoPagado.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ],
            if (canPay) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPayment('charge', charge.id),
                  icon: Icon(Icons.payment),
                  label: Text('Pagar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green[300],
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
      case 'multa_aplicada':
        return Colors.red;
      case 'en_revision':
        return Colors.orange;
      case 'pagado':
      case 'pagada':
        return Colors.green;
      case 'vencido':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToPayment(String type, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFormScreen(
          type: type,
          id: id,
          paymentService: _paymentService,
        ),
      ),
    );
  }
}