import 'package:flutter/material.dart';
import 'package:rider_app/services/fcm_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Order Available',
      'message': 'There is a new order near you. Tap to view details.',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
      'time': '2 min ago',
      'type': 'new_order',
      'isUnread': true,
    },
    {
      'id': '2',
      'title': 'Order Accepted',
      'message': 'Your order #ORD-2023-001 has been accepted.',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'time': '5 min ago',
      'type': 'order_update',
      'isUnread': true,
    },
    {
      'id': '3',
      'title': 'Order Completed',
      'message': 'Order #ORD-2023-002 has been completed successfully.',
      'icon': Icons.done_all,
      'color': Colors.orange,
      'time': '15 min ago',
      'type': 'order_update',
      'isUnread': false,
    },
    {
      'id': '4',
      'title': 'Payment Received',
      'message': '\$60.00 has been credited to your account.',
      'icon': Icons.attach_money,
      'color': Colors.purple,
      'time': '1 hour ago',
      'type': 'payment',
      'isUnread': false,
    },
    {
      'id': '5',
      'title': 'System Update',
      'message': 'New app version available. Update now for better experience.',
      'icon': Icons.update,
      'color': Colors.teal,
      'time': '2 hours ago',
      'type': 'system',
      'isUnread': false,
    },
    {
      'id': '6',
      'title': 'Promotion',
      'message': 'Earn extra \$10 for every 5 orders completed this week.',
      'icon': Icons.card_giftcard,
      'color': Colors.red,
      'time': '1 day ago',
      'type': 'promotion',
      'isUnread': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _controller.forward();
    
    // Subscribe to relevant topics
    _subscribeToTopics();
  }

  void _subscribeToTopics() {
    FCMService.subscribeToTopic('rider_notifications');
    FCMService.subscribeToTopic('new_orders');
    FCMService.subscribeToTopic('payments');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearAllNotifications() {
    setState(() {
      for (var notification in _notifications) {
        notification['isUnread'] = false;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testNotification() {
    // Simulate receiving a new notification
    setState(() {
      _notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Test Notification',
        'message': 'This is a test notification from FCM',
        'icon': Icons.notifications,
        'color': Colors.blue,
        'time': 'Just now',
        'type': 'test',
        'isUnread': true,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _testNotification,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.black),
            onPressed: _clearAllNotifications,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFilterChip('All', true),
                      _buildFilterChip('Unread', false),
                      _buildFilterChip('Promotions', false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(_notifications[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'ll see notifications here when they arrive',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: _testNotification,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Test Notification',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.black,
      onSelected: (selected) {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.black : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = notification['isUnread'];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isUnread ? Colors.blue[100]! : Colors.grey[200]!,
          width: isUnread ? 1 : 0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification['color']![300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color']![700],
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (notification['type'] == 'new_order')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ACTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}