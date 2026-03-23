import 'package:flutter/material.dart';
import 'package:rider_app/models/pricing_system.dart';
import 'package:rider_app/services/pricing_service.dart';

class PricingCalculatorScreen extends StatefulWidget {
  final double distance;
  final int estimatedTime;
  
  const PricingCalculatorScreen({
    super.key,
    required this.distance,
    required this.estimatedTime,
  });

  @override
  State<PricingCalculatorScreen> createState() => _PricingCalculatorScreenState();
}

class _PricingCalculatorScreenState extends State<PricingCalculatorScreen> {
  final PricingService _pricingService = PricingService();
  late DeliveryQuote _quote;
  bool _hasHeavyItems = false;
  DateTime _deliveryTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calculateQuote();
  }

  void _calculateQuote() {
    setState(() {
      _quote = _pricingService.calculateDeliveryQuote(
        distance: widget.distance,
        estimatedTime: widget.estimatedTime,
        deliveryTime: _deliveryTime,
        hasHeavyItems: _hasHeavyItems,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Quote'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryInfo(),
            const SizedBox(height: 20),
            _buildQuoteSummary(),
            const SizedBox(height: 20),
            _buildFareBreakdown(),
            const SizedBox(height: 20),
            _buildOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoRow('Distance', '${widget.distance.toStringAsFixed(1)} km'),
            _buildInfoRow('Estimated Time', '${widget.estimatedTime} minutes'),
            _buildInfoRow('Delivery Time', _formatTime(_deliveryTime)),
            if (_quote.isPeakHour)
              _buildInfoRow('Peak Hour', 'Yes', color: Colors.orange),
            if (_quote.isNightDelivery)
              _buildInfoRow('Night Delivery', 'Yes', color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSummary() {
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Total Fare',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '₹${_quote.totalFare.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rider Earnings: ₹${_quote.riderEarnings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdown() {
    final breakdown = _pricingService.getFareBreakdown(_quote);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fare Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ...breakdown.map((item) => _buildBreakdownItem(item)),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${_quote.totalFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item['amount'].toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text('Heavy/Bulky Items'),
              subtitle: const Text('₹30 surcharge for heavy items'),
              value: _hasHeavyItems,
              onChanged: (value) {
                setState(() {
                  _hasHeavyItems = value;
                  _calculateQuote();
                });
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Delivery Time'),
              subtitle: Text(_formatTime(_deliveryTime)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectDeliveryTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDeliveryTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deliveryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deliveryTime),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        setState(() {
          _deliveryTime = newDateTime;
          _calculateQuote();
        });
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
