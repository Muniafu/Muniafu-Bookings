class Onboarding {
  String title;
  String description;
  String imageUrl;

  Onboarding({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Onboarding.fromMap(Map<String, dynamic> data) {
    return Onboarding(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}