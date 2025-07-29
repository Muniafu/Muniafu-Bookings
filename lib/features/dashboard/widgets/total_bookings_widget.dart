import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalBookingsWidget extends StatelessWidget {
  const TotalBookingsWidget({super.key});

  Future<int> _fetchTotalBookings() async {
    final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchTotalBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        } else if (snapshot.hasError) {
          return const _ErrorCard();
        } else {
          return _InfoCard(total: snapshot.data ?? 0);
        }
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final int total;
  const _InfoCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Bookings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(total.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Error loading total bookings')),
      ),
    );
  }
}
