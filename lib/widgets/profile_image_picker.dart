import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rider_app/services/image_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rider_app/controllers/user_controller.dart';

class ProfileImagePicker extends StatefulWidget {
  // optional existing file to show
  final File? initialFile;
  final double radius;
  final bool allowChange;

  const ProfileImagePicker({super.key, this.initialFile, this.radius = 50, this.allowChange = true});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _localFile;
  String? _remoteUrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _localFile = widget.initialFile;
    _remoteUrl = userController.profileImageUrl;
  }

  Future<void> _changeImage() async {
    if (!widget.allowChange) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final picked = await ImageService.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        setState(() { _loading = false; });
        return;
      }

      final cropped = await ImageService.cropImage(picked);
      final toCompress = cropped ?? picked;
      final compressed = await ImageService.compressImage(toCompress, quality: 85) ?? toCompress;

      // upload to firebase storage if user is logged in, otherwise keep locally
      final user = FirebaseAuth.instance.currentUser;
      String? downloadUrl;
      if (user != null) {
        final path = 'profiles/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        downloadUrl = await ImageService.uploadFile(compressed, path: path);
      }

      // update controller
      userController.updateUserData(newProfilePic: compressed, newProfileImageUrl: downloadUrl);

      setState(() {
        _localFile = compressed;
        _remoteUrl = downloadUrl;
      });
    } catch (e) {
      setState(() { _error = 'Failed to update image'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (_loading) {
      avatar = CircleAvatar(radius: widget.radius, backgroundColor: Colors.grey[100], child: const CircularProgressIndicator(color: Colors.black));
    } else if (_localFile != null) {
      avatar = CircleAvatar(radius: widget.radius, backgroundColor: Colors.grey[100], backgroundImage: FileImage(_localFile!));
    } else if (_remoteUrl != null) {
      avatar = CircleAvatar(radius: widget.radius, backgroundColor: Colors.grey[100], backgroundImage: NetworkImage(_remoteUrl!));
    } else {
      avatar = CircleAvatar(radius: widget.radius, backgroundColor: Colors.grey[100], child: const Icon(Icons.person, size: 50, color: Colors.black));
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _changeImage,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
            child: avatar,
          ),
        ),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }
}
