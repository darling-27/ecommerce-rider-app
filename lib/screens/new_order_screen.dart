import 'package:flutter/material.dart';
import 'package:rider_app/controllers/order_controller.dart';
import 'package:rider_app/screens/map_navigation_screen.dart';
import 'dart:async';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  int _secondsLeft = 30;
  Timer? _timer;

  final Order mockOrder = Order(
    id: "#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
    customerName: "Rahul Verma",
    pickupAddress: "KFC, City Center Mall",
    deliveryAddress: "Flat 405, Green Valley Society",
    distance: 5.4,
    amount: 54.0, // ₹10 per KM
    date: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        if (mounted) setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _acceptOrder() {
    _timer?.cancel();
    orderController.acceptOrder(mockOrder);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MapNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Order Request'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "₹${mockOrder.amount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Text("Estimated Earnings", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildInfoCard(),
            const Spacer(),
            Text("Request expires in $_secondsLeft seconds", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('REJECT'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildLocationRow(Icons.store, "Pickup", mockOrder.pickupAddress, Colors.blue),
          const Divider(height: 30),
          _buildLocationRow(Icons.location_on, "Delivery", mockOrder.deliveryAddress, Colors.red),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Distance", style: TextStyle(color: Colors.grey)),
              Text("${mockOrder.distance} KM", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String address, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
