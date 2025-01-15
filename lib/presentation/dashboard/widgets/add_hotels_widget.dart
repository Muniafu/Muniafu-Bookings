import 'package:flutter/material.dart';

class AddHotelsWidget extends StatefulWidget{
  final Function(Map<String, dynamic>) onAddHotel;

  const AddHotelsWidget({super.key, required this.onAddHotel});

  @override
  _AddHotelsWidgetState createState() => _AddHotelsWidgetState();
}

class _AddHotelsWidgetState extends State<AddHotelsWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =TextEditingController();
  final TextEditingController _locationController =TextEditingController();
  final TextEditingController _priceController =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Hotel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hotel Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the hotel name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the hotel location';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price Per Night'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onAddHotel({
                    'name': _nameController.text,
                    'location': _locationController.text,
                    'price': double.parse(_priceController.text),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hotel added successfully!')),
                  );
                }
              },
              child: const Text('Add Hotel'),
            )
          ],
        ),
      ),
    );
  }
}