import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/booking.dart';
//import '../../data/services/booking_service.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({Key? key}) : super(key: key);

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  DateTimeRange? _selectedDateRange;

  final List<String> _statuses = ['all', 'pending', 'confirmed', 'cancelled', 'completed'];
  final List<String> _categories = ['all', 'Deluxe', 'Standard', 'Suite']; // Example categories

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('bookings');

      // Apply status filter
      if (_selectedStatus != 'all') {
        query = query.where('status', isEqualTo: _selectedStatus);
      }

      // Apply date range filter
      if (_selectedDateRange != null) {
        query = query
            .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDateRange!.start))
            .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(_selectedDateRange!.end));
      }

      final snapshot = await query.orderBy('checkInDate', descending: true).get();
      final bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      // Apply category filter if needed
      if (_selectedCategory != 'all') {
        final roomSnapshot = await FirebaseFirestore.instance.collection('rooms').get();
        final roomMap = {
          for (final doc in roomSnapshot.docs) doc.id: doc['type'] // Assuming 'type' field exists
        };

        setState(() {
          _bookings = bookings.where((booking) {
            return roomMap[booking.roomId] == _selectedCategory;
          }).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _bookings = bookings;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
    }
  }

  Future<void> _updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': status.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking ${status.name} successfully')),
      );
      
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _fetchBookings();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = 'all';
      _selectedCategory = 'all';
      _selectedDateRange = null;
    });
    _fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterControls(),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                    ? const Center(child: Text('No bookings found'))
                    : ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return _buildBookingCard(booking);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          DropdownButton<String>(
            value: _selectedStatus,
            items: _statuses.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status.capitalize()),
            )).toList(),
            onChanged: (value) {
              setState(() => _selectedStatus = value!);
              _fetchBookings();
            },
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            items: _categories.map((category) => DropdownMenuItem(
              value: category,
              child: Text(category.capitalize()),
            )).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
              _fetchBookings();
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              _selectedDateRange == null
                  ? 'Select Dates'
                  : '${DateFormat.yMd().format(_selectedDateRange!.start)} - ${DateFormat.yMd().format(_selectedDateRange!.end)}',
            ),
            onPressed: _selectDateRange,
          ),
          OutlinedButton(
            child: const Text('Clear Filters'),
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final theme = Theme.of(context);
    final isActive = booking.status == BookingStatus.confirmed && 
        booking.checkOutDate.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    booking.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(theme, booking.status),
                    ),
                  ),
                  backgroundColor: _getStatusBackgroundColor(theme, booking.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('User: ${booking.userId.substring(0, 8)}...'),
            Text('Room: ${booking.roomId} (${booking.hotelName})'),
            const SizedBox(height: 8),
            Text('Check-in: ${DateFormat.yMMMd().format(booking.checkInDate)}'),
            Text('Check-out: ${DateFormat.yMMMd().format(booking.checkOutDate)}'),
            Text('Guests: ${booking.numberOfGuests}'),
            Text('Total: \$${booking.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            if (isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateBookingStatus(booking.id, BookingStatus.cancelled),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus(booking.id, BookingStatus.completed),
                    child: const Text('MARK COMPLETED'),
                  ),
                ],
              ),
            if (booking.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Created: ${DateFormat.yMMMd().add_Hms().format(booking.createdAt!)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return theme.colorScheme.onPrimary;
      case BookingStatus.cancelled:
        return theme.colorScheme.onError;
      case BookingStatus.pending:
        return theme.colorScheme.onSecondary;
      case BookingStatus.completed:
        return theme.colorScheme.onPrimary;
    }
  }

  Color _getStatusBackgroundColor(ThemeData theme, BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return theme.colorScheme.primary;
      case BookingStatus.cancelled:
        return theme.colorScheme.error;
      case BookingStatus.pending:
        return theme.colorScheme.secondary;
      case BookingStatus.completed:
        return theme.colorScheme.primary.withOpacity(0.7);
    }
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}