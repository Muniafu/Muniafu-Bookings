import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  
  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, size: size, color: color),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}