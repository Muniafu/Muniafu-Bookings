import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_room_screen.dart';
import '../../models/room_model.dart';

class RoomsListScreen extends StatefulWidget {
  final String hotelId;
  const RoomsListScreen({super.key, required this.hotelId});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  final roomsRef = FirebaseFirestore.instance.collection('rooms');
  final bookingsRef = FirebaseFirestore.instance.collection('bookings');

  bool _isGrid = false;
  int _limit = 20; // simple pagination
  String _search = '';
  bool _loadingMore = false;

  // Utility: build query with pagination + search
  Query _roomsQuery() {
    Query q = roomsRef.where('hotelId', isEqualTo: widget.hotelId).orderBy('type');
    if (_search.trim().isNotEmpty) {
      // simple name search - uses 'type' field
      q = q.where('type', isGreaterThanOrEqualTo: _search).where('type', isLessThanOrEqualTo: '$_search\uf8ff');
    }
    return q.limit(_limit);
  }

  Future<void> _duplicateRoom(String docId, Map<String, dynamic> data) async {
    try {
      final newData = Map<String, dynamic>.from(data);
      newData.remove('id'); // Firestore will assign new id
      final res = await roomsRef.add(newData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplicated to ${res.id}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplicate failed: $e')));
    }
  }

  Future<void> _toggleMaintenance(String docId, bool current) async {
    try {
      await roomsRef.doc(docId).update({'isUnderMaintenance': !current});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _deleteRoom(String docId) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete room'),
            content: const Text('Delete this room? This action is irreversible.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await roomsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _showSeasonalPricingSheet(String docId, Map<String, dynamic> roomData) async {
    // seasonalPrices stored as list of maps: {start: ISO, end: ISO, price: double, label: string}
    final List existing = roomData['seasonalPrices'] ?? [];
    final controllerLabel = TextEditingController();
    final controllerPrice = TextEditingController();
    DateTime? start;
    DateTime? end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: StatefulBuilder(builder: (c, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Seasonal Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (existing.isNotEmpty)
                  Column(
                    children: existing.map<Widget>((e) {
                      final label = e['label'] ?? '${e['start']} → ${e['end']}';
                      final price = e['price'] ?? '';
                      return ListTile(title: Text(label), trailing: Text('\$${price.toString()}'));
                    }).toList(),
                  ),
                TextField(controller: controllerLabel, decoration: const InputDecoration(labelText: 'Label (e.g. Xmas)')),
                TextField(controller: controllerPrice, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          );
                          if (p != null) setState(() => start = p);
                        },
                        child: Text(start == null ? 'Start date' : start!.toLocal().toString().split(' ').first),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          );
                          if (p != null) setState(() => end = p);
                        },
                        child: Text(end == null ? 'End date' : end!.toLocal().toString().split(' ').first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (controllerPrice.text.isEmpty || start == null || end == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                      return;
                    }
                    final entry = {
                      'label': controllerLabel.text.trim(),
                      'price': double.parse(controllerPrice.text),
                      'start': start!.toIso8601String(),
                      'end': end!.toIso8601String(),
                    };
                    final updated = List.from(existing)..add(entry);
                    await roomsRef.doc(docId).update({'seasonalPrices': updated});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seasonal price saved')));
                  },
                  child: const Text('Save seasonal price'),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        );
      },
    );
  }

  Future<bool> _isRoomBookedToday(String roomId) async {
    try {
      final now = DateTime.now();
      final snapshot = await bookingsRef
          .where('roomId', isEqualTo: roomId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final DateTime ci = DateTime.parse(data['checkIn']);
        final DateTime co = DateTime.parse(data['checkOut']);
        if (now.isAfter(ci.subtract(const Duration(seconds: 1))) && now.isBefore(co.add(const Duration(seconds: 1)))) return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> _computeOccupancyAndRevenue(String roomId, {int days = 30}) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final snapshot = await bookingsRef.where('roomId', isEqualTo: roomId).where('status', isEqualTo: 'confirmed').get();
    int bookedNights = 0;
    double revenue = 0.0;
    for (var doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final ci = DateTime.parse(data['checkIn']);
      final co = DateTime.parse(data['checkOut']);
      // overlap with range [start,end]
      final overlapStart = ci.isAfter(start) ? ci : start;
      final overlapEnd = co.isBefore(end) ? co : end;
      if (overlapEnd.isAfter(overlapStart)) {
        bookedNights += overlapEnd.difference(overlapStart).inDays;
        revenue += (data['totalPrice'] ?? 0) as num;
      }
    }
    final occupancy = (bookedNights / (days)).clamp(0, 1); // rough ratio per night
    return {'occupancyRate': occupancy, 'revenue': revenue};
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    // increase limit and rebuild stream
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _limit += 20;
      _loadingMore = false;
    });
  }

  Widget _buildRoomCard(String id, Map<String, dynamic> data) {
    final type = data['type'] ?? data['name'] ?? 'Room';
    final price = (data['price'] ?? 0).toDouble();
    final capacity = data['capacity'] ?? data['beds'] ?? 1;
    final images = (data['images'] as List?)?.cast<String>() ?? [];
    final maintenance = data['isUnderMaintenance'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoomScreen(hotelId: widget.hotelId, roomId: id, roomData: data))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              SizedBox(
                width: 120,
                height: 84,
                child: images.isNotEmpty
                    ? Image.network(images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                    : Container(color: Colors.grey[200], child: const Icon(Icons.hotel, size: 40)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    if (maintenance)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('Maintenance', style: TextStyle(color: Colors.red)))
                    else
                      const SizedBox(),
                  ]),
                  const SizedBox(height: 6),
                  Text('Capacity: $capacity • \$${price.toStringAsFixed(2)}/night'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    FutureBuilder<bool>(
                      future: _isRoomBookedToday(id),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2));
                        final booked = snap.data!;
                        return Chip(
                          label: Text(booked ? 'Occupied Today' : 'Available'),
                          backgroundColor: booked ? Colors.red.shade100 : Colors.green.shade100,
                          labelStyle: TextStyle(color: booked ? Colors.red.shade800 : Colors.green.shade800),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSeasonalPricingSheet(id, data),
                      icon: const Icon(Icons.thermostat),
                      label: const Text('Seasonal Price'),
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.orange.shade50, foregroundColor: Colors.orange),
                    ),
                    IconButton(onPressed: () => _duplicateRoom(id, data), icon: const Icon(Icons.copy)),
                    IconButton(onPressed: () => _toggleMaintenance(id, maintenance), icon: Icon(maintenance ? Icons.build_circle : Icons.build)),
                    IconButton(onPressed: () => _deleteRoom(id), icon: const Icon(Icons.delete, color: Colors.red)),
                    IconButton(
                      onPressed: () async {
                        final stats = await _computeOccupancyAndRevenue(id);
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Room metrics (30d)'),
                            content: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('Occupancy: ${(stats['occupancyRate'] * 100).toStringAsFixed(1)}%'),
                              const SizedBox(height: 6),
                              Text('Revenue: \$${(stats['revenue']).toStringAsFixed(2)}'),
                            ]),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String id, Map<String, dynamic> data) {
    final type = data['type'] ?? data['name'] ?? 'Room';
    final price = (data['price'] ?? 0).toDouble();
    final images = (data['images'] as List?)?.cast<String>() ?? [];
    final maintenance = data['isUnderMaintenance'] ?? false;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoomScreen(hotelId: widget.hotelId, roomId: id, roomData: data))),
        child: Column(
          children: [
            Expanded(
              child: images.isNotEmpty ? Image.network(images.first, fit: BoxFit.cover) : Container(color: Colors.grey[200]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${price.toStringAsFixed(0)}'),
                  IconButton(onPressed: () => _duplicateRoom(id, data), icon: const Icon(Icons.copy, size: 18)),
                ]),
                if (maintenance) Container(padding: const EdgeInsets.all(4), color: Colors.red.shade100, child: const Text('Maintenance', style: TextStyle(color: Colors.red))),
              ]),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Rooms"),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
            tooltip: 'Toggle view',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showModalBottomSheet(context: context, builder: (_) => _buildAdminActions()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoomScreen(hotelId: widget.hotelId))),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search rooms by type...'),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _roomsQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No rooms found'));

                if (_isGrid) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = (doc.data() as Map<String, dynamic>);
                      return _buildGridItem(doc.id, data);
                    },
                  );
                } else {
                  return ListView.builder(
                    itemCount: docs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == docs.length) {
                        // Load more control
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: _loadingMore
                                ? const CircularProgressIndicator()
                                : ElevatedButton(onPressed: _loadMore, child: const Text('Load more')),
                          ),
                        );
                      }
                      final doc = docs[index];
                      final data = (doc.data() as Map<String, dynamic>);
                      return _buildRoomCard(doc.id, data);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(leading: const Icon(Icons.sync_alt), title: const Text('Bulk update seasonal pricing'), onTap: () {}),
          ListTile(leading: const Icon(Icons.schedule), title: const Text('Integrate housekeeping'), onTap: () {}),
          ListTile(leading: const Icon(Icons.analytics), title: const Text('Occupancy & revenue report'), onTap: () {}),
          ListTile(leading: const Icon(Icons.close), title: const Text('Close'), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}