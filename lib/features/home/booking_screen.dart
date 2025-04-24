import 'package:flutter/material.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '1',
      'hotel': 'Sunset Paradise Resort',
      'room': 'Deluxe Ocean View',
      'checkIn': '2023-12-15',
      'checkOut': '2023-12-20',
      'status': 'Confirmed'
    },
    {
      'id': '2',
      'hotel': 'Mountain View Lodge',
      'room': 'Executive Suite',
      'checkIn': '2024-01-10',
      'checkOut': '2024-01-15',
      'status': 'Pending'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked.add(const Duration(days: 1)))) {
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate == null || picked.isAfter(_checkInDate!)) {
            _checkOutDate = picked;
          }
        }
      });
    }
  }

  Widget _buildNewBookingForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Check-In Date",
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_checkInDate != null 
                      ? "${_checkInDate!.toLocal()}".split(' ')[0]
                      : 'Select date'),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Check-Out Date",
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_checkOutDate != null
                      ? "${_checkOutDate!.toLocal()}".split(' ')[0]
                      : 'Select date'),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Special Requests",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate() && 
                  _checkInDate != null && 
                  _checkOutDate != null) {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      amount: 299.99, // Replace with actual amount calculation
                      bookingId: 'BOOKING_${DateTime.now().millisecondsSinceEpoch}',
                      currency: 'USD',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields and select dates'),
                  ),
                );
              }
            },
            child: const Text("Proceed to Payment", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    if (_bookings.isEmpty) {
      return const Center(
        child: Text('You have no bookings yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              booking['hotel'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Room: ${booking['room']}"),
                const SizedBox(height: 4),
                Text("Check-In: ${booking['checkIn']}"),
                const SizedBox(height: 4),
                Text("Check-Out: ${booking['checkOut']}"),
                const SizedBox(height: 8),
                Chip(
                  label: Text(booking['status']),
                  backgroundColor: booking['status'] == 'Confirmed'
                      ? Colors.green[100]
                      : Colors.orange[100],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to booking details
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "New Booking", icon: Icon(Icons.add)),
            Tab(text: "My Bookings", icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewBookingForm(),
          _buildBookingList(),
        ],
      ),
    );
  }
}