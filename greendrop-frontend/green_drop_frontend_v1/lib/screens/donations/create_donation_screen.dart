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
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Books';
  String _selectedCondition = 'Gently Used / Good';
  final List<String> _photoList = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

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

  final List<String> _conditions = [
    'Like New / Pristine',
    'Gently Used / Good',
    'Fair / Worn Out (For Recycling)',
  ];

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.user['address']?['formattedAddress'] ?? 'Pune, Maharashtra';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _photoList.add('data:image/png;base64,${base64Encode(bytes)}');
        });
      }
    } catch (_) {}
  }

  void _addPhotoFromUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _photoList.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoList.removeAt(index);
    });
  }

  String _getDefaultCategoryPhoto(String category) {
    switch (category) {
      case 'Books':
        return 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500';
      case 'Clothes & Wearing':
        return 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=500';
      case 'Electronics':
        return 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500';
      case 'Toys & Games':
        return 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=500';
      case 'Food & Grains':
        return 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=500';
      default:
        return 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb0?w=500';
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please enter an item title!'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Fallback to high quality category image if user didn't attach custom photo
    final finalPhotos = _photoList.isNotEmpty
        ? _photoList
        : [_getDefaultCategoryPhoto(_selectedCategory)];

    try {
      final response = await ApiService.post('/donations', {
        'donorId': widget.user['_id'],
        'donorName': widget.user['name'] ?? 'Donor',
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'weightKg': double.tryParse(_weightController.text) ?? 2.0,
        'address': _addressController.text.trim().isEmpty
            ? 'Pune, Maharashtra'
            : _addressController.text.trim(),
        'photoUrls': finalPhotos,
      });
      if (response.statusCode != 201) {
        throw Exception(ApiService.errorMessage(response, fallback: 'Could not publish this donation.'));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(error.toString().replaceFirst('Exception: ', 'Could not publish: ')),
          ),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }

    final newDonationData = {
      '_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'donorId': widget.user['_id'],
      'donorName': widget.user['name'] ?? 'Donor',
      'title': _titleController.text.trim(),
      'category': _selectedCategory,
      'condition': _selectedCondition,
      'weightKg': double.tryParse(_weightController.text) ?? 2.0,
      'address': _addressController.text.trim().isEmpty ? 'Pune, Maharashtra' : _addressController.text.trim(),
      'photoUrls': finalPhotos,
      'status': 'AVAILABLE',
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('🎉 Donation posted successfully! Displayed live instantly.'),
      ),
    );
    Navigator.pop(context, newDonationData);
  }


  @override
  Widget build(BuildContext context) {
    final isPage = Navigator.canPop(context);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.add_circle, color: Colors.green.shade800),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌱 Post a New Donation Item',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Share items with verified NGOs or Zero-Waste Recyclers.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
          const Divider(height: 24),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Item Title *',
              hintText: 'e.g. Winter Jackets, School Textbooks, Microwave',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _categories.contains(_selectedCategory) ? _selectedCategory : _categories[0],
            decoration: const InputDecoration(
              labelText: 'Donation Category *',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _conditions.contains(_selectedCondition) ? _selectedCondition : _conditions[1],
            decoration: const InputDecoration(
              labelText: 'Item Condition *',
              border: OutlineInputBorder(),
            ),
            items: _conditions
                .map((cond) => DropdownMenuItem(value: cond, child: Text(cond)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCondition = v!),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Est. Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Location Address *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            '📷 Attach Photos (Gallery Upload or Image Link):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (_photoList.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photoList.length,
                itemBuilder: (c, i) {
                  final imgStr = _photoList[i];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imgStr.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(imgStr.split(',').last),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  imgStr,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(Icons.image),
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
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade900,
                ),
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Pick Gallery Image'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'Or paste photo URL...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_link, color: Colors.green),
                      onPressed: _addPhotoFromUrl,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.publish, color: Colors.white),
            label: const Text(
              'Publish Donation Listing',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _isSubmitting ? null : _submit,
          )
        ],
      ),
    );

    if (isPage) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post New Donation'),
          backgroundColor: Colors.green.shade800,
          foregroundColor: Colors.white,
        ),
        body: content,
      );
    }

    return content;
  }
}
