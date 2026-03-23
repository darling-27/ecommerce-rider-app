import 'package:flutter/material.dart';
import 'package:rider_app/screens/home_screen.dart';
import 'package:rider_app/controllers/user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:rider_app/widgets/profile_image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleNumController = TextEditingController();
  final _bankAccController = TextEditingController();

  String _withdrawalFreq = "Weekly";
  String _emergencyPeriod = "3 Days";

  File? _aadhaarPic, _panPic, _vehiclePic, _rcPic, _platePic, _licensePic;
  final _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      switch (type) {
        case 'aadhaar': _aadhaarPic = File(image.path); break;
        case 'pan': _panPic = File(image.path); break;
        case 'vehicle': _vehiclePic = File(image.path); break;
        case 'rc': _rcPic = File(image.path); break;
        case 'plate': _platePic = File(image.path); break;
        case 'license': _licensePic = File(image.path); break;
      }
    });
  }

  void _submit() {
    final hasProfile = userController.profilePic != null || (userController.profileImageUrl != null && userController.profileImageUrl!.isNotEmpty);
    if (_nameController.text.isEmpty || _phoneController.text.length != 10 || !hasProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name, phone and upload profile pic'), backgroundColor: Colors.black),
      );
      return;
    }
    
    userController.updateUserData(
      newName: _nameController.text,
      newPhone: _phoneController.text,
      newAadhaar: _aadhaarController.text,
      newAadhaarPic: _aadhaarPic,
      newPan: _panController.text,
      newPanPic: _panPic,
      newVehicleNumber: _vehicleNumController.text,
      newVehiclePic: _vehiclePic,
      newRcPic: _rcPic,
      newPlatePic: _platePic,
      newLicense: _licenseController.text,
      newLicensePic: _licensePic,
      newBankAcc: _bankAccController.text,
      newFreq: _withdrawalFreq,
      newEmergency: _emergencyPeriod,
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('REGISTRATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ProfileImagePicker(initialFile: userController.profilePic),
            const SizedBox(height: 20),
            _buildSection('PERSONAL IDENTITY', [
              _buildField(_nameController, 'FULL NAME', Icons.person),
              _buildField(_phoneController, 'PHONE NUMBER', Icons.phone, type: TextInputType.phone),
              _buildField(_aadhaarController, 'AADHAAR NUMBER', Icons.credit_card),
              _buildImagePicker('AADHAAR CARD PHOTO', _aadhaarPic, 'aadhaar'),
              _buildField(_panController, 'PAN CARD NUMBER', Icons.badge),
              _buildImagePicker('PAN CARD PHOTO', _panPic, 'pan'),
            ]),
            _buildSection('VEHICLE DOCUMENTS', [
              _buildField(_vehicleNumController, 'VEHICLE NUMBER', Icons.directions_bike),
              _buildImagePicker('VEHICLE PHOTO', _vehiclePic, 'vehicle'),
              _buildImagePicker('RC PHOTO', _rcPic, 'rc'),
              _buildImagePicker('NUMBER PLATE PHOTO', _platePic, 'plate'),
            ]),
            _buildSection('DRIVING LICENSE', [
              _buildField(_licenseController, 'LICENSE NUMBER', Icons.card_membership),
              _buildImagePicker('DRIVING LICENSE PHOTO', _licensePic, 'license'),
            ]),
            _buildSection('WITHDRAWAL PREFERENCES', [
              _buildField(_bankAccController, 'BANK ACCOUNT NUMBER', Icons.account_balance),
              _buildDropdown('WITHDRAWAL FREQUENCY', _withdrawalFreq, ['Weekly', 'Bi-weekly', 'Monthly'], (val) {
                setState(() => _withdrawalFreq = val!);
              }),
              _buildDropdown('EMERGENCY WITHDRAWAL PERIOD', _emergencyPeriod, ['1 Day', '2 Days', '3 Days'], (val) {
                setState(() => _emergencyPeriod = val!);
              }),
            ]),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
              child: const Text('SUBMIT APPLICATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black)),
        const Divider(color: Colors.black, thickness: 2),
        const SizedBox(height: 15),
        ...children,
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.black, size: 20),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, File? file, String type) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: file == null ? Colors.black12 : Colors.black, width: file == null ? 1 : 2),
        ),
        child: file == null 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 30),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.file(file, fit: BoxFit.cover),
                Container(color: Colors.black26),
                const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 40)),
              ],
            ),
      ),
    );
  }
}
