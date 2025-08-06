import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:muniafu/features/home/widgets/payment_form.dart';

import '../../data/models/room.dart';
import '../../data/models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../data/services/booking_service.dart';
import 'payment_success_screen.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_details_bottom_sheet.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final bool isDirectBooking;

  const BookingScreen({
    Key? key,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.isDirectBooking = true,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _requestsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.isDirectBooking ? 2 : 1,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      final isAdmin = authProvider.isAdmin;

      if (!widget.isDirectBooking && user != null) {
        if (isAdmin) {
          bookingProvider.listenToAllBookings();
        } else {
          bookingProvider.listenToUserBookings(user.uid);
        }
      }

      _prefillUserData();
    });
  }

  void _prefillUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
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

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
      final nights = widget.checkOut.difference(widget.checkIn).inDays;
      final total = widget.room.pricePerNight * nights;

      await BookingService().createBooking(
        userId: user.uid,
        room: widget.room,
        checkInDate: widget.checkIn,
        checkOutDate: widget.checkOut,
        numberOfGuests: widget.guests,
        totalAmount: total,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentSuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    final total = widget.room.pricePerNight * nights;

    if (!widget.isDirectBooking) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isAdmin ? 'All Bookings' : 'My Bookings'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Past"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(bookingProvider.activeBookings),
            _buildBookingList(bookingProvider.pastBookings),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: "New Booking"),
            Tab(icon: Icon(Icons.list), text: "My Bookings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingConfirmation(total, nights),
          _buildBookingList(bookingProvider.bookings),
        ],
      ),
    );
  }

  Widget _buildBookingConfirmation(double total, int nights) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hotel Room: ${widget.room.type}', 
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // Booking Details Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guest Details', style: theme.textTheme.titleMedium),
                        const Divider(),
                        Text('Name: ${user.fullName ?? user.email}'),
                        Text('Email: ${user.email}'),
                        if (user.phone != null) Text('Phone: ${user.phone}'),
                        const SizedBox(height: 16),
                        
                        Text('Booking Details', style: theme.textTheme.titleMedium),
                        const Divider(),
                        Text('Check-in: ${DateFormat.yMMMd().format(widget.checkIn)}'),
                        Text('Check-out: ${DateFormat.yMMMd().format(widget.checkOut)}'),
                        Text('Nights: $nights'),
                        Text('Guests: ${widget.guests}'),
                        const SizedBox(height: 16),
                        
                        Text('Payment Summary', style: theme.textTheme.titleMedium),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Room Rate (${widget.room.type})'),
                            Text('\$${widget.room.pricePerNight.toStringAsFixed(2)} x $nights nights'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: theme.textTheme.titleMedium),
                            Text('\$${total.toStringAsFixed(2)}', 
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Payment Form
                PaymentFormWidget(
                  roomId: widget.room.id,
                  amount: (total * 100).toInt(),
                  onPaymentSuccess: _confirmBooking,
                ),
                
                // Special Requests
                TextFormField(
                  controller: _requestsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Requests',
                    hintText: 'Any special requests for your stay?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (_, i) => BookingCard(
        booking: bookings[i].toJson(),
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