import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import './providers/auth_provider.dart' as app;
import './providers/hotel_provider.dart';
import './providers/booking_provider.dart';
import './providers/payment_provider.dart';

import 'models/room_model.dart';
import '/models/hotel_model.dart';

import 'services/payment_service.dart';

//import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/booking/confirmation_screen.dart';
import 'features/home/home_screen.dart';
import 'features/hotel_detail/hotel_detail_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/manage_bookings_screen.dart';
import 'features/admin/manage_properties_screen.dart';
import 'features/profile/my_bookings_screen.dart';
import 'features/profile/wishlist_screen.dart';
import 'features/admin/add_edit_property_screen.dart';
import 'features/admin/analytics_dashboard_screen.dart';
import 'features/review/submit_review_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final paymentService = PaymentService(
    paystackPublicKeyTest: 'pk_test_94b67a918deefd624913bd5a2a378a5131a4e5c4',
    isSandbox: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider(paymentService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app.AuthProvider>(context);
    if (auth.isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Hotel Booking App',
      debugShowCheckedModeBanner: false,
      home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      routes: {
        //'/splash': (context) => SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/properties': (context) => const ManagePropertiesScreen(),
        '/admin/bookings': (context) => const ManageBookingsScreen(),
        '/admin/add-property': (context) => const AddEditPropertyScreen(),
        '/admin/analytics': (context) => const AnalyticsDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with parameters
        switch (settings.name) {
          case '/hotel-detail':
            final hotel = settings.arguments as HotelModel;
            return MaterialPageRoute(
              builder: (context) => HotelDetailScreen(hotel: hotel, hotelId: '',),
            );
          case '/booking':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => BookingScreen(
                room: args['room'] as RoomModel,
                hotel: args['hotel'] as HotelModel,
              ),
            );
          case '/confirmation':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                bookingId: args['bookingId'],
                paymentId: args['paymentId'],
              ),
            );
          case '/review':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SubmitReviewScreen(
                bookingId: args['bookingId'],
                hotelId: args['hotelId'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}