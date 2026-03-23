import 'package:flutter/material.dart';
import 'package:rider_app/models/document_compliance.dart';

class DocumentComplianceService {
  static final DocumentComplianceService _instance = DocumentComplianceService._internal();
  factory DocumentComplianceService() => _instance;
  DocumentComplianceService._internal();

  // Mock data for demonstration
  List<Document> getRiderDocuments(String riderId) {
    return [
      Document(
        id: "doc_1",
        name: "Aadhaar Card",
        type: "aadhaar",
        documentNumber: "1234-5678-9012",
        issueDate: DateTime(2020, 1, 15),
        expiryDate: DateTime(2030, 1, 15),
        status: "verified",
        imageUrl: "https://example.com/aadhaar.jpg",
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Document(
        id: "doc_2",
        name: "PAN Card",
        type: "pan",
        documentNumber: "ABCDE1234F",
        issueDate: DateTime(2019, 5, 20),
        expiryDate: DateTime(2040, 5, 20),
        status: "verified",
        imageUrl: "https://example.com/pan.jpg",
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Document(
        id: "doc_3",
        name: "Driving License",
        type: "license",
        documentNumber: "DL-1234567890",
        issueDate: DateTime(2023, 3, 10),
        expiryDate: DateTime(2026, 3, 10), // Expiring soon
        status: "verified",
        imageUrl: "https://example.com/license.jpg",
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Document(
        id: "doc_4",
        name: "Vehicle Registration",
        type: "vehicle_rc",
        documentNumber: "HR-26-DL-1234",
        issueDate: DateTime(2022, 8, 5),
        expiryDate: DateTime(2023, 8, 5), // Expired
        status: "expired",
        imageUrl: "https://example.com/rc.jpg",
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];
  }

  ComplianceStatus getComplianceStatus(String riderId) {
    final documents = getRiderDocuments(riderId);
    final alerts = _generateComplianceAlerts(documents);
    final missingDocs = _checkMissingDocuments(documents);
    final isCompliant = _checkCompliance(documents);

    return ComplianceStatus(
      riderId: riderId,
      documents: documents,
      alerts: alerts,
      isCompliant: isCompliant,
      lastChecked: DateTime.now(),
      missingDocuments: missingDocs,
    );
  }

  List<ComplianceAlert> _generateComplianceAlerts(List<Document> documents) {
    List<ComplianceAlert> alerts = [];

    for (var doc in documents) {
      if (doc.isExpired) {
        alerts.add(ComplianceAlert(
          id: "alert_${doc.id}_expired",
          documentId: doc.id,
          documentType: doc.type,
          alertType: "expired",
          message: "${doc.name} has expired. Please renew immediately.",
          createdAt: DateTime.now(),
          isRead: false,
        ));
      } else if (doc.isExpiringSoon) {
        alerts.add(ComplianceAlert(
          id: "alert_${doc.id}_expiring",
          documentId: doc.id,
          documentType: doc.type,
          alertType: "expiry_warning",
          message: "${doc.name} expires in ${doc.daysUntilExpiry} days. Please renew soon.",
          createdAt: DateTime.now(),
          isRead: false,
        ));
      }
    }

    // Check for rejected documents
    final rejectedDocs = documents.where((doc) => doc.status == "rejected").toList();
    for (var doc in rejectedDocs) {
      alerts.add(ComplianceAlert(
        id: "alert_${doc.id}_rejected",
        documentId: doc.id,
        documentType: doc.type,
        alertType: "verification_required",
        message: "${doc.name} verification was rejected. Please re-upload.",
        createdAt: DateTime.now(),
        isRead: false,
      ));
    }

    return alerts;
  }

  List<String> _checkMissingDocuments(List<Document> documents) {
    final requiredDocuments = ['aadhaar', 'pan', 'license', 'vehicle_rc'];
    final existingTypes = documents.map((doc) => doc.type).toSet();
    return requiredDocuments.where((type) => !existingTypes.contains(type)).toList();
  }

  bool _checkCompliance(List<Document> documents) {
    // Check if all required documents exist and are valid
    final requiredDocuments = ['aadhaar', 'pan', 'license', 'vehicle_rc'];
    final existingTypes = documents.map((doc) => doc.type).toSet();
    
    // Check if all required documents are present
    if (!requiredDocuments.every((type) => existingTypes.contains(type))) {
      return false;
    }
    
    // Check if any document is expired
    if (documents.any((doc) => doc.isExpired)) {
      return false;
    }
    
    // Check if any document is rejected
    if (documents.any((doc) => doc.status == "rejected")) {
      return false;
    }
    
    return true;
  }

  Future<void> markAlertAsRead(String alertId) async {
    // In real implementation, this would update the alert in database
    print("Alert $alertId marked as read");
  }

  Future<void> renewDocument(String documentId, DateTime newExpiryDate) async {
    // In real implementation, this would update the document in database
    print("Document $documentId renewed with new expiry: $newExpiryDate");
  }

  List<Document> getExpiringDocuments(String riderId, {int days = 30}) {
    final documents = getRiderDocuments(riderId);
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return documents.where((doc) => 
      doc.expiryDate.isAfter(DateTime.now()) && 
      doc.expiryDate.isBefore(cutoffDate)
    ).toList();
  }

  List<Document> getExpiredDocuments(String riderId) {
    final documents = getRiderDocuments(riderId);
    return documents.where((doc) => doc.isExpired).toList();
  }
}

class DocumentComplianceScreen extends StatefulWidget {
  const DocumentComplianceScreen({Key? key}) : super(key: key);

  @override
  DocumentComplianceScreenState createState() => DocumentComplianceScreenState();
}

class DocumentComplianceScreenState extends State<DocumentComplianceScreen> {
   final DocumentComplianceService _complianceService = DocumentComplianceService();
   late ComplianceStatus _complianceStatus;

   @override
   void initState() {
     super.initState();
     _complianceStatus = _complianceService.getComplianceStatus("rider_123");
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Document Compliance'),
         backgroundColor: Colors.black,
         foregroundColor: Colors.white,
       ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildComplianceStatusCard(),
             const SizedBox(height: 20),
             _buildAlertsSection(),
             const SizedBox(height: 20),
             _buildDocumentsList(),
             const SizedBox(height: 20),
             _buildMissingDocumentsSection(),
           ],
         ),
       ),
     );
   }

