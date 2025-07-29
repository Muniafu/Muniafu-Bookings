import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  DateTimeRange? _selectedDateRange;
  List<DocumentSnapshot> _bookings = [];
  bool _loading = true;

  final List<String> _statuses = ['all', 'pending', 'confirmed', 'rejected'];
  final List<String> _categories = ['all', 'Deluxe', 'Standard', 'Suite']; // example

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('bookings');

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    if (_selectedDateRange != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDateRange!.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_selectedDateRange!.end));
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();

    final filtered = _selectedCategory == 'all'
        ? snapshot.docs
        : await _filterByCategory(snapshot.docs, _selectedCategory);

    setState(() {
      _bookings = filtered;
      _loading = false;
    });
  }

  Future<List<DocumentSnapshot>> _filterByCategory(List<DocumentSnapshot> bookings, String category) async {
    final roomSnapshot = await FirebaseFirestore.instance.collection('rooms').get();
    final roomMap = {
      for (final doc in roomSnapshot.docs) doc.id: doc['category']
    };

    return bookings.where((doc) {
      final roomId = doc['roomId'];
      return roomMap[roomId] == category;
    }).toList();
  }

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({'status': status});
    _fetchBookings();
  }

  void _openDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _fetchBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                    ? const Center(child: Text('No bookings match the filters.'))
                    : ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (_, i) {
                          final data = _bookings[i].data() as Map<String, dynamic>;
                          final id = _bookings[i].id;

                          return Card(
                            child: ListTile(
                              title: Text('Room: ${data['roomId']}'),
                              subtitle: Text('User: ${data['userId']}\nStatus: ${data['status']}'),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(id, 'confirmed'),
                                    child: const Text('Approve'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(id, 'rejected'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          DropdownButton<String>(
            value: _selectedStatus,
            onChanged: (val) {
              setState(() => _selectedStatus = val!);
              _fetchBookings();
            },
            items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.capitalize()))).toList(),
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (val) {
              setState(() => _selectedCategory = val!);
              _fetchBookings();
            },
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize()))).toList(),
          ),
          ElevatedButton.icon(
            onPressed: _openDatePicker,
            icon: const Icon(Icons.date_range),
            label: const Text('Select Date Range'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}