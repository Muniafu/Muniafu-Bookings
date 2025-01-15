import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muniafu/firebase_options.dart';
import 'package:provider/provider.dart';

// Import Providers
import 'package:muniafu/providers/admin_provider.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:muniafu/providers/booking_provider.dart';
import 'package:muniafu/providers/hotel_provider.dart';
import 'package:muniafu/providers/navigation_provider.dart';

// Import screens
import 'package:muniafu/presentation/authentication/screens/login_screen.dart';
import 'package:muniafu/presentation/authentication/screens/signup_screen.dart';
import 'package:muniafu/presentation/authentication/screens/welcome_screen.dart';
import 'package:muniafu/presentation/home/booking_screen.dart';
import 'package:muniafu/presentation/home/home_screen.dart';
import 'package:muniafu/presentation/onboarding/onboarding_screen.dart';
import 'package:muniafu/presentation/search/search_screen.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookings App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        /*'/': (context) =>  const OnboardingScreen()*/
        '/': (context) =>  const WelcomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        '/search': (context) => const SearchScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}