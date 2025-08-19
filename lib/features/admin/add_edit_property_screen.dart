import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

import '../../providers/hotel_provider.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final HotelModel? hotel;

  const AddEditPropertyScreen({super.key, this.hotel});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descController = TextEditingController();
  final ratingController = TextEditingController();
  final amenitiesController = TextEditingController();
  final seoTagsController = TextEditingController();
  final basePriceController = TextEditingController();
  final taxRateController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  int _currentStep = 0;
  final picker = ImagePicker();
  final List<File> _images = [];
  final List<Uint8List> _webImages = [];
  String? _coverImageUrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      nameController.text = widget.hotel!.name;
      addressController.text = widget.hotel!.address;
      descController.text = widget.hotel!.description;
      ratingController.text = widget.hotel!.rating.toString();
      amenitiesController.text = widget.hotel!.amenities.join(', ');
      latController.text = (widget.hotel!.coordinates['lat'] ?? 0).toString();
      lngController.text = (widget.hotel!.coordinates['lng'] ?? 0).toString();
    }
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      if (kIsWeb) {
        _webImages.clear();
        for (var file in picked) {
          final bytes = await file.readAsBytes();
          _webImages.add(bytes);
        }
      } else {
        _images.clear();
        _images.addAll(picked.map((e) => File(e.path)));
      }
      setState(() {});
    }
  }

    double getCalculatedPrice() {
      final base = double.tryParse(basePriceController.text) ?? 0;
      final tax = double.tryParse(taxRateController.text) ?? 0;
      return base + (base * (tax / 100));
    }

    Future<void> saveHotel() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() => isLoading = true);

      final id = widget.hotel?.id ?? const Uuid().v4();
      final List<String> uploadedUrls = [];
      String? coverImageFinalUrl;

      // Upload mobile images
      for (var i = 0; i < _images.length; i++) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('hotel_images')
            .child('${DateTime.now().millisecondsSinceEpoch}_mobile_$i.jpg');

        await ref.putFile(_images[i]);
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);

        if (_coverImageUrl == 'mobile_$i') {
          coverImageFinalUrl = url;
        }
      }

      // Upload web images (if any)
      for (var i = 0; i < _webImages.length; i++) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('hotel_images')
            .child('${DateTime.now().millisecondsSinceEpoch}_web_$i.jpg');

        await ref.putData(
          _webImages[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);

        if (_coverImageUrl == 'web_$i') {
          coverImageFinalUrl = url;
        }
      }

      // If no explicit cover image selected, pick first uploaded
      coverImageFinalUrl ??= uploadedUrls.isNotEmpty ? uploadedUrls.first : null;

      final hotel = HotelModel(
        id: id,
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        coordinates: {
          'lat': double.tryParse(latController.text) ?? 0,
          'lng': double.tryParse(lngController.text) ?? 0
        },
        description: descController.text.trim(),
        amenities:
            amenitiesController.text.split(',').map((e) => e.trim()).toList(),
        images: uploadedUrls,
        coverImage: coverImageFinalUrl, // <— cover image stored here
        rating: double.tryParse(ratingController.text.trim()) ?? 0.0,
        seoTags: seoTagsController.text.split(',').map((e) => e.trim()).toList(),
        basePrice: double.tryParse(basePriceController.text) ?? 0.0,
        taxRate: double.tryParse(taxRateController.text) ?? 0.0,
      );

      final service = HotelService();
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

      if (widget.hotel == null) {
        await service.addHotel(hotel);
        await hotelProvider.fetchHotels();
      } else {
        await service.updateHotel(hotel);
      }

      setState(() => isLoading = false);
      Navigator.pop(context);
    }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hotel != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Hotel" : "Add Hotel")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  saveHotel();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                    title: const Text("Images"),
                    content: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImages,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Pick Images"),
                        ),
                        const SizedBox(height: 8),

                        ReorderableGridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          children: [
                            if (kIsWeb)
                              ..._webImages.map((bytes) => GestureDetector(
                                onTap: () => setState(() => _coverImageUrl = bytes.hashCode.toString()),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(bytes, fit: BoxFit.cover),
                                    if (_coverImageUrl == bytes.hashCode.toString())
                                      Container(
                                        color: Colors.black45,
                                        child: const Center(
                                          child: Icon(Icons.star, color: Colors.yellow),
                                        ),
                                      )
                                  ],
                                ),
                              )),
                            if (!kIsWeb)
                              ..._images.map((f) => GestureDetector(
                                onTap: () => setState(() => _coverImageUrl = f.path),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(f, fit: BoxFit.cover),
                                    if (_coverImageUrl == f.path)
                                      Container(
                                        color: Colors.black45,
                                        child: const Center(
                                          child: Icon(Icons.star, color: Colors.yellow),
                                        ),
                                      )
                                  ],
                                ),
                              )),
                          ],

                          onReorder: (oldIndex, newIndex) {
                            if (kIsWeb) {
                              final item = _webImages.removeAt(oldIndex);
                              _webImages.insert(newIndex, item);
                            } else {
                              final item = _images.removeAt(oldIndex);
                              _images.insert(newIndex, item);
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                Step(
                  title: const Text("Location (Manual)"),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: latController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Latitude"),
                      ),
                      TextFormField(
                        controller: lngController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Longitude"),
                      ),
                    ],
                  ),
                ),
                Step(
                title: const Text("Images"),
                content: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Pick Images"),
                    ),
                    const SizedBox(height: 8),

                    ReorderableGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: [
                        if (kIsWeb)
                          ..._webImages.map((bytes) => GestureDetector(
                            onTap: () => setState(() => _coverImageUrl = bytes.hashCode.toString()),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(bytes, fit: BoxFit.cover),
                                if (_coverImageUrl == bytes.hashCode.toString())
                                  Container(
                                    color: Colors.black45,
                                    child: const Center(
                                      child: Icon(Icons.star, color: Colors.yellow),
                                    ),
                                  )
                              ],
                            ),
                          )),
                        if (!kIsWeb)
                          ..._images.map((f) => GestureDetector(
                            onTap: () => setState(() => _coverImageUrl = f.path),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(f, fit: BoxFit.cover),
                                if (_coverImageUrl == f.path)
                                  Container(
                                    color: Colors.black45,
                                    child: const Center(
                                      child: Icon(Icons.star, color: Colors.yellow),
                                    ),
                                  )
                              ],
                            ),
                          )),
                      ],
                      onReorder: (oldIndex, newIndex) {
                        if (kIsWeb) {
                          final item = _webImages.removeAt(oldIndex);
                          _webImages.insert(newIndex, item);
                        } else {
                          final item = _images.removeAt(oldIndex);
                          _images.insert(newIndex, item);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              ],
            ),
    );
  }
}