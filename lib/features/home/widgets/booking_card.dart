import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;
  
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  booking['image'] ?? 'assets/images/hotel_placeholder.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              
              // Booking details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['hotel'] ?? 'Unknown Hotel',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['room'] ?? 'Standard Room',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${booking['checkIn'] ?? 'N/A'} - ${booking['checkOut'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            booking['status'] ?? 'Unknown',
                            style: TextStyle(
                              color: booking['status'] == 'Confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          backgroundColor: booking['status'] == 'Confirmed'
                              ? Colors.green[50]
                              : Colors.orange[50],
                        ),
                        Text(
                          '\$${booking['price']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}