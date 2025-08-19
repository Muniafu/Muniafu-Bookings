import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logHotelView(String hotelId) async {
    await _analytics.logEvent(name: 'view_hotel', parameters: {'hotel_id': hotelId});
  }

  Future<void> logBooking(String bookingId, double amount) async {
    await _analytics.logEvent(name: 'booking', parameters: {
      'booking_id': bookingId,
      'amount': amount,
    });
  }
}