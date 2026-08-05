import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class CreateDonationScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const CreateDonationScreen({super.key, required this.user});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _titleController = TextEditingController();
  final _weightController = TextEditingController(text: '2');
  final _addressController = TextEditingController();

  String _selectedCategory = 'Books';
  final List<String> _base64Images = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Books',
    'Kitchenware',
    'Cupboards & Furniture',
    'Clothes & Wearing',
    'Electronics',
    'Toys & Games',
    'Food & Grains',
    'Medical Supplies',
    'Other'
  ];

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _base64Images.add('data:image/png;base64,${base64Encode(bytes)}');
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _base64Images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _base64Images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and attach at least 1 photo.')),
      );
      return;
    }

    final res = await ApiService.post('/donations', {
      'donorId': widget.user['_id'],
      'donorName': widget.user['name'],
      'title': _titleController.text,
      'category': _selectedCategory,
      'condition': 'Gently Used',
      'weightKg': double.tryParse(_weightController.text) ?? 1,
      'address': _addressController.text.isEmpty
          ? 'Pune Central, India'
          : _addressController.text,
      'photoUrls': _base64Images,
    });

    if (res.statusCode == 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Multi-photo donation posted successfully!')),
      );
      _titleController.clear();
      setState(() => _base64Images.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌱 Post a New Donation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Item Title *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _categories.contains(_selectedCategory) ? _selectedCategory : _categories[0],
            decoration: const InputDecoration(
              labelText: 'Donation Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Est. Weight (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Pickup Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '📷 Attached Photos (Multiple Photos Allowed):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_base64Images.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _base64Images.length,
                itemBuilder: (c, i) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: MemoryImage(
                              base64Decode(_base64Images[i].split(',').last),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removePhoto(i),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo, color: Colors.green),
            label: const Text('Add Photo to Gallery'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Post Donation Item',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
