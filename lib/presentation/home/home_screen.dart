import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:muniafu/presentation/home/booking_screen.dart';
import 'package:muniafu/presentation/home/hotel_rooms_screen.dart';
import 'package:muniafu/presentation/home/widgets/text_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: TextWidget(
              text: 'Welcome to Booking App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // 3D Image Slider Section
          CarouselSlider(
            items: [
              _imageCard(context, './assets/images/onboarding.png', 'Luxury Hotel 1'),
              _imageCard(context, './assets/images/onboarding2.png', 'Luxury Hotel 2'),
              _imageCard(context, './assets/images/onboarding3.png', 'Luxury Hotel 3'),
            ],
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              aspectRatio: 16 / 9,
              initialPage: 0,
            ),
          ),
          const SizedBox(height: 20),

          // Featured Hotel Section
          Card(
            elevation: 5,
            child: ListTile(
              leading: _blurredImage('./assets/images/onboarding2.png'),
              title: const TextWidget(
                text: 'Featured Hotel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const TextWidget(
                text: 'Explore our top-rated hotels for your stay',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HotelRoomsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Special Deals Section
          Card(
            elevation: 5,
            child: ListTile(
              leading: _blurredImage('./assets/images/onboarding.png'),
              title: const TextWidget(
                text: 'Special Deals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const TextWidget(
                text: 'Check out our exclusive offers and discounts.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3D Slider Card Widget
  Widget _imageCard(BuildContext context, String imagePath, String title) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(imagePath),
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

  // Blurred Image Widget for Hover Effect
  Widget _blurredImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
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