import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/hotel_provider.dart';
import '../../models/hotel_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _prefetchTimer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HotelProvider>(context, listen: false);
    if (provider.hotels.isEmpty) provider.fetchHotels(refresh: true);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<HotelProvider>(context, listen: false);

    if (_scrollController.position.pixels >
        (_scrollController.position.maxScrollExtent - 300)) {
      provider.loadMore();
    }

    // predictive prefetch for item a little ahead
    _prefetchTimer?.cancel();
    _prefetchTimer = Timer(const Duration(milliseconds: 200), () {
      final approxIndex =
          (_scrollController.position.pixels / 220).floor() + 5; // heuristic
      if (approxIndex >= 0 && approxIndex < provider.hotels.length) {
        final id = provider.hotels[approxIndex].id;
        provider.prefetchHotelDetails(id);
      }
    });
  }

  @override
  void dispose() {
    _prefetchTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => Provider.of<HotelProvider>(context, listen: false).fetchHotels(refresh: true);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Colors.indigo, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search hotels, city or landmark',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.searchHotels('');
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) => provider.searchHotels(value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.notifications, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Offers carousel: placeholder
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: PageView(controller: PageController(viewportFraction: 0.92), children: [
                      _offerCard("https://via.placeholder.com/800x400.png?text=Offer+1", "Special Offer 1"),
                      _offerCard("https://via.placeholder.com/800x400.png?text=Offer+2", "Weekend Sale"),
                      _offerCard("https://via.placeholder.com/800x400.png?text=Offer+3", "Member Discount"),
                    ]),
                  ),
                ),

                // Quick actions row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickAction(Icons.favorite, "Wishlist", () => Navigator.pushNamed(context, '/wishlist')),
                        _quickAction(Icons.calendar_today, "Bookings", () => Navigator.pushNamed(context, '/my-bookings')),
                        _quickAction(Icons.person, "Profile", () => Navigator.pushNamed(context, '/profile')),
                      ],
                    ),
                  ),
                ),

                // Hotel list
                provider.isLoading && provider.hotels.isEmpty
                    ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                    : provider.hotels.isEmpty
                        ? const SliverFillRemaining(child: Center(child: Text("No hotels found")))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // If provider.hasMore we may show a loading tile at end
                                if (index >= provider.hotels.length) return const SizedBox.shrink();
                                final hotel = provider.hotels[index];
                                return _hotelCard(hotel);
                              },
                              childCount: provider.hotels.length,
                            ),
                          ),

                if (provider.hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: provider.isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: () => provider.loadMore(), child: const Text("Load more")),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _offerCard(String imageUrl, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (c, u) => Container(color: Colors.grey[300]),
            errorWidget: (c, u, e) => Container(color: Colors.grey[300], child: const Icon(Icons.error)),
          ),
          Positioned(left: 16, bottom: 16, child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(icon, color: Colors.indigo),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _hotelCard(HotelModel hotel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/hotel-detail', arguments: hotel);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'hotel-image-${hotel.id}',
                child: CachedNetworkImage(
                  imageUrl: hotel.images.isNotEmpty ? hotel.images.first : '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: Colors.grey[300]),
                  errorWidget: (c, u, e) => Container(height: 180, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(hotel.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    if (hotel.tags.isNotEmpty)
                      Wrap(spacing: 6, children: hotel.tags.map((t) => Chip(label: Text(t), backgroundColor: Colors.orange.shade100)).toList()),
                  ]),
                  const SizedBox(height: 6),
                  Text(hotel.address),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                    const SizedBox(width: 4),
                    Text(hotel.rating.toStringAsFixed(1)),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text("\$${hotel.basePrice.toStringAsFixed(0)}/night", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                      // availability badge
                      if (hotel.availableRooms > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: hotel.availableRooms <= 2 ? Colors.red.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Text(hotel.availableRooms <= 2 ? 'Last ${hotel.availableRooms} rooms!' : '${hotel.availableRooms} rooms', style: TextStyle(color: hotel.availableRooms <= 2 ? Colors.red.shade800 : Colors.green.shade800)),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Sold out', style: TextStyle(color: Colors.grey)),
                        )
                    ])
                  ])
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}