import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';

class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String contactType; // 'customer', 'merchant', 'support', 'emergency'
  final String? email;
  final String? address;
  final bool isFavorite;
  final DateTime lastContacted;
  final int callCount;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.contactType,
    this.email,
    this.address,
    required this.isFavorite,
    required this.lastContacted,
    required this.callCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'contactType': contactType,
      'email': email,
      'address': address,
      'isFavorite': isFavorite,
      'lastContacted': lastContacted.toIso8601String(),
      'callCount': callCount,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      contactType: json['contactType'],
      email: json['email'],
      address: json['address'],
      isFavorite: json['isFavorite'],
      lastContacted: DateTime.parse(json['lastContacted']),
      callCount: json['callCount'],
    );
  }
}

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  // Mock data for demonstration
  List<Contact> getContacts() {
    return [
      Contact(
        id: "contact_1",
        name: "Amit Sharma",
        phoneNumber: "+919876543210",
        contactType: "customer",
        email: "amit.sharma@email.com",
        address: "H.No 45, Civil Lines, Delhi",
        isFavorite: true,
        lastContacted: DateTime.now().subtract(const Duration(hours: 2)),
        callCount: 15,
      ),
      Contact(
        id: "contact_2",
        name: "Pizza Hut Sector 15",
        phoneNumber: "+911123456789",
        contactType: "merchant",
        email: "sector15@pizzahut.com",
        address: "Pizza Hut, Sector 15, Noida",
        isFavorite: true,
        lastContacted: DateTime.now().subtract(const Duration(days: 1)),
        callCount: 8,
      ),
      Contact(
        id: "contact_3",
        name: "Customer Support",
        phoneNumber: "+911800123456",
        contactType: "support",
        email: "support@deliveryapp.com",
        isFavorite: false,
        lastContacted: DateTime.now().subtract(const Duration(days: 5)),
        callCount: 3,
      ),
      Contact(
        id: "contact_4",
        name: "Emergency Services",
        phoneNumber: "+91100",
        contactType: "emergency",
        isFavorite: true,
        lastContacted: DateTime.now().subtract(const Duration(days: 30)),
        callCount: 1,
      ),
    ];
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return true;
      } else {
        throw 'Could not launch phone call';
      }
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  Future<bool> sendSms(String phoneNumber, String message) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return true;
      } else {
        throw 'Could not launch SMS';
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  Future<bool> sendEmail(String email, String subject, String body) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return true;
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  Future<bool> requestPhonePermission() async {
    // Simplified permission handling for now
    return true;
  }

  Future<bool> requestSmsPermission() async {
    // Simplified permission handling for now
    return true;
  }

  List<Contact> getFavoriteContacts() {
    return getContacts().where((contact) => contact.isFavorite).toList();
  }

  List<Contact> getRecentContacts({int limit = 10}) {
    return getContacts()
        .where((contact) => contact.lastContacted.isAfter(
            DateTime.now().subtract(const Duration(days: 30))))
        .toList()
      ..sort((a, b) => b.lastContacted.compareTo(a.lastContacted));
  }

  List<Contact> searchContacts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getContacts().where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
          contact.phoneNumber.contains(query);
    }).toList();
  }

  Future<void> addToFavorites(String contactId) async {
    // In real implementation, this would update the database
    print("Contact $contactId added to favorites");
  }

  Future<void> removeFromFavorites(String contactId) async {
    // In real implementation, this would update the database
    print("Contact $contactId removed from favorites");
  }

  Future<void> updateCallCount(String contactId) async {
    // In real implementation, this would update the database
    print("Call count updated for contact $contactId");
  }

  String getContactTypeIcon(String contactType) {
    switch (contactType) {
      case 'customer': return '👤';
      case 'merchant': return '🏪';
      case 'support': return '🎧';
      case 'emergency': return '🚨';
      default: return '📞';
    }
  }

  Color getContactTypeColor(String contactType) {
    switch (contactType) {
      case 'customer': return Colors.blue;
      case 'merchant': return Colors.green;
      case 'support': return Colors.orange;
      case 'emergency': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class ContactIntegrationScreen extends StatefulWidget {
  final String? preselectedContactId; // For direct contact calling
  
  const ContactIntegrationScreen({Key? key, this.preselectedContactId}) : super(key: key);

  @override
  _ContactIntegrationScreenState createState() => _ContactIntegrationScreenState();
}

class _ContactIntegrationScreenState extends State<ContactIntegrationScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _favoriteContacts = [];
  // This field is populated for potential UI usage; ignore unused-field lint until it is displayed.
  // ignore: unused_field
  List<Contact> _recentContacts = [];
  bool _showFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
    
    // If preselected contact is provided, make direct call
    if (widget.preselectedContactId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _makeDirectCall(widget.preselectedContactId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    _allContacts = _contactService.getContacts();
    _favoriteContacts = _contactService.getFavoriteContacts();
    _recentContacts = _contactService.getRecentContacts();
    _filteredContacts = _allContacts;
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _showFavorites ? _favoriteContacts : _allContacts;
      });
    } else {
      setState(() {
        _filteredContacts = _contactService.searchContacts(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.star : Icons.star_border),
            onPressed: _toggleFavoritesView,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFavorites && _favoriteContacts.isEmpty)
            _buildNoFavoritesMessage()
          else
            _buildContactsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNoFavoritesMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No favorite contacts',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Star your frequently contacted people',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleFavoritesView,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('View All Contacts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshContacts,
        child: ListView.builder(
          itemCount: _filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = _filteredContacts[index];
            return _buildContactItem(contact);
          },
        ),
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _contactService.getContactTypeColor(contact.contactType),
          child: Text(
            _contactService.getContactTypeIcon(contact.contactType),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phoneNumber),
            if (contact.email != null) ...[
              const SizedBox(height: 2),
              Text(
                contact.email!,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _contactService.getContactTypeColor(contact.contactType).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contact.contactType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _contactService.getContactTypeColor(contact.contactType),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (contact.isFavorite)
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                const Spacer(),
                Text(
                  'Called ${contact.callCount} times',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.orange : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(contact),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makeCall(contact),
            ),
          ],
        ),
        onTap: () => _showContactDetails(contact),
      ),
    );
  }

  Future<void> _refreshContacts() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadContacts();
    });
  }

  void _toggleFavoritesView() {
    setState(() {
      _showFavorites = !_showFavorites;
      _filteredContacts = _showFavorites ? _favoriteContacts : _allContacts;
      _searchController.clear();
    });
  }

  void _toggleFavorite(Contact contact) async {
    if (contact.isFavorite) {
      await _contactService.removeFromFavorites(contact.id);
    } else {
      await _contactService.addToFavorites(contact.id);
    }
    setState(() {
      _loadContacts();
    });
  }

  void _makeCall(Contact contact) async {
    final success = await _contactService.makePhoneCall(contact.phoneNumber);
    if (success) {
      await _contactService.updateCallCount(contact.id);
      setState(() {
        _loadContacts(); // Refresh to update call count
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _makeDirectCall(String contactId) {
    final contact = _allContacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => _allContacts.first,
    );
    _makeCall(contact);
  }

  void _showContactDetails(Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ContactDetailsSheet(
        contact: contact,
        contactService: _contactService,
        onCallMade: () {
          setState(() {
            _loadContacts();
          });
        },
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickActionsSheet(
        contactService: _contactService,
      ),
    );
  }
}

class _ContactDetailsSheet extends StatelessWidget {
  final Contact contact;
  final ContactService contactService;
  final Function() onCallMade;

  const _ContactDetailsSheet({
    Key? key,
    required this.contact,
    required this.contactService,
    required this.onCallMade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: contactService.getContactTypeColor(contact.contactType),
            child: Text(
              contactService.getContactTypeIcon(contact.contactType),
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            contact.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contact.phoneNumber,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          if (contact.email != null) ...[
            const SizedBox(height: 8),
            Text(
              contact.email!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
          if (contact.address != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(158, 158, 158, 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                contact.address!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionbutton(
                context,
                Icons.call,
                'Call',
                Colors.green,
                () => _makeCall(context),
              ),
              _buildActionbutton(
                context,
                Icons.message,
                'Message',
                Colors.blue,
                () => _sendMessage(context),
              ),
              if (contact.email != null)
                _buildActionbutton(
                  context,
                  Icons.email,
                  'Email',
                  Colors.orange,
                  () => _sendEmail(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionbutton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  void _makeCall(BuildContext context) async {
    Navigator.pop(context);
    final success = await contactService.makePhoneCall(contact.phoneNumber);
    if (success) {
      await contactService.updateCallCount(contact.id);
      onCallMade();
    }
  }

  void _sendMessage(BuildContext context) async {
    Navigator.pop(context);
    final success = await contactService.sendSms(
      contact.phoneNumber,
      'Hello ${contact.name}, I am your delivery rider.',
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendEmail(BuildContext context) async {
    Navigator.pop(context);
    if (contact.email != null) {
      final success = await contactService.sendEmail(
        contact.email!,
        'Delivery Update',
        'Hello ${contact.name},\n\nThis is regarding your recent order delivery.',
      );
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to send email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final ContactService contactService;

  const _QuickActionsSheet({Key? key, required this.contactService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                context,
                Icons.support_agent,
                'Support',
                Colors.orange,
                _callSupport,
              ),
              _buildQuickActionButton(
                context,
                Icons.emergency,
                'Emergency',
                Colors.red,
                _callEmergency,
              ),
              _buildQuickActionButton(
                context,
                Icons.local_police,
                'Police',
                Colors.blue,
                _callPolice,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: color),
          onPressed: () {
            Navigator.pop(context);
            onPressed();
          },
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  void _callSupport() async {
    await contactService.makePhoneCall("+911800123456");
  }

  void _callEmergency() async {
    await contactService.makePhoneCall("+91100");
  }

  void _callPolice() async {
    await contactService.makePhoneCall("+91100");
  }
}

// Quick dial widget for use in other screens
class QuickDialWidget extends StatelessWidget {
  final String phoneNumber;
  final String name;
  final String contactType;

  const QuickDialWidget({
    Key? key,
    required this.phoneNumber,
    required this.name,
    required this.contactType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contactService = ContactService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: contactService.getContactTypeColor(contactType),
              child: Text(
                contactService.getContactTypeIcon(contactType),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makeQuickCall(context, contactService),
            ),
          ],
        ),
      ),
    );
  }

  void _makeQuickCall(BuildContext context, ContactService contactService) async {
    final success = await contactService.makePhoneCall(phoneNumber);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}