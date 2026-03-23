import 'package:flutter/material.dart';
import 'package:rider_app/controllers/order_controller.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = orderController.history;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: history.isEmpty 
        ? const Center(child: Text('No orders yet'))
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final order = history[index];
              return _buildHistoryCard(order);
            },
          ),
    );
  }

  Widget _buildHistoryCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Text(DateFormat('dd MMM, hh:mm a').format(order.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("${order.distance} KM", style: const TextStyle(fontSize: 13)),
                ],
              ),
              Text(
                "₹${order.amount.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
