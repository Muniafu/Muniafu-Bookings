import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muniafu/data/services/admin_service.dart';
import 'package:muniafu/data/services/auth_service.dart';
import 'package:muniafu/data/services/booking_service.dart';
import 'package:muniafu/data/services/hotel_service.dart';
import 'package:muniafu/data/services/user_service.dart';
import 'package:muniafu/features/home/hotel_rooms_screen.dart';
import 'package:muniafu/features/home/profile_screen.dart';
import 'package:muniafu/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import App Theme
//import 'package:muniafu/app/config/app_theme.dart';

//import 'package:muniafu/app/core/widgets/background_widget.dart';
//import 'package:muniafu/app/core/widgets/bottom_nav_bar.dart';
//import 'package:muniafu/app/core/widgets/button_widget.dart';
//import 'package:muniafu/app/core/widgets/text_widget.dart';
//import 'package:muniafu/app/core/widgets/logo_widget.dart';

// Import Providers
import 'package:muniafu/providers/admin_provider.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:muniafu/providers/booking_provider.dart';
import 'package:muniafu/providers/hotel_provider.dart';
import 'package:muniafu/providers/navigation_provider.dart';
import 'package:muniafu/providers/user_provider.dart';

// Import screens
import 'package:muniafu/features/authentication/screens/login_screen.dart';
import 'package:muniafu/features/authentication/screens/signup_screen.dart';
import 'package:muniafu/features/authentication/screens/welcome_screen.dart';
//import 'package:muniafu/features/home/booking_screen.dart';
import 'package:muniafu/features/dashboard/dashboard_screen.dart';
import 'package:muniafu/features/home/home_screen.dart';
import 'package:muniafu/features/onboarding/onboarding_screen.dart';
import 'package:muniafu/features/search/search_screen.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final firestore = FirebaseFirestore.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider(AdminService())),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService(
          firebaseAuth: firebase_auth.FirebaseAuth.instance,
          firestore: firestore,
          prefs: prefs,
        ))),
        ChangeNotifierProvider(create: (_) => BookingProvider(BookingService.firestore())),
        ChangeNotifierProvider(create: (_) => HotelProvider(HotelService.firestore())),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider(UserService.firestore())),
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
      //theme: AppTheme.lightTheme,
      //darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (context) =>  const OnboardingScreen(),
        '/welcome': (context) =>  const WelcomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/hotel-rooms': (context) => const HotelRoomsScreen(),
        '/bookings': (context) => const BookingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}