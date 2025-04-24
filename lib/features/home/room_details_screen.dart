import 'package:flutter/material.dart';
import 'booking_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomName;
  final String roomImage;
  final String roomDescription;
  final double roomPrice;

  const RoomDetailsScreen({
    super.key,
    required this.roomName,
    this.roomImage = "assets/images/room_sample.jpg",
    this.roomDescription = "Free WiFi, Breakfast, Ocean View, King Bed",
    this.roomPrice = 199.00,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                roomImage,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Room Title
            Text(
              roomName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Price
            Text(
              "\$${roomPrice.toStringAsFixed(2)} per night",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Amenities Section
            const Text(
              "Amenities:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAmenityChip(Icons.wifi, "Free WiFi"),
                _buildAmenityChip(Icons.restaurant, "Breakfast"),
                _buildAmenityChip(Icons.king_bed, "King Bed"),
                _buildAmenityChip(Icons.beach_access, "Ocean View"),
                _buildAmenityChip(Icons.ac_unit, "Air Conditioning"),
                _buildAmenityChip(Icons.tv, "Smart TV"),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Description:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Our $roomName offers $roomDescription. Enjoy premium comfort with luxurious bedding, modern furnishings, and breathtaking views. Perfect for both business and leisure travelers.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Book Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}