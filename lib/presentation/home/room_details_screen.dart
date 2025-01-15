import 'package:flutter/material.dart';
import 'package:muniafu/presentation/home/widgets/text_widget.dart';

// Detailed information about a  specific room

class RoomDetailsScreen extends StatelessWidget{
  final String roomName;

  const RoomDetailsScreen({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(roomName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: 'Details of $roomName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
              const SizedBox(height: 20),
              const Text('Description and amenities of the room go here.'),
              ElevatedButton(
                onPressed: () {
                  
                  // Implement booking logic
                },
                child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}