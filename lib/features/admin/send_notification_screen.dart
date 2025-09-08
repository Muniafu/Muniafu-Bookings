import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userIdController = TextEditingController(); // Optional

  bool _sending = false;

  Future<void> _sendNotification() async {
    setState(() => _sending = true);
    try {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();
      final userId = _userIdController.text.trim().isEmpty
          ? '*'
          : _userIdController.text.trim();
      
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'body': body,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );

      _titleController.clear();
      _bodyController.clear();
      _userIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error $e')),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID (leave blank to send to all)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _sendNotification,
              child: _sending ? const CircularProgressIndicator() : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}