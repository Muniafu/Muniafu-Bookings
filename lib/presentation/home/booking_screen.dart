import 'package:flutter/material.dart';

//Display the user's bookings
class BookingScreen extends StatelessWidget{
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Bookings')),
      body: const Center(
        child: Text('List of your bookings will appear here.'),
      ),
    );
  }
}