import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/receipt_pdf_generator.dart';

class MyReceiptsScreen extends StatelessWidget {
  const MyReceiptsScreen({super.key});

  Stream<QuerySnapshot> _userBookings() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
      .collection('bookings')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Receipts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No receipts available.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Room: ${data['roomId']}"),
                subtitle: Text("Status: ${data['status']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    await ReceiptPdfGenerator.generateReceipt(
                      bookingId: docs[i].id,
                      userId: data['userId'],
                      roomId: data['roomId'],
                      status: data['status'],
                      createdAt: (data['createdAt'] as Timestamp).toDate(),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}