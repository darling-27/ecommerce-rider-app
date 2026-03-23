import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_app/controllers/order_controller.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  late GoogleMapController mapController;

  final LatLng _pickup = const LatLng(28.6139, 77.2090); // Delhi mock
  final LatLng _delivery = const LatLng(28.6250, 77.2200);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _markAsDelivered() {
    orderController.completeOrder();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Delivered Successfully!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final order = orderController.currentOrder;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _pickup, zoom: 14.0),
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: _pickup, infoWindow: const InfoWindow(title: 'Pickup')),
              Marker(markerId: const MarkerId('delivery'), position: _delivery, infoWindow: const InfoWindow(title: 'Delivery')),
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildOrderDetailsOverlay(order),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsOverlay(Order? order) {
    if (order == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Text('Cash on Delivery', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Text("₹${order.amount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _markAsDelivered,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('MARK AS DELIVERED', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
