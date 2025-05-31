import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  
  const DateSelector({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                  : 'Select date',
              style: TextStyle(
                color: selectedDate != null
                    ? Colors.black
                    : Theme.of(context).hintColor,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}