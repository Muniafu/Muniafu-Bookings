import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? roomData;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomAndUser();
  }

  Future<void> _fetchRoomAndUser() async {
    try {
      final roomSnap = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.booking.roomId)
          .get();
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.booking.userId)
          .get();

      setState(() {
        roomData = roomSnap.data();
        userData = userSnap.data();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading room/user data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room images carousel
                  if (roomData != null &&
                      roomData!['images'] != null &&
                      (roomData!['images'] as List).isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: (roomData!['images'] as List).length,
                        itemBuilder: (_, index) => Image.network(
                          roomData!['images'][index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: Text("No room images")),
                    ),

                  const SizedBox(height: 16),

                  // Booking Timeline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _bookingTimeline(
                      checkIn: booking.checkIn.toString().split(" ").first,
                      checkOut: booking.checkOut.toString().split(" ").first,
                    ),
                  ),
                  const Divider(height: 32),

                  // Guest Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child:
                              const Icon(Icons.person, color: Colors.black54),
                        ),
                        title: Text(userData?['name'] ?? "Guest"),
                        subtitle: Text(userData?['email'] ?? "No email provided"),
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Booking Info Section
                  _sectionTitle("Booking Information"),
                  _infoTile("Booking ID", booking.id),
                  _infoTile("Check-in",
                      booking.checkIn.toString().split(" ").first),
                  _infoTile("Check-out",
                      booking.checkOut.toString().split(" ").first),
                  _infoTile("Guests", booking.guests.toString()),

                  const Divider(height: 32),

                  // Payment Info Section
                  _sectionTitle("Payment Details"),
                  _infoTile("Total Price",
                      "\$${booking.totalPrice.toStringAsFixed(2)}"),
                  _infoTile("Payment ID", booking.paymentId),

                  const Divider(height: 32),

                  // Status & Cancel Option
                  _sectionTitle("Booking Status"),
                  ListTile(
                    title: const Text("Status"),
                    trailing: Chip(
                      label: Text(booking.status),
                      backgroundColor: _statusColor(booking.status),
                    ),
                  ),

                  if (booking.status.toLowerCase() == 'confirmed')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel Booking"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Cancel Booking?"),
                              content: const Text(
                                  "Are you sure you want to cancel this booking?"),
                              actions: [
                                TextButton(
                                  child: const Text("No"),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Yes, Cancel"),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await Provider.of<BookingProvider>(context,
                                    listen: false)
                                .cancelBooking(booking.id);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// --- Helper Widgets ---
  Widget _infoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'checked-in':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _bookingTimeline({required String checkIn, required String checkOut}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _timelineStep("Check-in", checkIn, true),
        Expanded(
          child: Container(height: 2, color: Colors.grey.shade400),
        ),
        _timelineStep("Stay", "In Progress", false, icon: Icons.hotel),
        Expanded(
          child: Container(height: 2, color: Colors.grey.shade400),
        ),
        _timelineStep("Check-out", checkOut, false),
      ],
    );
  }

  Widget _timelineStep(String label, String date, bool completed,
      {IconData? icon}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor:
              completed ? Colors.green : Colors.grey.shade400,
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 20)
              : const Icon(Icons.check, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}