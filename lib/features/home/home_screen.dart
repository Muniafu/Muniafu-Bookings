import 'dart:async';
import 'package:flutter/material.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/hotel_provider.dart';
import '../../data/models/hotel.dart';
import 'hotel_rooms_screen.dart';
import 'booking_screen.dart';
import 'profile_screen.dart';
import '../../app/core/widgets/rating_widget.dart';
import '../../app/core/widgets/button_widget.dart';
import '../../data/models/room.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load hotels on initial screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelProvider>().loadHotels();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelRoomsScreen(searchQuery: query),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<HotelProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: provider.loadHotels,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // AppBar with search
            SliverAppBar(
              expandedHeight: 116.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('StayEase'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer, // Use primaryContainer instead of withOpacity
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: InputDecoration(
                        hintText: 'Search destinations, hotels...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                )
              ),
            ),
            
            // Main content
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                
                // Welcome section
                _buildWelcomeSection(theme),
                const SizedBox(height: 20),
                
                // Featured destinations carousel
                _buildDestinationsCarousel(context),
                const SizedBox(height: 30),
                
                // Quick actions
                _buildQuickActions(context),
                const SizedBox(height: 30),
                
                // Featured hotels section
                _buildFeaturedHotels(context, provider),
                const SizedBox(height: 30),
                
                // Special offers section
                _buildSpecialOffers(context),
                const SizedBox(height: 30),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    final user = context.watch<AuthProvider>().currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user != null ? 'Welcome, ${user.name}' : 'Find Your Perfect Stay',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover amazing hotels at the best prices',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Popular Destinations",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          items: [
            _buildDestinationCard(
              context,
              'Bali, Indonesia',
              'https://picsum.photos/600/400?destination=1',
              '72 Hotels',
            ),
            _buildDestinationCard(
              context,
              'Paris, France',
              'https://picsum.photos/600/400?destination=2',
              '58 Hotels',
            ),
            _buildDestinationCard(
              context,
              'Tokyo, Japan',
              'https://picsum.photos/600/400?destination=3',
              '64 Hotels',
            ),
          ],
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            aspectRatio: 16/9,
            autoPlayInterval: const Duration(seconds: 5),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(
    BuildContext context, 
    String title, 
    String imageUrl, 
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelRoomsScreen(destination: title),
        ),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(color: Colors.grey[200]),
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                Icons.hotel,
                "Hotels",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelRoomsScreen()),
                ),
              ),
              _buildActionButton(
                context,
                Icons.flight,
                "Flights",
                () {},
              ),
              _buildActionButton(
                context,
                Icons.local_offer,
                "Deals",
                () {},
              ),
              _buildActionButton(
                context,
                Icons.map,
                "Explore",
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    IconData icon, 
    String label, 
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeaturedHotels(BuildContext context, HotelProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Featured Hotels",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelRoomsScreen()),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator()),
          
          if (provider.error != null)
            Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          
          if (!provider.isLoading && provider.hotels.isNotEmpty)
            ...provider.hotels.take(3).map((hotel) => _buildHotelCard(context, hotel)),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelRoomsScreen(hotel: hotel),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hotel.images.isNotEmpty
                    ? Image.network(
                        hotel.images.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.hotel, size: 40),
                          ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.hotel, size: 40),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Hotel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel.location,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingWidget(rating: hotel.rating),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${(hotel.pricePerNight).toStringAsFixed(0)}/night',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        ButtonWidget.filled(
                          text: "View",
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelRoomsScreen(hotel: hotel),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialOffers(BuildContext context) {
    // Create a dummy room for the special offer booking
    final specialOfferRoom = Room(
      id: 'special-offer',
      hotelId: 'special-hotel',
      type: 'Weekend Getaway Package',
      name: 'Weekend Getaway Package',
      pricePerNight: 199.00,
      capacity: 2,
      images: [],
      amenities: ['Breakfast', 'Ocean View', 'Free WiFi'],
      isAvailable: true,
      discount: 0.3,
      description: 'Enjoy 30% off for 2-night stays at participating resorts',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Special Offers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekend Getaway Package",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enjoy 30% off for 2-night stays at participating resorts",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: const Text("30% OFF"),
                        backgroundColor: Colors.orange[100],
                        labelStyle: const TextStyle(color: Colors.orange),
                      ),
                      const Spacer(),
                      ButtonWidget.filled(
                        text: "Book Now",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              room: specialOfferRoom,
                              checkIn: DateTime.now().add(const Duration(days: 3)),
                              checkOut: DateTime.now().add(const Duration(days: 5)),
                              guests: 2,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text(
              "My Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {              
              // Navigate to ProfileScreen with provider
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}