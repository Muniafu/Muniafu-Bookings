class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime tiestamp;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tiestamp,
    this.read = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      title: data['title'],
      body: data['body'],
      tiestamp: (data['timestamp']).toDate(),
      read: data['read'] ?? false,
    );
  }
}