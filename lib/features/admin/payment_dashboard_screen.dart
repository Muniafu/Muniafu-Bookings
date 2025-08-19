import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

class PaymentDashboardScreen extends StatefulWidget {
  const PaymentDashboardScreen({super.key});

  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen> {
  String _filterStatus = 'all';
  DateTimeRange? _dateRange;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search payments',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: _buildPaymentList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();

    if (paymentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentProvider.error != null) {
      return Center(child: Text(paymentProvider.error!));
    }

    return FutureBuilder<List<PaymentModel>>(
      future: paymentProvider.getAdminPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No payments found'));
        }

        // Apply filters
        var filteredPayments = snapshot.data!;
        
        // Status filter
        if (_filterStatus != 'all') {
          filteredPayments = filteredPayments
              .where((p) => p.status == _filterStatus)
              .toList();
        }

        // Date range filter
        if (_dateRange != null) {
          filteredPayments = filteredPayments
              .where((p) => p.createdAt.isAfter(_dateRange!.start) && 
                            p.createdAt.isBefore(_dateRange!.end))
              .toList();
        }

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          filteredPayments = filteredPayments
              .where((p) => 
                  p.bookingId.toLowerCase().contains(searchTerm) ||
                  p.userId.toLowerCase().contains(searchTerm) ||
                  p.gatewayReference.toLowerCase().contains(searchTerm))
              .toList();
        }

        if (filteredPayments.isEmpty) {
          return const Center(child: Text('No matching payments found'));
        }

        return ListView.builder(
          itemCount: filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = filteredPayments[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking: ${payment.bookingId}'),
                    Text('Method: ${payment.paymentMethod}'),
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm').format(payment.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    payment.status.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(payment.status),
                ),
                onTap: () => _showPaymentDetails(context, payment),
              ),
            );
          },
        );
      },
    );
  }

  Color? _getStatusColor(String status) {
    switch (status) {
      case 'successful':
        return Colors.green[100];
      case 'failed':
        return Colors.red[100];
      case 'pending':
        return Colors.amber[100];
      default:
        return Colors.grey[100];
    }
  }

  void _showPaymentDetails(BuildContext context, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details - ${payment.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Amount', '${payment.currency} ${payment.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Booking ID', payment.bookingId),
              _buildDetailRow('User ID', payment.userId),
              _buildDetailRow('Payment Method', payment.paymentMethod),
              _buildDetailRow('Status', payment.status.toUpperCase()),
              _buildDetailRow('Reference', payment.gatewayReference),
              _buildDetailRow('Created', DateFormat.yMMMd().add_jm().format(payment.createdAt)),
              if (payment.completedAt != null)
                _buildDetailRow('Completed', DateFormat.yMMMd().add_jm().format(payment.completedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (payment.status == 'pending')
            TextButton(
              onPressed: () {
                // Add manual verification logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment verification initiated')),
                );
              },
              child: const Text('VERIFY'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterStatus,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'successful', child: Text('Successful')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (value) => setState(() => _filterStatus = value!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDateRange(context),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date Range'),
                child: Text(
                  _dateRange == null
                      ? 'Select date range'
                      : '${DateFormat.yMd().format(_dateRange!.start)} - ${DateFormat.yMd().format(_dateRange!.end)}',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = 'all';
                _dateRange = null;
              });
              Navigator.pop(context);
            },
            child: const Text('RESET'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }
}