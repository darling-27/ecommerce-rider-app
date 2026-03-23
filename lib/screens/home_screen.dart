import 'package:flutter/material.dart';
import 'package:rider_app/screens/new_order_screen.dart';
import 'package:rider_app/screens/order_history_screen.dart';
import 'package:rider_app/screens/profile_screen.dart';
import 'package:rider_app/screens/earnings_screen.dart';
import 'package:rider_app/screens/help_support_screen.dart';
import 'package:rider_app/controllers/user_controller.dart';
import 'package:rider_app/controllers/order_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrderHistoryScreen(),
    const EarningsScreen(),
    const ProfileScreen(),
    const HelpSupportScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool _isOnline = false;
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _headerController.forward();
    
    userController.addListener(() {
      if (mounted) setState(() {});
    });
    orderController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  void _navigateToNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewOrderScreen()),
    );
  }

  void _goToProfile() {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState._onTabTapped(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _goToProfile,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: userController.profilePic != null ? FileImage(userController.profilePic!) : null,
                              child: userController.profilePic == null ? const Icon(Icons.person, color: Colors.black) : null,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userController.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Switch(
                                value: _isOnline,
                                onChanged: (value) => _toggleOnlineStatus(),
                                activeColor: Colors.white,
                                activeTrackColor: Colors.grey[800],
                                inactiveThumbColor: Colors.grey[400],
                                inactiveTrackColor: Colors.grey[900],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isOnline ? "YOU ARE ONLINE" : "YOU ARE OFFLINE",
                        style: TextStyle(
                          color: _isOnline ? Colors.white : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!_isOnline)
                      _buildStatusBanner()
                    else
                      Column(
                        children: [
                          _buildEarningsCard(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.power_settings_new, size: 40, color: Colors.black),
          const SizedBox(height: 16),
          const Text(
            'GO ONLINE TO START',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text(
            'You will receive delivery requests once online',
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'ACCOUNT BALANCE',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            '₹${userController.currentBalance.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(orderController.history.length.toString(), 'ORDERS'),
              Container(width: 1, height: 30, color: Colors.black12),
              _buildStatItem('${orderController.totalDistance.toStringAsFixed(1)}', 'KM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ACTIONS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _navigateToNewOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
          child: const Text('SEARCH NEW ORDERS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black, width: 2),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
          child: const Text('EMERGENCY SUPPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ],
    );
  }
}
