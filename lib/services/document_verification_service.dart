import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentVerificationService {
  static final DocumentVerificationService _instance = DocumentVerificationService._internal();
  factory DocumentVerificationService() => _instance;
  DocumentVerificationService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  Future<String?> uploadDocument(File imageFile, String documentType, String userId) async {
    try {
      final fileName = '${documentType}_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('documents/$userId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  Future<bool> submitDocumentForVerification({
    required String userId,
    required String documentType,
    required String documentNumber,
    required String imageUrl,
    required DateTime expiryDate,
  }) async {
    try {
      final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('document_verifications').doc(docId).set({
        'id': docId,
        'userId': userId,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'imageUrl': imageUrl,
        'expiryDate': expiryDate.toIso8601String(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error submitting document for verification: $e');
      return false;
    }
  }

  Future<List<DocumentVerification>> getUserDocuments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('document_verifications')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => DocumentVerification.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching user documents: $e');
      return [];
    }
  }

  Future<bool> updateDocumentStatus({
    required String documentId,
    required String status,
    String? rejectionReason,
    String? reviewerId,
  }) async {
    try {
      await _firestore.collection('document_verifications').doc(documentId).update({
        'status': status,
        'rejectionReason': rejectionReason,
        'reviewerId': reviewerId,
        'reviewedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error updating document status: $e');
      return false;
    }
  }

  Future<DocumentVerification?> getDocumentById(String documentId) async {
    try {
      final doc = await _firestore.collection('document_verifications').doc(documentId).get();
      if (doc.exists) {
        return DocumentVerification.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }

  Stream<List<DocumentVerification>> getPendingVerifications() {
    return _firestore
        .collection('document_verifications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => DocumentVerification.fromJson(doc.data())).toList());
  }

  Future<List<DocumentType>> getRequiredDocumentTypes() async {
    // In real implementation, this would come from backend
    return [
      DocumentType(
        id: 'aadhaar',
        name: 'Aadhaar Card',
        description: 'Required for identity verification',
        required: true,
        hasExpiry: false,
      ),
      DocumentType(
        id: 'pan',
        name: 'PAN Card',
        description: 'Required for tax purposes',
        required: true,
        hasExpiry: false,
      ),
      DocumentType(
        id: 'license',
        name: 'Driving License',
        description: 'Required for driving verification',
        required: true,
        hasExpiry: true,
      ),
      DocumentType(
        id: 'vehicle_rc',
        name: 'Vehicle Registration',
        description: 'Required for vehicle verification',
        required: true,
        hasExpiry: true,
      ),
      DocumentType(
        id: 'vehicle_insurance',
        name: 'Vehicle Insurance',
        description: 'Required for insurance coverage',
        required: true,
        hasExpiry: true,
      ),
    ];
  }
}

class DocumentVerification {
  final String id;
  final String userId;
  final String documentType;
  final String documentNumber;
  final String imageUrl;
  final DateTime expiryDate;
  final String status; // 'pending', 'verified', 'rejected'
  final String? rejectionReason;
  final String? reviewerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reviewedAt;

  DocumentVerification({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentNumber,
    required this.imageUrl,
    required this.expiryDate,
    required this.status,
    this.rejectionReason,
    this.reviewerId,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon => 
      DateTime.now().isBefore(expiryDate) && 
      DateTime.now().add(const Duration(days: 30)).isAfter(expiryDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'reviewerId': reviewerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory DocumentVerification.fromJson(Map<String, dynamic> json) {
    return DocumentVerification(
      id: json['id'],
      userId: json['userId'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      imageUrl: json['imageUrl'],
      expiryDate: DateTime.parse(json['expiryDate']),
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      reviewerId: json['reviewerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    );
  }
}

class DocumentType {
  final String id;
  final String name;
  final String description;
  final bool required;
  final bool hasExpiry;

  DocumentType({
    required this.id,
    required this.name,
    required this.description,
    required this.required,
    required this.hasExpiry,
  });
}

class DocumentUploadScreen extends StatefulWidget {
  final String userId;
  final DocumentType documentType;
  final DocumentVerification? existingDocument;

  const DocumentUploadScreen({
    Key? key,
    required this.userId,
    required this.documentType,
    this.existingDocument,
  }) : super(key: key);

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final DocumentVerificationService _service = DocumentVerificationService();
  final TextEditingController _documentNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingDocument != null) {
      _documentNumberController.text = widget.existingDocument!.documentNumber;
      _selectedExpiryDate = widget.existingDocument!.expiryDate;
      _expiryDateController.text = _formatDate(_selectedExpiryDate!);
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${widget.documentType.name}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentInfo(),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildDocumentNumberField(),
            if (widget.documentType.hasExpiry) ...[
              const SizedBox(height: 20),
              _buildExpiryDateField(),
            ],
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.documentType.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.documentType.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            if (widget.documentType.required) ...[
              const SizedBox(height: 8),
              const Text(
                'This document is required',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage == null ? Colors.grey : Colors.green,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap to select document image',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Make sure the image is clear and readable',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                : Image.file(
                    _selectedImage!,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentNumberField() {
    return TextField(
      controller: _documentNumberController,
      decoration: const InputDecoration(
        labelText: 'Document Number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildExpiryDateField() {
    return TextField(
      controller: _expiryDateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Expiry Date',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      onTap: _selectExpiryDate,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading || _selectedImage == null ? null : _submitDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isUploading
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
                  Text('Uploading...'),
                ],
              )
            : Text(
                widget.existingDocument != null ? 'Update Document' : 'Submit for Verification',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose where to pick your document image from'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (action == null) return;

    File? image;
    if (action == 'camera') {
      image = await _service.pickImageFromCamera();
    } else {
      image = await _service.pickImageFromGallery();
    }

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _expiryDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submitDocument() async {
    if (_documentNumberController.text.isEmpty || 
        _selectedImage == null ||
        (widget.documentType.hasExpiry && _selectedExpiryDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload image to Firebase Storage
      final imageUrl = await _service.uploadDocument(
        _selectedImage!,
        widget.documentType.id,
        widget.userId,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload document image');
      }

      // Submit for verification
      final success = await _service.submitDocumentForVerification(
        userId: widget.userId,
        documentType: widget.documentType.id,
        documentNumber: _documentNumberController.text,
        imageUrl: imageUrl,
        expiryDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 3650)),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document submitted for verification!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to submit document');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}