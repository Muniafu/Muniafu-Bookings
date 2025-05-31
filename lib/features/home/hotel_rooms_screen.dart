import 'package:flutter/material.dart';
import 'room_details_screen.dart';

class HotelRoomsScreen extends StatelessWidget {
  final String? destination;

  const HotelRoomsScreen({super.key, this.destination});

  // Sample room data
  final List<Map<String, dynamic>> rooms = const [
    {
      'type': 'Deluxe Room',
      'description': 'Sea view, Free breakfast, 35 sqm',
      'icon': Icons.king_bed,
      'price': '\$199/night'
    },
    {
      'type': 'Executive Suite',
      'description': 'City view, Lounge access, 50 sqm',
      'icon': Icons.business,
      'price': '\$299/night'
    },
    {
      'type': 'Family Room',
      'description': '2 bedrooms, Kitchenette, 60 sqm',
      'icon': Icons.family_restroom,
      'price': '\$349/night'
    },
    {
      'type': 'Standard Room',
      'description': 'Garden view, 25 sqm',
      'icon': Icons.single_bed,
      'price': '\$149/night'
    },
    {
      'type': 'Presidential Suite',
      'description': 'Panoramic views, Butler service, 100 sqm',
      'icon': Icons.villa,
      'price': '\$599/night'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination ?? "Available Rooms"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(room['icon'], size: 32),
              title: Text(
                room['type'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room['description']),
                  const SizedBox(height: 4),
                  Text(
                    room['price'],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text("Details"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoomDetailsScreen(roomName: '',),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    child: const Text("Book"),
                    onPressed: () {
                      // Add booking functionality
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}