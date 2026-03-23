import 'package:flutter/material.dart';
import 'package:rider_app/models/performance_metrics.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceAnalyticsService {
  static final PerformanceAnalyticsService _instance = PerformanceAnalyticsService._internal();
  factory PerformanceAnalyticsService() => _instance;
  PerformanceAnalyticsService._internal();

  // Mock data for demonstration
  RiderPerformance getCurrentPerformance() {
    return RiderPerformance(
      riderId: "rider_123",
      totalDeliveries: 45,
      averageRating: 4.7,
      totalEarnings: 2250.0,
      averageDeliveryTime: 28.5,
      distanceCovered: 180.5,
      onTimeDeliveries: 42,
      lateDeliveries: 2,
      cancelledDeliveries: 1,
      periodStart: DateTime.now().subtract(const Duration(days: 30)),
      periodEnd: DateTime.now(),
      deliveryHistory: _generateMockDeliveryHistory(),
    );
  }

  List<DeliveryMetric> _generateMockDeliveryHistory() {
    List<DeliveryMetric> history = [];
    for (int i = 0; i < 45; i++) {
      history.add(DeliveryMetric(
        orderId: "#ORD-${1000 + i}",
        deliveryTime: DateTime.now().subtract(Duration(days: i)),
        rating: 4.0 + (i % 6) * 0.2, // Ratings between 4.0-5.0
        earnings: 45.0 + (i % 10) * 5.0, // Earnings between 45-95
        distance: 3.0 + (i % 8) * 1.5, // Distance between 3-15 KM
        deliveryDuration: 20 + (i % 20), // Duration between 20-40 minutes
        isOnTime: i % 10 != 0, // 90% on-time rate
        customerName: "Customer ${i + 1}",
      ));
    }
    return history;
  }

  List<RiderPerformance> getWeeklyPerformance() {
    List<RiderPerformance> weekly = [];
    for (int i = 0; i < 4; i++) {
      weekly.add(RiderPerformance(
        riderId: "rider_123",
        totalDeliveries: 10 + (i * 2),
        averageRating: 4.5 + (i * 0.1),
        totalEarnings: 500.0 + (i * 100),
        averageDeliveryTime: 25.0 + (i * 2),
        distanceCovered: 40.0 + (i * 10),
        onTimeDeliveries: 8 + i,
        lateDeliveries: 1,
        cancelledDeliveries: i == 0 ? 1 : 0,
        periodStart: DateTime.now().subtract(Duration(days: 7 * (i + 1))),
        periodEnd: DateTime.now().subtract(Duration(days: 7 * i)),
        deliveryHistory: [],
      ));
    }
    return weekly;
  }

  List<String> getImprovementAreas(RiderPerformance performance) {
    List<String> areas = [];
    
    if (performance.onTimeRate < 90) {
      areas.add("Improve punctuality - ${performance.onTimeRate.toStringAsFixed(1)}% on-time rate");
    }
    
    if (performance.averageRating < 4.5) {
      areas.add("Focus on customer service - ${performance.averageRating.toStringAsFixed(1)} average rating");
    }
    
    if (performance.averageDeliveryTime > 30) {
      areas.add("Optimize delivery routes - ${performance.averageDeliveryTime.toStringAsFixed(1)} min average time");
    }
    
    if (performance.completionRate < 95) {
      areas.add("Reduce cancellations - ${performance.completionRate.toStringAsFixed(1)}% completion rate");
    }
    
    if (areas.isEmpty) {
      areas.add("Excellent performance! Keep up the good work.");
    }
    
    return areas;
  }

  double calculateEfficiencyScore(RiderPerformance performance) {
    double score = 0;
    
    // Rating component (30% weight)
    score += (performance.averageRating / 5.0) * 30;
    
    // On-time rate component (25% weight)
    score += (performance.onTimeRate / 100.0) * 25;
    
    // Completion rate component (20% weight)
    score += (performance.completionRate / 100.0) * 20;
    
    // Earnings component (15% weight)
    double earningsBenchmark = 2000.0; // Monthly benchmark
    score += (performance.totalEarnings / earningsBenchmark).clamp(0.0, 1.0) * 15;
    
    // Distance efficiency component (10% weight)
    double avgDistancePerDelivery = performance.distanceCovered / performance.totalDeliveries;
    double distanceEfficiency = (15.0 / avgDistancePerDelivery).clamp(0.0, 1.0); // 15KM benchmark
    score += distanceEfficiency * 10;
    
    return score.clamp(0.0, 100.0);
  }
}

class PerformanceAnalyticsScreen extends StatelessWidget {
  final PerformanceAnalyticsService _service = PerformanceAnalyticsService();
  
  @override
  Widget build(BuildContext context) {
    final performance = _service.getCurrentPerformance();
    final improvementAreas = _service.getImprovementAreas(performance);
    final efficiencyScore = _service.calculateEfficiencyScore(performance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEfficiencyCard(efficiencyScore),
            const SizedBox(height: 20),
            _buildPerformanceSummary(performance),
            const SizedBox(height: 20),
            _buildMetricsChart(performance),
            const SizedBox(height: 20),
            _buildImprovementAreas(improvementAreas),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard(double score) {
    Color scoreColor;
    String scoreText;
    
    if (score >= 80) {
      scoreColor = Colors.green;
      scoreText = "Excellent";
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreText = "Good";
    } else {
      scoreColor = Colors.red;
      scoreText = "Needs Improvement";
    }

    return Card(
      color: scoreColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              scoreText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Overall Efficiency Score',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(RiderPerformance performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildSummaryItem('Total Deliveries', performance.totalDeliveries.toString(), Icons.delivery_dining),
            _buildSummaryItem('Average Rating', performance.averageRating.toStringAsFixed(1), Icons.star),
            _buildSummaryItem('Total Earnings', '₹${performance.totalEarnings.toStringAsFixed(0)}', Icons.account_balance),
            _buildSummaryItem('On-time Rate', '${performance.onTimeRate.toStringAsFixed(1)}%', Icons.timer),
            _buildSummaryItem('Completion Rate', '${performance.completionRate.toStringAsFixed(1)}%', Icons.check_circle),
            _buildSummaryItem('Distance Covered', '${performance.distanceCovered.toStringAsFixed(1)} KM', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsChart(RiderPerformance performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const List<String> titles = ['On-time', 'Completion', 'Rating'];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: performance.onTimeRate,
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: performance.completionRate,
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: performance.averageRating * 20, // Convert 5-star to percentage
                          color: Colors.orange,
                          width: 20,
                        ),
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

  Widget _buildImprovementAreas(List<String> areas) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Improvement Areas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ...areas.map((area) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      area,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}