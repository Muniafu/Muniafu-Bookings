import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/hotel_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payment_provider.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final RoomModel room;
  final HotelModel hotel;
  
  const BookingScreen({super.key, required this.room, required this.hotel});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  int _guests = 1;
  String? _bookingId;

  @override
  void initState() {
    super.initState();
    _checkIn = DateTime.now();
    _checkOut = _checkIn.add(const Duration(days: 1));
    _bookingId = 'BOOK_${DateTime.now().millisecondsSinceEpoch}';
  }

  int get selectedNights => _checkOut.difference(_checkIn).inDays;

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (!_checkOut.isAfter(_checkIn)) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Booking details
            Text('Room: ${widget.room.name}', style: Theme.of(context).textTheme.titleLarge),
            Text('Price: KES ${widget.room.pricePerNight.toStringAsFixed(2)}/night'),
            
            // Date selection
            ListTile(
              title: const Text('Check-in'),
              trailing: Text(DateFormat('MMM d, y').format(_checkIn)),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: const Text('Check-out'),
              trailing: Text(DateFormat('MMM d, y').format(_checkOut)),
              onTap: () => _selectDate(context, false),
            ),
            Text('Nights: $selectedNights'),
            
            // Guest selection
            ListTile(
              title: const Text('Guests'),
              trailing: DropdownButton<int>(
                value: _guests,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _guests = value);
                  }
                },
                items: List.generate(6, (i) => i + 1)
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
              ),
            ),
            
            const Spacer(),
            
            // Total and payment button
            Text(
              'Total: KES ${(widget.room.pricePerNight * selectedNights).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            
            paymentProvider.isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      // Create booking first
                      final booking = BookingModel(
                        id: _bookingId!,
                        userId: authProvider.user!.uid,
                        roomId: widget.room.id,
                        checkIn: _checkIn,
                        checkOut: _checkOut,
                        guests: _guests,
                        totalPrice: widget.room.pricePerNight * selectedNights,
                        status: 'pending',
                        paymentId: '',
                      );
                      
                      await bookingProvider.createBooking(booking);

                      // Then process payment
                      await paymentProvider.initializePayment(
                        context: context,
                        userId: authProvider.user!.uid,
                        bookingId: _bookingId!,
                        amount: widget.room.pricePerNight * selectedNights,
                        email: authProvider.user!.email,
                        phone: authProvider.user!.phone,
                      );

                      if (paymentProvider.currentPayment?.status == 'successful') {
                        // Update booking status if payment succeeds
                        await bookingProvider.updateBooking(
                          booking,
                          {'status': 'confirmed', 'paymentId': paymentProvider.currentPayment!.id},
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfirmationScreen(
                              bookingId: _bookingId!,
                              paymentId: paymentProvider.currentPayment!.id,
                            ),
                          ),
                        );
                      } else if (paymentProvider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(paymentProvider.error!)),
                        );
                      }
                    },
                    child: const Text('Proceed to Payment'),
                  ),
          ],
        ),
      ),
    );
  }
}