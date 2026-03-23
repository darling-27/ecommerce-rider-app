import 'package:flutter/material.dart';
import 'package:rider_app/controllers/user_controller.dart';
import 'package:rider_app/screens/login_screen.dart';
import 'dart:io';
import 'package:rider_app/widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _aadhaarController;
  late TextEditingController _panController;
  late TextEditingController _licenseController;
  late TextEditingController _vehicleNumController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userController.name);
    _phoneController = TextEditingController(text: userController.phone);
    _aadhaarController = TextEditingController(text: userController.aadhaarNumber);
    _panController = TextEditingController(text: userController.panNumber);
    _licenseController = TextEditingController(text: userController.licenseNumber);
    _vehicleNumController = TextEditingController(text: userController.vehicleNumber);
    
    userController.addListener(_refresh);
  }

  @override
  void dispose() {
    userController.removeListener(_refresh);
    _nameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _licenseController.dispose();
    _vehicleNumController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted && !_isEditing) {
      setState(() {
        _nameController.text = userController.name;
        _phoneController.text = userController.phone;
        _aadhaarController.text = userController.aadhaarNumber;
        _panController.text = userController.panNumber;
        _licenseController.text = userController.licenseNumber;
        _vehicleNumController.text = userController.vehicleNumber;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    userController.updateUserData(
      newName: _nameController.text,
      newPhone: _phoneController.text,
      newAadhaar: _aadhaarController.text,
      newPan: _panController.text,
      newLicense: _licenseController.text,
      newVehicleNumber: _vehicleNumController.text,
    );
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.black),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.black))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY PROFILE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildInfoSection('PERSONAL IDENTITY', [
              _buildEditableInfoRow(Icons.person, 'FULL NAME', _nameController),
              _buildEditableInfoRow(Icons.phone, 'PHONE NUMBER', _phoneController),
              _buildEditableInfoRow(Icons.credit_card, 'AADHAAR NUMBER', _aadhaarController),
              if (userController.aadhaarPic != null) _buildDocPreview('AADHAAR CARD', userController.aadhaarPic!),
              _buildEditableInfoRow(Icons.badge, 'PAN CARD', _panController),
              if (userController.panPic != null) _buildDocPreview('PAN CARD', userController.panPic!),
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('VEHICLE INFORMATION', [
              _buildEditableInfoRow(Icons.directions_bike, 'VEHICLE NUMBER', _vehicleNumController),
              if (userController.vehiclePic != null) _buildDocPreview('VEHICLE PHOTO', userController.vehiclePic!),
              if (userController.rcPic != null) _buildDocPreview('RC PHOTO', userController.rcPic!),
              if (userController.platePic != null) _buildDocPreview('NUMBER PLATE', userController.platePic!),
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('DRIVING LICENSE', [
              _buildEditableInfoRow(Icons.card_membership, 'LICENSE NUMBER', _licenseController),
              if (userController.licensePic != null) _buildDocPreview('DRIVING LICENSE', userController.licensePic!),
            ]),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 60),
                elevation: 0,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          ProfileImagePicker(),
          const SizedBox(height: 16),
          Text(userController.name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const Text('VERIFIED DELIVERY PARTNER', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const Divider(color: Colors.black, thickness: 1),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditableInfoRow(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                _isEditing 
                  ? TextField(
                      controller: controller,
                      cursorColor: Colors.black,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                    )
                  : Text(controller.text.isEmpty ? 'NOT PROVIDED' : controller.text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPreview(String label, File file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
          child: Image.file(file, height: 120, width: double.infinity, fit: BoxFit.cover),
        ),
      ],
    );
  }
}
