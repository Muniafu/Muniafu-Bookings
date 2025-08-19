import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final hotels = Provider.of<HotelProvider>(context).hotels;

    
    // Get favorite hotel IDs from user preferences
    final favoriteHotelIds = (user.preferences['favoriteHotels'] as List<dynamic>?)?.cast<String>() ?? [];
     
    // Filter hotels to only include favorites
    final favoriteHotels = hotels.where((h) => favoriteHotelIds.contains(h.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: favoriteHotels.isEmpty
          ? const Center(child: Text("No favorites yet."))
          : ListView.builder(
              itemCount: favoriteHotels.length,
              itemBuilder: (context, index) {
                final HotelModel hotel = favoriteHotels[index];
                return ListTile(
                  title: Text(hotel.name),
                  subtitle: Text(hotel.address),
                  onTap: () => Navigator.pushNamed(context, '/hotel-detail', arguments: hotel),
                );
              },
            ),
    );
  }
}