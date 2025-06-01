import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';
import '../../data/models/room.dart';
import '../../providers/booking_provider.dart';
import 'payment_screen.dart';
import '../../app/core/widgets/button_widget.dart';
import 'package:muniafu/features/home/widgets/date_selector.dart';

class BookingScreen extends StatefulWidget {
  final Room? room;

  const BookingScreen({super.key, this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    // Determine tab count based on context
    final tabCount = widget.room != null ? 2 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    
    // Pre-fill form if user data is available
    _prefillUserData();
  }

  void _prefillUserData() {
    // In a real app, you'd get this from user profile
    _nameController.text = 'John Doe';
    _emailController.text = 'john@example.com';
    _phoneController.text = '+1234567890';
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
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset check-out if invalid
          if (_checkOutDate != null && 
              _checkOutDate!.isBefore(picked.add(const Duration(days: 1)))) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<BookingProvider>(context);
    final hasRoomContext = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasRoomContext ? 'Book Room' : 'My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: hasRoomContext
              ? const [
                  Tab(icon: Icon(Icons.add), text: "New Booking"),
                  Tab(icon: Icon(Icons.list), text: "My Bookings"),
                ]
              : const [
                  Tab(text: "Active"),
                  Tab(text: "Past"),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: hasRoomContext
            ? [
                _buildNewBookingForm(),
                _buildUserBookings(provider),
              ]
            : [
                _buildBookingList(provider.activeBookings),
                _buildBookingList(provider.pastBookings),
              ],
      ),
    );
  }

  Widget _buildNewBookingForm() {
    final theme = Theme.of(context);
    final room = widget.room!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Room info card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  room.images.isNotEmpty
                      ? Image.network(
                          room.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.hotel, size: 40),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.type,
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${room.pricePerNight.toStringAsFixed(2)}/night',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

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
            onPressed: () => _submitBooking(room),
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

  void _submitBooking(Room room) {
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
      
      // Calculate total price
      final duration = _checkOutDate!.difference(_checkInDate!).inDays;
      final totalPrice = room.pricePerNight * _rooms * duration;
      
      // Create booking model
      final booking = Booking(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id', // Would come from auth
        hotelId: room.hotelId,
        hotelName: 'Hotel Name', // Would come from hotel service
        roomId: room.id,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        numberOfGuests: _adults + _children, // Fixed: Added required parameter
        totalPrice: totalPrice,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        specialRequests: _requestsController.text.isNotEmpty
            ? [_requestsController.text]
            : null,
      );
      
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (_) => PaymentScreen.real( // Fixed: Use named constructor
            amount: totalPrice,
            currency: 'USD',
            bookingId: booking.id,
            booking: booking,
            room: room,
            guestInfo: {
              'name': _nameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'adults': _adults,
              'children': _children,
            },
          ),
        ),
      );
    }
  }

  Widget _buildUserBookings(BookingProvider provider) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.bookings.isEmpty) {
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
          itemCount: provider.bookings.length,
          itemBuilder: (context, index) => BookingCard(
            booking: provider.bookings[index],
            onTap: () => _showBookingDetails(context, provider.bookings[index]),
          ),
        );
      },
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (_, i) => BookingCard(
        booking: bookings[i],
        onTap: () => _showBookingDetails(context, bookings[i]),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BookingDetailsBottomSheet(booking: booking),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = booking.checkOutDate.difference(booking.checkInDate).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hotel, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotelName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(booking.checkInDate)} - '
                      '${DateFormat('MMM dd, yyyy').format(booking.checkOutDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            booking.status.name.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(booking.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _getStatusColor(booking.status).withOpacity(0.1),
                        ),
                        const Spacer(),
                        Text(
                          '\$${booking.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$duration ${duration == 1 ? 'night' : 'nights'} · ${booking.specialRequests?.length ?? 0} requests',
                      style: const TextStyle(color: Colors.grey),
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }
}

class BookingDetailsBottomSheet extends StatelessWidget {
  final Booking booking;

  const BookingDetailsBottomSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = booking.checkOutDate.difference(booking.checkInDate).inDays;

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
              // Placeholder image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hotel, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotelName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room ID: ${booking.roomId}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        booking.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                        ),
                      ),
                      backgroundColor: _getStatusColor(booking.status).withOpacity(0.1),
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
            value: DateFormat('MMM dd, yyyy').format(booking.checkInDate),
          ),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Check-Out',
            value: DateFormat('MMM dd, yyyy').format(booking.checkOutDate),
          ),
          _buildDetailRow(
            icon: Icons.nights_stay,
            label: 'Duration',
            value: '$duration ${duration == 1 ? 'night' : 'nights'}',
          ),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Total Price',
            value: '\$${booking.totalPrice.toStringAsFixed(2)}',
          ),
          if (booking.specialRequests != null && booking.specialRequests!.isNotEmpty)
            _buildDetailRow(
              icon: Icons.note,
              label: 'Requests',
              value: booking.specialRequests!.join(', '),
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
                  onPressed: () => _showCancelConfirmation(context, booking),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  void _showCancelConfirmation(BuildContext context, Booking booking) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final parentContext = context;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await provider.cancelBooking(booking.id);
                if (parentContext.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(parentContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Booking has been cancelled'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}