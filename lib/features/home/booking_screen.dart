import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';
import 'package:muniafu/features/home/widgets/booking_card.dart';
import 'package:muniafu/features/home/widgets/date_selector.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _requestsController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;

  // Sample booking data
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '1',
      'hotel': 'Sunset Paradise Resort',
      'room': 'Deluxe Ocean View',
      'checkIn': '2023-12-15',
      'checkOut': '2023-12-20',
      'status': 'Confirmed',
      'image': 'assets/images/hotel1.jpg',
      'price': 299.99,
    },
    {
      'id': '2',
      'hotel': 'Mountain View Lodge',
      'room': 'Executive Suite',
      'checkIn': '2024-01-10',
      'checkOut': '2024-01-15',
      'status': 'Pending',
      'image': 'assets/images/hotel2.jpg',
      'price': 429.99,
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        // Disable past dates
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
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
          // Personal Info Section
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person),
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
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
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
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          
          // Dates Section
          const Text(
            'Booking Dates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DateSelector(
                  label: "Check-In Date",
                  selectedDate: _checkInDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DateSelector(
                  label: "Check-Out Date",
                  selectedDate: _checkOutDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Occupancy Section
          const Text(
            'Occupancy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildCounterRow(
            label: "Adults",
            count: _adults,
            onIncrement: () => setState(() => _adults++),
            onDecrement: () => setState(() => _adults = _adults > 1 ? _adults - 1 : 1),
          ),
          const SizedBox(height: 12),
          
          _buildCounterRow(
            label: "Children",
            count: _children,
            onIncrement: () => setState(() => _children++),
            onDecrement: () => setState(() => _children = _children > 0 ? _children - 1 : 0),
          ),
          const SizedBox(height: 12),
          
          _buildCounterRow(
            label: "Rooms",
            count: _rooms,
            onIncrement: () => setState(() => _rooms++),
            onDecrement: () => setState(() => _rooms = _rooms > 1 ? _rooms - 1 : 1),
          ),
          const SizedBox(height: 24),
          
          // Special Requests
          const Text(
            'Special Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          TextFormField(
            controller: _requestsController,
            decoration: const InputDecoration(
              hintText: "Any special requests or requirements?",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          
          // Submit Button
          ButtonWidget.filled(
            text: "Proceed to Payment",
            onPressed: _submitBooking,
            isFullWidth: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onDecrement,
                color: Colors.grey[700],
              ),
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onIncrement,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      if (_checkInDate == null || _checkOutDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select check-in and check-out dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_checkOutDate!.difference(_checkInDate!).inDays < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out date must be after check-in date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Calculate total price based on duration and room count
      final duration = _checkOutDate!.difference(_checkInDate!).inDays;
      const nightlyRate = 149.99; // Sample rate - would come from hotel selection
      final totalPrice = (nightlyRate * _rooms * duration).toStringAsFixed(2);
      
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            amount: double.parse(totalPrice),
            bookingId: 'BOOK_${DateTime.now().millisecondsSinceEpoch}',
            currency: 'USD',
            bookingDetails: {
              'name': _nameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'checkIn': DateFormat('yyyy-MM-dd').format(_checkInDate!),
              'checkOut': DateFormat('yyyy-MM-dd').format(_checkOutDate!),
              'adults': _adults,
              'children': _children,
              'rooms': _rooms,
              'requests': _requestsController.text,
            },
          ),
        ),
      );
    }
  }

  Widget _buildBookingList() {
    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Bookings Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't made any bookings yet",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ButtonWidget.filled(
              text: 'Book Now',
              onPressed: () => _tabController.animateTo(0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return BookingCard(
          booking: booking,
          onTap: () => _showBookingDetails(booking),
        );
      },
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BookingDetailsBottomSheet(booking: booking);
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
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: "New Booking"),
            Tab(icon: Icon(Icons.list), text: "My Bookings"),
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

class BookingDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> booking;
  
  const BookingDetailsBottomSheet({
    super.key,
    required this.booking,
  });
  
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking['image'] ?? 'assets/images/hotel_placeholder.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['hotel'] ?? 'Unknown Hotel',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['room'] ?? 'Standard Room',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Check-In',
            value: booking['checkIn'] ?? 'N/A',
          ),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Check-Out',
            value: booking['checkOut'] ?? 'N/A',
          ),
          _buildDetailRow(
            icon: Icons.people,
            label: 'Duration',
            value: _calculateDuration(
              booking['checkIn'] ?? '',
              booking['checkOut'] ?? '',
            ),
          ),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Total Price',
            value: '\$${booking['price']?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ButtonWidget.outlined(
                  text: 'Modify',
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to modification screen
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ButtonWidget.filled(
                  text: 'Cancel',
                  onPressed: () => _showCancelConfirmation(context),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  String _calculateDuration(String checkIn, String checkOut) {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(checkIn);
      final end = DateFormat('yyyy-MM-dd').parse(checkOut);
      final duration = end.difference(start).inDays;
      return '$duration ${duration == 1 ? 'night' : 'nights'}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close details sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking has been cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}