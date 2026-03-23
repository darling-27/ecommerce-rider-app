class Document {
  final String id;
  final String name;
  final String type; // 'aadhaar', 'pan', 'license', 'vehicle_rc', 'vehicle_insurance'
  final String documentNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String status; // 'verified', 'pending', 'expired', 'rejected'
  final String? rejectionReason;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.documentNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    this.rejectionReason,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon => 
      DateTime.now().isBefore(expiryDate) && 
      DateTime.now().add(const Duration(days: 30)).isAfter(expiryDate);

  int get daysUntilExpiry {
    final difference = expiryDate.difference(DateTime.now());
    return difference.inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'documentNumber': documentNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      documentNumber: json['documentNumber'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ComplianceAlert {
  final String id;
  final String documentId;
  final String documentType;
  final String alertType; // 'expiry_warning', 'expired', 'verification_required'
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  ComplianceAlert({
    required this.id,
    required this.documentId,
    required this.documentType,
    required this.alertType,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'documentType': documentType,
      'alertType': alertType,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory ComplianceAlert.fromJson(Map<String, dynamic> json) {
    return ComplianceAlert(
      id: json['id'],
      documentId: json['documentId'],
      documentType: json['documentType'],
      alertType: json['alertType'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}

class DocumentVerificationRequest {
  final String id;
  final String riderId;
  final String documentId;
  final String documentType;
  final String? imageUrl;
  final String status; // 'pending', 'verified', 'rejected'
  final String? reviewerId;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  DocumentVerificationRequest({
    required this.id,
    required this.riderId,
    required this.documentId,
    required this.documentType,
    this.imageUrl,
    required this.status,
    this.reviewerId,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderId': riderId,
      'documentId': documentId,
      'documentType': documentType,
      'imageUrl': imageUrl,
      'status': status,
      'reviewerId': reviewerId,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory DocumentVerificationRequest.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationRequest(
      id: json['id'],
      riderId: json['riderId'],
      documentId: json['documentId'],
      documentType: json['documentType'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      reviewerId: json['reviewerId'],
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    );
  }
}

class ComplianceStatus {
  final String riderId;
  final List<Document> documents;
  final List<ComplianceAlert> alerts;
  final bool isCompliant;
  final DateTime lastChecked;
  final List<String> missingDocuments;

  ComplianceStatus({
    required this.riderId,
    required this.documents,
    required this.alerts,
    required this.isCompliant,
    required this.lastChecked,
    required this.missingDocuments,
  });

  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'documents': documents.map((d) => d.toJson()).toList(),
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'isCompliant': isCompliant,
      'lastChecked': lastChecked.toIso8601String(),
      'missingDocuments': missingDocuments,
    };
  }

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) {
    return ComplianceStatus(
      riderId: json['riderId'],
      documents: (json['documents'] as List)
          .map((d) => Document.fromJson(d))
          .toList(),
      alerts: (json['alerts'] as List)
          .map((a) => ComplianceAlert.fromJson(a))
          .toList(),
      isCompliant: json['isCompliant'],
      lastChecked: DateTime.parse(json['lastChecked']),
      missingDocuments: List<String>.from(json['missingDocuments']),
    );
  }
}