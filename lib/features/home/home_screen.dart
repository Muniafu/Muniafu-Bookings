import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'hotel_rooms_screen.dart';
import 'profile_screen.dart';
import 'booking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotelEase'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Text(
              'Welcome to HotelEase',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Image Carousel Section
          CarouselSlider(
            items: [
              _imageCard(context, './assets/images/onboarding.png', 'Sunset Paradise Resort'),
              _imageCard(context, './assets/images/onboarding2.png', 'Mountain View Lodge'),
              _imageCard(context, './assets/images/onboarding3.png', 'Urban Luxury Suites'),
            ],
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              aspectRatio: 16/9,
              initialPage: 0,
            ),
          ),
          const SizedBox(height: 30),

          // Featured Hotels Section
          const Text(
            "Featured Hotels", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 10),
          
          Card(
            elevation: 5,
            child: ListTile(
              leading: _blurredImage('./assets/images/onboarding2.png'),
              title: const Text(
                "Sunset Paradise Resort",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Beachfront • 5 Stars"),
              trailing: ElevatedButton(
                child: const Text("View Rooms"),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const HotelRoomsScreen())
                  );
                },
              ),
            ),
          ),
          const Divider(),

          // Special Deals Section
          const Text(
            "Special Offers", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 10),
          
          Card(
            elevation: 5,
            child: ListTile(
              leading: _blurredImage('./assets/images/onboarding.png'),
              title: const Text(
                "Weekend Getaway Package",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("30% off for 2-night stays"),
              trailing: ElevatedButton(
                child: const Text("Book Now"),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const BookingScreen())
                  );
                },
              ),
            ),
          ),
          const Divider(),

          // Profile Section
          ListTile(
            leading: const Icon(Icons.person, size: 30),
            title: const Text(
              "My Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const ProfileScreen())
              );
            },
          ),
        ],
      ),
    );
  }

  // Image Card for Carousel
  Widget _imageCard(BuildContext context, String imagePath, String title) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('./assets/images/onboarding.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Blurred Image Widget
  Widget _blurredImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        './assets/images/onboarding.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        color: Colors.black.withOpacity(0.3),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }
}