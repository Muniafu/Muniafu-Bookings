import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String bookingId;
  final String hotelId;

  const SubmitReviewScreen({super.key, required this.bookingId, required this.hotelId});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  int rating = 0;
  final commentController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitReview() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    setState(() => isSubmitting = true);

    final review = {
      'id': const Uuid().v4(),
      'bookingId': widget.bookingId,
      'hotelId': widget.hotelId,
      'rating': rating,
      'comment': commentController.text.trim(),
      'date': DateTime.now().toIso8601String(),
      'userId': user.uid,
    };

    await FirebaseFirestore.instance.collection('reviews').add(review);

    setState(() => isSubmitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Review")),
      body: isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Rate your stay", style: TextStyle(fontSize: 18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(i < rating ? Icons.star : Icons.star_border),
                        color: Colors.amber,
                        onPressed: () => setState(() => rating = i + 1),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: "Leave a comment"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: submitReview, child: const Text("Submit Review")),
                ],
              ),
            ),
    );
  }
}