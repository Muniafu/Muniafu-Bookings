import 'package:cloud_firestore/cloud_firestore.dart';

class Onboarding {
  final String title;
  final String description;
  final String imagePath; // More generic name that works for both assets and URLs
  final String? ctaText; // New optional call-to-action text
  final int? durationSeconds; // New optional auto-advance duration
  final bool? showSkipButton; // New optional UI control

  Onboarding({
    required this.title,
    required this.description,
    required this.imagePath,
    this.ctaText,
    this.durationSeconds,
    this.showSkipButton = true, // Default value
  });

  // Factory constructor for JSON parsing (API/local JSON)
  factory Onboarding.fromJson(Map<String, dynamic> json) {
    return Onboarding(
      title: json['title'] ?? '', // Null safety from Onboarding
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? json['imageAsset'] ?? json['imageUrl'] ?? '',
      ctaText: json['ctaText'],
      durationSeconds: json['durationSeconds']?.toInt(),
      showSkipButton: json['showSkipButton'] ?? true,
    );
  }

  // Factory constructor for Firestore
  factory Onboarding.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Onboarding.fromJson(data);
  }

  // Convert to JSON (for API/local storage)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      if (ctaText != null) 'ctaText': ctaText,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (showSkipButton != false) 'showSkipButton': showSkipButton,
    };
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      if (ctaText != null) 'ctaText': ctaText,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'showSkipButton': showSkipButton,
    };
  }

  // Copy with method for immutable updates
  Onboarding copyWith({
    String? title,
    String? description,
    String? imagePath,
    String? ctaText,
    int? durationSeconds,
    bool? showSkipButton,
  }) {
    return Onboarding(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      ctaText: ctaText ?? this.ctaText,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      showSkipButton: showSkipButton ?? this.showSkipButton,
    );
  }
}