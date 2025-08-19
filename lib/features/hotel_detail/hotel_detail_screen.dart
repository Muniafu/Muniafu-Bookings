import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/hotel_model.dart';
import '../../models/room_model.dart';

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;

  const HotelDetailScreen({super.key, required this.hotelId, required HotelModel hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailScreen> {
  late HotelProvider hotelProvider;
  late BookingProvider bookingProvider;

  HotelModel? hotel;
  List<RoomModel> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    hotelProvider = context.read<HotelProvider>();
    bookingProvider = context.read<BookingProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Fetch hotel details
    hotel = await hotelProvider.getHotelById(widget.hotelId);

    // Fetch rooms
    rooms = await hotelProvider.getRoomsByHotel(widget.hotelId);

    setState(() => isLoading = false);
  }

  void _bookRoom(RoomModel room) async {
    // For demo, assuming a fixed check-in/out and 1 guest
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser', // replace with auth user ID
      roomId: room.id,
      checkIn: DateTime.now(),
      checkOut: DateTime.now().add(Duration(days: 2)),
      guests: 1,
      totalPrice: room.pricePerNight,
      status: 'pending',
      paymentId: '',
    );

    await bookingProvider.createBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hotel == null) {
      return const Scaffold(
        body: Center(child: Text('Hotel not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(hotel!.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Images Carousel
            SizedBox(
              height: 250,
              child: PageView(
                children: hotel!.images
                    .map((img) => Image.network(img, fit: BoxFit.cover))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(hotel!.rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(hotel!.address, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text(hotel!.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel!.amenities
                        .map((a) => Chip(label: Text(a)))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Available Rooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rooms.length,
                    itemBuilder: (_, index) {
                      final room = rooms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${room.name} - \$${room.pricePerNight.toStringAsFixed(2)}'),
                          subtitle: Text('Capacity: ${room.capacity} guests'),
                          trailing: ElevatedButton(
                            onPressed: () => _bookRoom(room),
                            child: const Text('Book'),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
