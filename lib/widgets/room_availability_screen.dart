import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomAvailabilityScreen extends StatefulWidget {
  final String roomId;
  const RoomAvailabilityScreen({super.key, required this.roomId});

  @override
  State<RoomAvailabilityScreen> createState() => _RoomAvailabilityScreenState();
}

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double? customPrice;
  bool available = true;

  Future<Map<String, dynamic>> _loadAvailability(DateTime day) async {
    final doc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('availability')
        .doc(day.toIso8601String().split('T')[0])
        .get();

    return doc.exists ? doc.data()! : {'available': true, 'price': null};
  }

  Future<void> _saveAvailability() async {
    final dateId = _selectedDay!.toIso8601String().split('T')[0];
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('availability')
        .doc(dateId)
        .set({'available': available, 'price': customPrice});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room Availability")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) async {
              setState(() {
                _focusedDay = focused;
                _selectedDay = selected;
              });

              final data = await _loadAvailability(selected);
              setState(() {
                available = data['available'] ?? true;
                customPrice = (data['price'] as num?)?.toDouble();
              });
            },
          ),
          if (_selectedDay != null) ...[
            SwitchListTile(
              title: const Text("Available"),
              value: available,
              onChanged: (v) => setState(() => available = v),
            ),
            ListTile(
              title: const Text("Price Override"),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: customPrice?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => customPrice = double.tryParse(v),
                ),
              ),
            ),
            ElevatedButton(onPressed: _saveAvailability, child: const Text("Save for Selected Date"))
          ]
        ],
      ),
    );
  }
}