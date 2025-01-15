import 'package:flutter/material.dart';

// Showcase available hotel rooms 
class HotelRoomsScreen extends StatelessWidget{
  const HotelRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Rooms')),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.hotel),
            title: Text('Room ${index + 1}'),
            trailing: ElevatedButton(
              onPressed: (){

                // Navigate to room details screen
              },
              child: const Text('Book Now'),
            ),
          );
        },
      ),
    );
  }
}