   Widget _buildComplianceStatusCard() {
     final isCompliant = _complianceStatus.isCompliant;
     // Inline values to avoid unused-variable lint and keep code concise
     final statusColor = isCompliant ? Colors.green : Colors.red;
     final statusText = isCompliant ? 'Compliant' : 'Non-Compliant';

     return Card(
      color: statusColor == Colors.green ? const Color.fromRGBO(76, 175, 80, 0.1) : const Color.fromRGBO(244, 67, 54, 0.1),
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Row(
           children: [
             Icon(isCompliant ? Icons.check_circle : Icons.error, size: 40, color: statusColor),
             const SizedBox(width: 15),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   statusText,
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                     color: statusColor,
                   ),
                 ),
                 const SizedBox(height: 5),
                 const Text(
                   'Your document compliance status',
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.black54,
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildAlertsSection() {
     final alerts = _complianceStatus.alerts;

    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.check_circle, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              const Text(
                'No compliance alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'All your documents are up to date',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...alerts.map((alert) => _buildAlertItem(alert)).toList(),
          ],
        ),
      ),
    );
   }

   Widget _buildAlertItem(ComplianceAlert alert) {
     IconData icon;
     Color color;

     switch (alert.alertType) {
       case "expired":
         icon = Icons.error;
         color = Colors.red;
         break;
       case "expiry_warning":
         icon = Icons.warning;
         color = Colors.orange;
         break;
       case "verification_required":
         icon = Icons.report;
         color = Colors.blue;
         break;
       default:
         icon = Icons.info;
         color = Colors.grey;
     }

     return Container(
       margin: const EdgeInsets.symmetric(vertical: 4),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha((0.05 * 255).round()),
       ),
       child: Row(
         children: [
           Icon(icon, size: 20, color: color),
           const SizedBox(width: 12),
           Expanded(
             child: Text(
               alert.message,
               style: const TextStyle(fontSize: 14),
             ),
           ),
           if (!alert.isRead)
             Container(
               width: 8,
               height: 8,
               decoration: const BoxDecoration(
                 color: Colors.red,
                 shape: BoxShape.circle,
               ),
             ),
         ],
       ),
     );
   }

   Widget _buildDocumentsList() {
    final documents = _complianceStatus.documents;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
          ],
        ),
      ),
    );
   }

   Widget _buildDocumentItem(Document document) {
    Color statusColor;
    IconData statusIcon;
    
    switch (document.status) {
      case "verified":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case "rejected":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case "expired":
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(158, 158, 158, 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 20, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  document.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  document.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Number: ${document.documentNumber}'),
          Text('Expiry: ${document.expiryDate.toString().split(' ')[0]}'),
          if (document.isExpiringSoon)
            Text(
              'Expires in ${document.daysUntilExpiry} days',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          if (document.isExpired)
            const Text(
              'EXPIRED',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
   }

   Widget _buildMissingDocumentsSection() {
    final missingDocs = _complianceStatus.missingDocuments;
    
    if (missingDocs.isEmpty) return const SizedBox.shrink();

    return Card(
      color: const Color.fromRGBO(244, 67, 54, 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Missing Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ...missingDocs.map((docType) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.error, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    _getDocumentName(docType),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Navigate to document upload screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload Missing Documents'),
            ),
          ],
        ),
      ),
    );
   }

   String _getDocumentName(String docType) {
    switch (docType) {
      case 'aadhaar': return 'Aadhaar Card';
      case 'pan': return 'PAN Card';
      case 'license': return 'Driving License';
      case 'vehicle_rc': return 'Vehicle Registration Certificate';
      case 'vehicle_insurance': return 'Vehicle Insurance';
      default: return docType;
    }
  }
}