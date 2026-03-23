import 'package:flutter/material.dart';

class Order {
  final String id;
  final String customerName;
  final String pickupAddress;
  final String deliveryAddress;
  final double distance; // in KM
  final double amount;
  final DateTime date;
  bool isCompleted;

  Order({
    required this.id,
    required this.customerName,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.amount,
    required this.date,
    this.isCompleted = false,
  });
}

class OrderController extends ChangeNotifier {
  List<Order> history = [
    Order(
      id: "#ORD-101",
      customerName: "Amit Sharma",
      pickupAddress: "Pizza Hut, Sector 15",
      deliveryAddress: "H.No 45, Civil Lines",
      distance: 4.5,
      amount: 45.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: true,
    ),
    Order(
      id: "#ORD-102",
      customerName: "Suresh Kumar",
      pickupAddress: "Burger King, Mall Road",
      deliveryAddress: "Flat 202, Heights Apartment",
      distance: 8.2,
      amount: 82.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: true,
    ),
  ];

  Order? currentOrder;

  double get totalEarnings {
    return history.fold(0, (sum, item) => sum + item.amount);
  }

  double get totalDistance {
    return history.fold(0, (sum, item) => sum + item.distance);
  }

  void acceptOrder(Order order) {
    currentOrder = order;
    notifyListeners();
  }

  void completeOrder() {
    if (currentOrder != null) {
      currentOrder!.isCompleted = true;
      history.insert(0, currentOrder!);
      currentOrder = null;
      notifyListeners();
    }
  }
}

final orderController = OrderController();
