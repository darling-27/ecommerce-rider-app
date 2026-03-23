import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<bool> requestCameraPermission() async {
    // Simplified permission handling for now
    return true;
  }

  Future<bool> requestGalleryPermission() async {
    // Simplified permission handling for now
    return true;
  }

  Future<File?> captureImage() async {
    try {
      // Check camera permission
      if (!(await requestCameraPermission())) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      // Check gallery permission
      if (!(await requestGalleryPermission())) {
        throw Exception('Gallery permission denied');
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<List<File>?> captureMultipleImages({int maxImages = 5}) async {
    try {
      if (!(await requestCameraPermission())) {
        throw Exception('Camera permission denied');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        return images.take(maxImages).map((xFile) => File(xFile.path)).toList();
      }
      return null;
    } catch (e) {
      print('Error capturing multiple images: $e');
      return null;
    }
  }

  Future<File?> captureDocumentImage() async {
    try {
      if (!(await requestCameraPermission())) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error capturing document image: $e');
      return null;
    }
  }

  Future<String?> saveImageToGallery(File imageFile) async {
    try {
      // In real implementation, you might want to use a plugin like image_gallery_saver
      // For now, we'll just return the file path
      return imageFile.path;
    } catch (e) {
      print('Error saving image to gallery: $e');
      return null;
    }
  }

  Future<void> deleteImage(File imageFile) async {
    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<File?> resizeImage(File imageFile, {int maxWidth = 1200, int maxHeight = 1200}) async {
    try {
      // In real implementation, you would use image package to resize
      // For now, we'll return the original file
      return imageFile;
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  Future<String?> getImageMetadata(File imageFile) async {
    try {
      // In real implementation, you would extract EXIF data
      // For now, we'll return basic info
      final stat = await imageFile.stat();
      return 'Size: ${stat.size} bytes, Modified: ${stat.modified}';
    } catch (e) {
      print('Error getting image metadata: $e');
      return null;
    }
  }
}

class ImageCaptureDialog extends StatefulWidget {
  final String title;
  final String description;
  final bool allowMultiple;
  final int maxImages;
  final bool documentMode; // For document capture with guidelines

  const ImageCaptureDialog({
    Key? key,
    required this.title,
    required this.description,
    this.allowMultiple = false,
    this.maxImages = 1,
    this.documentMode = false,
  }) : super(key: key);

  @override
  _ImageCaptureDialogState createState() => _ImageCaptureDialogState();
}

class _ImageCaptureDialogState extends State<ImageCaptureDialog> {
  final CameraService _cameraService = CameraService();
  List<File> _capturedImages = [];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.description),
            const SizedBox(height: 20),
            if (widget.documentMode) _buildDocumentGuidelines(),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_capturedImages.isNotEmpty)
          ElevatedButton(
            onPressed: _isProcessing ? null : _submitImages,
            child: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit'),
          ),
      ],
    );
  }

  Widget _buildDocumentGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Icon(Icons.document_scanner, size: 40, color: Colors.blue),
          SizedBox(height: 10),
          Text(
            'Document Capture Guidelines',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Ensure good lighting\n• Hold document flat\n• Include all corners\n• Avoid glare and shadows',
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_capturedImages.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_camera, size: 48, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'No images captured yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (widget.allowMultiple) {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _capturedImages.length,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _capturedImages[index],
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              _capturedImages.first,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeAllImages,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _captureFromCamera,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _pickFromGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _captureFromCamera() async {
    setState(() => _isProcessing = true);

    try {
      File? image;
      if (widget.documentMode) {
        image = await _cameraService.captureDocumentImage();
      } else if (widget.allowMultiple && _capturedImages.length < widget.maxImages) {
        final images = await _cameraService.captureMultipleImages(
          maxImages: widget.maxImages - _capturedImages.length,
        );
        if (images != null) {
          setState(() => _capturedImages.addAll(images));
        }
      } else {
        image = await _cameraService.captureImage();
      }

      if (image != null && !widget.allowMultiple) {
        setState(() => _capturedImages = [image!]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      if (widget.allowMultiple && _capturedImages.length < widget.maxImages) {
        final images = await _cameraService.captureMultipleImages(
          maxImages: widget.maxImages - _capturedImages.length,
        );
        if (images != null) {
          setState(() => _capturedImages.addAll(images));
        }
      } else {
        final image = await _cameraService.pickImageFromGallery();
        if (image != null) {
          setState(() => _capturedImages = [image]);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _capturedImages.removeAt(index));
  }

  void _removeAllImages() {
    setState(() => _capturedImages.clear());
  }

  void _submitImages() {
    Navigator.pop(context, _capturedImages);
  }
}

class DocumentCaptureScreen extends StatefulWidget {
  final String documentType;
  final String documentTitle;
  final Function(List<File>) onImagesCaptured;

  const DocumentCaptureScreen({
    Key? key,
    required this.documentType,
    required this.documentTitle,
    required this.onImagesCaptured,
  }) : super(key: key);

  @override
  _DocumentCaptureScreenState createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen> {
  final CameraService _cameraService = CameraService();
  List<File> _capturedImages = [];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture ${widget.documentTitle}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructions(),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 20),
            _buildCaptureButtons(),
            const Spacer(),
            if (_capturedImages.isNotEmpty)
              _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capture Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please capture clear images of your ${widget.documentTitle.toLowerCase()}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Ensure good lighting\n• Hold document flat\n• Capture all corners\n• Avoid glare and shadows\n• Make sure text is readable',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_capturedImages.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner, size: 64, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              'No images captured yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Capture or select images below',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PageView.builder(
        itemCount: _capturedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _capturedImages[index],
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Image ${index + 1} of ${_capturedImages.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptureButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _selectFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('From Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _submitDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Submit Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _captureImage() async {
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraService.captureDocumentImage();
      if (image != null) {
        setState(() => _capturedImages.add(image));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraService.pickImageFromGallery();
      if (image != null) {
        setState(() => _capturedImages.add(image));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _capturedImages.removeAt(index));
  }

  Future<void> _submitDocument() async {
    setState(() => _isProcessing = true);

    try {
      // Process images (resize, compress, etc.)
      final processedImages = <File>[];
      for (var image in _capturedImages) {
        final processed = await _cameraService.resizeImage(image);
        if (processed != null) {
          processedImages.add(processed);
        }
      }

      if (processedImages.isNotEmpty) {
        widget.onImagesCaptured(processedImages);
        Navigator.pop(context);
      } else {
        throw Exception('Failed to process images');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}