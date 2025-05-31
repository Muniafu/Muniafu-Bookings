import 'package:cloud_firestore/cloud_firestore.dart';

class Onboarding {
  final String title;
  final String description;
  final String imagePath;
  final String? ctaText;
  final int? durationSeconds;
  final bool showSkipButton;
  final int orderIndex; // New field for ordering
  final String? routeName; // New field for custom navigation

  Onboarding({
    required this.title,
    required this.description,
    required this.imagePath,
    this.ctaText,
    this.durationSeconds,
    this.showSkipButton = true,
    this.orderIndex = 0,
    this.routeName,
  });

  // Factory constructor for JSON parsing (API/local JSON)
  factory Onboarding.fromJson(Map<String, dynamic> json) {
    return Onboarding(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? 
                json['image'] as String? ?? 
                json['imageAsset'] as String? ?? 
                json['imageUrl'] as String? ?? '',
      ctaText: json['ctaText'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      showSkipButton: json['showSkipButton'] as bool? ?? true,
      orderIndex: json['orderIndex'] as int? ?? 0,
      routeName: json['routeName'] as String?,
    );
  }

  // Factory constructor for Firestore
  factory Onboarding.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Onboarding.fromJson(data);
  }

  // Factory constructor for Firestore QueryDocumentSnapshot
  factory Onboarding.fromQueryDocument(QueryDocumentSnapshot doc) {
    return Onboarding.fromFirestore(doc);
  }

  // Convert to JSON (for API/local storage)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      if (ctaText != null) 'ctaText': ctaText,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'showSkipButton': showSkipButton,
      'orderIndex': orderIndex,
      if (routeName != null) 'routeName': routeName,
    };
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Copy with method for immutable updates
  Onboarding copyWith({
    String? title,
    String? description,
    String? imagePath,
    String? ctaText,
    int? durationSeconds,
    bool? showSkipButton,
    int? orderIndex,
    String? routeName,
  }) {
    return Onboarding(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      ctaText: ctaText ?? this.ctaText,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      showSkipButton: showSkipButton ?? this.showSkipButton,
      orderIndex: orderIndex ?? this.orderIndex,
      routeName: routeName ?? this.routeName,
    );
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Onboarding &&
        other.title == title &&
        other.description == description &&
        other.imagePath == imagePath &&
        other.ctaText == ctaText &&
        other.durationSeconds == durationSeconds &&
        other.showSkipButton == showSkipButton &&
        other.orderIndex == orderIndex &&
        other.routeName == routeName;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        imagePath.hashCode ^
        ctaText.hashCode ^
        durationSeconds.hashCode ^
        showSkipButton.hashCode ^
        orderIndex.hashCode ^
        routeName.hashCode;
  }

  @override
  String toString() {
    return 'Onboarding(title: $title, description: $description, imagePath: $imagePath, '
           'ctaText: $ctaText, durationSeconds: $durationSeconds, '
           'showSkipButton: $showSkipButton, orderIndex: $orderIndex, '
           'routeName: $routeName)';
  }
}