import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/screens/welcome_screen.dart';
import 'package:muniafu/presentation/home/payment_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture and username section
            const Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('/assets/images/bg.jpg'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Personal info section
            const InfoRow(title: 'Date of Birth', content: 'January 16, 2000'),
            const InfoRow(title: 'Location', content: 'Nairobi, Kenya'),
            const InfoRow(title: 'Bio', content: 'A mobile developer'),

            const Divider(),

            // Social Links Section
            const SocialLinks(),

            const Divider(),

            // Activity feed or recent activity section
            const RecentActivity(),

            const Divider(),

            // Payment Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to payment screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Payment'),
              ),
            ),
            
            // Logout button
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}

// Helper widget for displaying info rows (Date of Birth, Bio)
class InfoRow extends StatelessWidget {
  final String title;
  final String content;

  const InfoRow({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Social links section with clickable icons
class SocialLinks extends StatelessWidget {
  const SocialLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook, color: Colors.blue),
          onPressed: () {},
        ),
      ],
    );
  }
}

// Recent activity section with sample activity feed
class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text('- Liked a post...'),
        Text('- Commented on a post'),
        Text('- Followed a hotel page'),
      ],
    );
  }
}