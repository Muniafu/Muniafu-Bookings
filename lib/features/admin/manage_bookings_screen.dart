import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// ManageBookingsScreen
/// - Realtime bookings stream
/// - Filters: date-range, status, text (guest name/email)
/// - Expandable timeline cards
/// - Edit / update booking (status, dates, guests)
/// - Conflict detection (simple check for overlapping bookings per room)
/// - Export to CSV (generates CSV string, placeholder to share/save)
class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final bookingsRef = FirebaseFirestore.instance.collection('bookings');

  // Filters
  DateTime? _fromDate;
  DateTime? _toDate;
  String _statusFilter = 'all'; // all, confirmed, checked_in, cancelled
  String _queryText = '';

  // UI
  final DateFormat _dateFmt = DateFormat.yMMMd();
  bool _isExporting = false;

  // For conflict detection cache
  Map<String, List<Map<String, dynamic>>> _roomBookingsCache = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  /// Basic client-side filter function for bookings:
  bool _passesFilters(Map<String, dynamic> data) {
    try {
      final checkIn = DateTime.parse(data['checkIn']);
      final checkOut = DateTime.parse(data['checkOut']);

      if (_fromDate != null && checkOut.isBefore(_fromDate!)) return false;
      if (_toDate != null && checkIn.isAfter(_toDate!)) return false;

      if (_statusFilter != 'all' && (data['status'] ?? '') != _statusFilter) return false;

      if (_queryText.isNotEmpty) {
        final q = _queryText.toLowerCase();
        final guestName = ((data['guestName'] ?? '') as String).toLowerCase();
        final guestEmail = ((data['guestEmail'] ?? '') as String).toLowerCase();
        if (!guestName.contains(q) && !guestEmail.contains(q) && !(data['userId'] ?? '').toString().contains(q)) {
          return false;
        }
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  /// Conflict detection: returns true if this booking overlaps any other confirmed booking for same room
  bool _hasConflict(Map<String, dynamic> target, List<QueryDocumentSnapshot> allDocs) {
    try {
      final roomId = target['roomId'];
      final tIn = DateTime.parse(target['checkIn']);
      final tOut = DateTime.parse(target['checkOut']);
      for (var doc in allDocs) {
        final d = doc.data() as Map<String, dynamic>;
        if (doc.id == target['id']) continue; // skip self
        if (d['roomId'] != roomId) continue;
        if ((d['status'] ?? '') != 'confirmed') continue;
        final oIn = DateTime.parse(d['checkIn']);
        final oOut = DateTime.parse(d['checkOut']);
        final overlap = tIn.isBefore(oOut) && tOut.isAfter(oIn);
        if (overlap) return true;
      }
    } catch (_) {}
    return false;
  }

  /// Update booking doc with partial changes
  Future<void> _updateBookingDoc(String id, Map<String, dynamic> changes) async {
    await bookingsRef.doc(id).update(changes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking updated')));
    }
  }

  /// Cancel booking
  Future<void> _cancelBooking(String id) async {
    await bookingsRef.doc(id).update({'status': 'cancelled'});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    }
  }

  /// Export visible bookings to CSV string (caller may save/share)
  Future<String> _exportBookingsToCsv(List<Map<String, dynamic>> bookings) async {
    // Header
    final headers = [
      'id',
      'userId',
      'guestName',
      'guestEmail',
      'roomId',
      'checkIn',
      'checkOut',
      'guests',
      'totalPrice',
      'status',
      'paymentId'
    ];
    final csvRows = <List<String>>[headers];
    for (var b in bookings) {
      csvRows.add([
        b['id'] ?? '',
        b['userId'] ?? '',
        b['guestName'] ?? '',
        b['guestEmail'] ?? '',
        b['roomId'] ?? '',
        b['checkIn'] ?? '',
        b['checkOut'] ?? '',
        (b['guests'] ?? '').toString(),
        (b['totalPrice'] ?? '').toString(),
        b['status'] ?? '',
        b['paymentId'] ?? '',
      ]);
    }
    // Simple CSV builder (escape cellular commas)
    final buffer = StringBuffer();
    for (var row in csvRows) {
      buffer.writeln(row.map((c) => '"${c.toString().replaceAll('"', '""')}"').join(','));
    }
    return buffer.toString();
  }

  /// Placeholder: trigger reminders (you should wire to a Cloud Function or similar)
  Future<void> _triggerPreStayReminders(List<Map<String, dynamic>> bookings) async {
    // TODO: call your Cloud Function endpoint to send emails/SMS
    // e.g. use https callable function or axios/http to post to your endpoint
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pre-stay reminders triggered (placeholder)')));
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return Colors.green;
      case 'checked_in':
        return Colors.blue;
      case 'checked_out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _statusChip(String status) {
    return Chip(
      label: Text(status.replaceAll('_', ' ').toUpperCase()),
      backgroundColor: _statusColor(status).withOpacity(0.15),
      labelStyle: TextStyle(color: _statusColor(status)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        actions: [
          IconButton(
            tooltip: 'Export visible bookings to CSV',
            icon: _isExporting ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Icon(Icons.download),
            onPressed: _isExporting
                ? null
                : () async {
                    setState(() => _isExporting = true);
                    // Get current visible bookings via a on-screen query: here we fetch the filtered snapshot once
                    final snapshot = await bookingsRef.get();
                    final docs = snapshot.docs.map((d) => d.data()).where(_passesFilters).toList();
                    final csv = await _exportBookingsToCsv(docs);
                    setState(() => _isExporting = false);

                    // TODO: Save csv to device or share. As a simple fallback show in dialog to copy.
                    
                    if (!mounted) return;
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('CSV Export (preview)'),
                        content: SingleChildScrollView(child: Text(csv.substring(0, csv.length.clamp(0, 2000)))),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'trigger_reminders') {
                final snapshot = await bookingsRef.get();
                final docs = snapshot.docs.map((d) => d.data()).where(_passesFilters).toList();
                await _triggerPreStayReminders(docs);
              } else if (v == 'revenue_report') {
                // placeholder: open analytics screen or compute revenue
                final snapshot = await bookingsRef.get();
                final docs = snapshot.docs.map((d) => d.data()).where(_passesFilters).toList();
                double revenue = 0;
                for (var b in docs) {
                  revenue += (b['totalPrice'] ?? 0) as num;
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Total revenue (filtered): \$${revenue.toStringAsFixed(2)}')));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'trigger_reminders', child: Text('Trigger pre-stay reminders')),
              const PopupMenuItem(value: 'revenue_report', child: Text('Compute filtered revenue')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search guest name / email / userId'),
                    onChanged: (v) => setState(() => _queryText = v.trim()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _pickFromDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(_fromDate == null ? 'From' : _dateFmt.format(_fromDate!)),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: _pickToDate,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(_toDate == null ? 'To' : _dateFmt.format(_toDate!)),
                ),
              ],
            ),
          ),

          // Status chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _statusChoice('all', 'All'),
                _statusChoice('confirmed', 'Confirmed'),
                _statusChoice('checked_in', 'Checked In'),
                _statusChoice('checked_out', 'Checked Out'),
                _statusChoice('cancelled', 'Cancelled'),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingsRef.orderBy('checkIn', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                // Optionally rebuild cache for conflict detection
                _roomBookingsCache.clear();
                for (var d in docs) {
                  final m = d.data() as Map<String, dynamic>;
                  final roomId = m['roomId'] ?? 'unknown';
                  _roomBookingsCache.putIfAbsent(roomId, () => []).add(m);
                }

                // Apply client-side filters
                final visibleDocs = docs.where((d) => _passesFilters(d.data() as Map<String, dynamic>)).toList();

                if (visibleDocs.isEmpty) {
                  return const Center(child: Text('No bookings found for selected filters.'));
                }

                // Timeline / List
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final doc = visibleDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id; // ensure id present
                    final hasConflict = _hasConflict(data, docs);

                    return _BookingCard(
                      data: data,
                      conflict: hasConflict,
                      onUpdate: (changes) => _updateBookingDoc(doc.id, changes),
                      onCancel: () => _cancelBooking(doc.id),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: visibleDocs.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChoice(String key, String label) {
    final selected = _statusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = key),
      ),
    );
  }
}

/// Individual booking card with expansion for details and inline editing.
/// - data is the booking map from Firestore (with id)
class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool conflict;
  final Future<void> Function(Map<String, dynamic> changes) onUpdate;
  final Future<void> Function() onCancel;

  const _BookingCard({
    required this.data,
    required this.conflict,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _expanded = false;
  bool _editing = false;
  late TextEditingController _guestCtrl;
  late DateTime _checkIn;
  late DateTime _checkOut;
  late String _status;

  final DateFormat _dateFmt = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _guestCtrl = TextEditingController(text: (widget.data['guests'] ?? '').toString());
    _checkIn = DateTime.parse(widget.data['checkIn']);
    _checkOut = DateTime.parse(widget.data['checkOut']);
    _status = (widget.data['status'] ?? 'confirmed');
  }

  @override
  void dispose() {
    _guestCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _checkIn : _checkOut;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _checkIn = picked;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final status = d['status'] ?? 'unknown';
    final color = _statusColor(status);
    final guestName = d['guestName'] ?? 'Guest';
    final guestEmail = d['guestEmail'] ?? '';

    return Card(
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.book_online, color: color)),
            title: Text('Booking ${d['id']?.toString().substring(0, 6) ?? '—'} • \$${(d['totalPrice'] ?? 0).toString()}'),
            subtitle: Text('${_dateFmt.format(DateTime.parse(d['checkIn']))} → ${_dateFmt.format(DateTime.parse(d['checkOut']))}'),
            trailing: Wrap(
              spacing: 8,
              children: [
                if (widget.conflict)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Text('CONFLICT', style: TextStyle(color: Colors.red)),
                  ),
                Chip(label: Text(status.toString().toUpperCase()), backgroundColor: color.withOpacity(0.15)),
                IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () => setState(() => _expanded = !_expanded)),
              ],
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Guest & payment
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(guestName),
                  subtitle: Text(guestEmail),
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text('Payment: ${(d['paymentId'] ?? 'N/A')}'),
                  subtitle: Text('Amount: \$${(d['totalPrice'] ?? 0).toString()}'),
                ),
                const SizedBox(height: 6),
                // Special requests
                if ((d['specialRequests'] ?? '').toString().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.note),
                    title: const Text('Special Requests'),
                    subtitle: Text(d['specialRequests'] ?? ''),
                  ),

                const Divider(),

                // Edit area
                if (_editing) ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text('Check-in: ${_dateFmt.format(_checkIn)}'),
                        onPressed: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range_outlined),
                        label: Text('Check-out: ${_dateFmt.format(_checkOut)}'),
                        onPressed: () => _pickDate(isStart: false),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  TextFormField(controller: _guestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Guests')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                      DropdownMenuItem(value: 'checked_in', child: Text('Checked In')),
                      DropdownMenuItem(value: 'checked_out', child: Text('Checked Out')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate and send patch update
                          final guests = int.tryParse(_guestCtrl.text) ?? (d['guests'] ?? 1);
                          final changes = {
                            'guests': guests,
                            'checkIn': _checkIn.toIso8601String(),
                            'checkOut': _checkOut.toIso8601String(),
                            'status': _status,
                          };
                          await widget.onUpdate(changes);
                          setState(() => _editing = false);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ] else ...[
                  // Non-edit view actions
                  Row(
                    children: [
                      TextButton.icon(onPressed: () => setState(() => _editing = true), icon: const Icon(Icons.edit), label: const Text('Modify')),
                      const SizedBox(width: 8),
                      TextButton.icon(onPressed: widget.onCancel, icon: const Icon(Icons.cancel), label: const Text('Cancel')),
                    ],
                  ),
                ],
              ]),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return Colors.green;
      case 'checked_in':
        return Colors.blue;
      case 'checked_out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}