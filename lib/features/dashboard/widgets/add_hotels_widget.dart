import 'package:flutter/material.dart';

class AddHotelsWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddHotel;
  final String? headerText;

  const AddHotelsWidget({
    super.key,
    required this.onAddHotel,
    this.headerText = 'Add Hotel to Wishlist',
  });

  @override
  State<AddHotelsWidget> createState() => _AddHotelsWidgetState();
}

class _AddHotelsWidgetState extends State<AddHotelsWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _clearForm() {
    _nameController.clear();
    _locationController.clear();
    _priceController.clear();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onAddHotel({
        'name': _nameController.text,
        'location': _locationController.text,
        'price': double.parse(_priceController.text),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel added successfully!')),
      );
      
      _clearForm();
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.headerText!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildHotelNameField(),
            const SizedBox(height: 15),
            _buildLocationField(),
            const SizedBox(height: 15),
            _buildPriceField(),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.add_home_work),
              label: const Text('Add Hotel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Hotel Name',
        prefixIcon: Icon(Icons.hotel),
      ),
      validator: (value) => value?.isEmpty ?? true 
          ? 'Please enter the hotel name' 
          : null,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Location',
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) => value?.isEmpty ?? true 
          ? 'Please enter the hotel location' 
          : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Price Per Night',
        prefixIcon: Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter the price';
        if (double.tryParse(value!) == null) return 'Invalid number format';
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}