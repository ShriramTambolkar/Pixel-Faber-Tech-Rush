import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/main_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  String _role = 'DONOR';
  bool _isLoading = false;

  final _emailController = TextEditingController(text: 'donor@greendrop.com');
  final _nameController = TextEditingController(text: 'Shubham N');
  final _phoneController = TextEditingController(text: '+91 9876543210');

  final _darpanIdController = TextEditingController();
  final _certUrlController = TextEditingController();
  final _panUrlController = TextEditingController();
  final _officeAddressController = TextEditingController();

  void _fillDemoAccount(String type) {
    setState(() {
      if (type == 'DONOR') {
        _role = 'DONOR';
        _nameController.text = 'Shubham N (Donor)';
        _emailController.text = 'donor@greendrop.com';
        _phoneController.text = '+91 9876543210';
      } else if (type == 'NGO') {
        _role = 'NGO';
        _nameController.text = 'Smile Foundation Pune';
        _emailController.text = 'ngo@smilepune.org';
        _phoneController.text = '+91 9123456789';
        _darpanIdController.text = 'MH/2026/0048123';
        _certUrlController.text = 'https://example.com/ngo-trust-deed.pdf';
        _panUrlController.text = 'https://example.com/ngo-pan-card.pdf';
        _officeAddressController.text = 'Deccan Gymkhana, Pune, MH 411004';
      } else if (type == 'ADMIN') {
        _role = 'ADMIN';
        _nameController.text = 'Platform System Admin';
        _emailController.text = 'admin@greendrop.org';
        _phoneController.text = '+91 0000000000';
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final path = _isLogin ? '/auth/login' : '/auth/register';
    Map<String, dynamic> body = {'email': _emailController.text.trim()};

    if (!_isLogin) {
      body.addAll({
        'role': _role,
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      });

      if (_role == 'NGO') {
        body['ngoDetails'] = {
          'darpanId': _darpanIdController.text.trim(),
          'registrationCertificateUrl': _certUrlController.text.trim(),
          'panCardUrl': _panUrlController.text.trim(),
          'officeAddress': _officeAddressController.text.trim(),
        };
      }
    }

    try {
      final res = await ApiService.post(path, body);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainHomeScreen(user: data['data']),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(data['error'] ?? 'Authentication failed'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // HERO APP LOGO & HEADER BANNER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E5631), Color(0xFF4C9A2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade900.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          size: 44,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '🌱 GreenDrop',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Connecting Donors & Verified NGOs for Zero-Waste Charity & Disaster Relief',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          Chip(
                            backgroundColor: Colors.white24,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            label: Text('✨ Zero Waste'),
                          ),
                          Chip(
                            backgroundColor: Colors.white24,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            label: Text('🚨 Disaster Relief'),
                          ),
                          Chip(
                            backgroundColor: Colors.white24,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            label: Text('🛡️ Verified NGOs'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // QUICK DEMO ACCOUNTS BAR FOR 1-CLICK LOGIN
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          '⚡ Quick 1-Click Demo Login:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                              ),
                              icon: const Icon(Icons.person, size: 16, color: Colors.green),
                              label: const Text('Donor Demo', style: TextStyle(fontSize: 12)),
                              onPressed: () => _fillDemoAccount('DONOR'),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                              ),
                              icon: const Icon(Icons.corporate_fare, size: 16, color: Colors.blue),
                              label: const Text('NGO Demo', style: TextStyle(fontSize: 12)),
                              onPressed: () => _fillDemoAccount('NGO'),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                              ),
                              icon: const Icon(Icons.security, size: 16, color: Colors.orange),
                              label: const Text('Admin Demo', style: TextStyle(fontSize: 12)),
                              onPressed: () => _fillDemoAccount('ADMIN'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // MAIN FORM CARD CONTAINER
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOGGLE LOGIN / REGISTER TABS
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                selected: _isLogin,
                                selectedColor: Colors.green.shade800,
                                labelStyle: TextStyle(
                                  color: _isLogin ? Colors.white : Colors.black87,
                                ),
                                onSelected: (val) => setState(() => _isLogin = true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                selected: !_isLogin,
                                selectedColor: Colors.green.shade800,
                                labelStyle: TextStyle(
                                  color: !_isLogin ? Colors.white : Colors.black87,
                                ),
                                onSelected: (val) => setState(() => _isLogin = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ROLE SELECTION CARDS IF REGISTERING
                        if (!_isLogin) ...[
                          const Text(
                            'Select Account Type:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildRoleCard('DONOR', 'Donor 👤', Colors.green),
                              const SizedBox(width: 8),
                              _buildRoleCard('NGO', 'NGO 🏢', Colors.blue),
                              const SizedBox(width: 8),
                              _buildRoleCard('ADMIN', 'Admin 🛡️', Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name / Organization Name *',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Phone Number *',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (_role == 'NGO') ...[
                            TextField(
                              controller: _darpanIdController,
                              decoration: const InputDecoration(
                                labelText: 'NGO NITI Aayog Darpan ID (Confidential)',
                                prefixIcon: Icon(Icons.verified),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _officeAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Registered Office Address *',
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Registered Email Address *',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // SUBMIT BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: Colors.green.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isLogin ? 'Log In to GreenDrop' : 'Create $_role Account',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String roleVal, String label, Color color) {
    final isSelected = _role == roleVal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = roleVal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
