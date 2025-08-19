import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/storage_service.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String hotelId;
  final String? roomId;
  final Map<String, dynamic>? roomData;

  const AddEditRoomScreen({
    super.key,
    required this.hotelId,
    this.roomId,
    this.roomData,
  });

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  final typeController = TextEditingController();
  final priceController = TextEditingController();
  final capacityController = TextEditingController();
  final featuresController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// Newly picked (local) images, will be uploaded on save
  final List<File> _newImages = [];

  /// URLs of already uploaded images (existing images)
  final List<String> _uploadedImages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.roomData != null) {
      // Prefill form with provided data
      final data = widget.roomData!;
      typeController.text = (data['type'] ?? '').toString();
      priceController.text = (data['price'] ?? '').toString();
      capacityController.text = (data['capacity'] ?? '').toString();
      featuresController.text = (data['features'] as List<dynamic>?)?.join(', ') ?? '';
      final imgs = (data['images'] as List<dynamic>?) ?? [];
      _uploadedImages.addAll(imgs.map((e) => e.toString()));
    }
  }

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();
    capacityController.dispose();
    featuresController.dispose();
    super.dispose();
  }

  /// Pick multiple new images from gallery
  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isNotEmpty) {
        setState(() {
          _newImages.addAll(picked.map((p) => File(p.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
    }
  }

  /// Remove an existing uploaded image (URL) from the list (does NOT delete from storage)
  Future<void> _removeUploadedImage(String url) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove Image'),
            content: const Text('Remove this image from the room? (image file will remain in storage)'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
            ],
          ),
        ) ??
        false;

    if (!ok) return;
    setState(() => _uploadedImages.remove(url));
  }

  /// Remove a newly picked image (local file)
  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  /// Save room: upload new images, combine image lists, create/update room doc
  Future<void> saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final roomId = widget.roomId ?? const Uuid().v4();

    try {
      // Upload new images and append their URLs
      for (final file in List<File>.from(_newImages)) {
        final url = await StorageService.uploadRoomImage(roomId, file);
        _uploadedImages.add(url);
      }

      // Parse numeric fields safely
      final price = double.tryParse(priceController.text.trim()) ?? 0.0;
      final capacity = int.tryParse(capacityController.text.trim()) ?? 1;
      final features = featuresController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final roomData = {
        'id': roomId,
        'hotelId': widget.hotelId,
        'type': typeController.text.trim(),
        'price': price,
        'capacity': capacity,
        'features': features,
        'images': _uploadedImages,
        'isAvailable': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final ref = FirebaseFirestore.instance.collection('rooms').doc(roomId);

      if (widget.roomId == null) {
        // create new
        await ref.set(roomData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room added')));
      } else {
        // update existing (merge so other fields not overwritten)
        await ref.set(roomData, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room updated')));
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildExistingImagesRow() {
    if (_uploadedImages.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _uploadedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final url = _uploadedImages[i];
              return Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 140, height: 90, fit: BoxFit.cover)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => _removeUploadedImage(url),
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.delete, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagesRow() {
    if (_newImages.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Images (will be uploaded)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _newImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = _newImages[i];
              return Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(f, width: 140, height: 90, fit: BoxFit.cover)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => _removeNewImage(i),
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.roomId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Room' : 'Add Room')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    TextFormField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Room Type', hintText: 'e.g. Deluxe, Suite'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Type is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price per night (USD)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Price is required';
                        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Capacity (guests)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Capacity required';
                        if (int.tryParse(v.trim()) == null) return 'Enter a whole number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: featuresController,
                      decoration: const InputDecoration(labelText: 'Features (comma separated)', hintText: 'WiFi, AC, Sea view'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Existing images (from URLs)
                    _buildExistingImagesRow(),
                    const SizedBox(height: 12),

                    // New images (local files)
                    _buildNewImagesRow(),
                    const SizedBox(height: 12),

                    // Buttons for image actions
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: pickImages, icon: const Icon(Icons.photo_library), label: const Text('Pick Images')),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Quick camera capture for single image
                            final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if (picked != null) {
                              setState(() => _newImages.add(File(picked.path)));
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: saveRoom,
                      child: Text(isEdit ? 'Update Room' : 'Add Room'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ]),
                ),
              ),
            ),
    );
  }
}