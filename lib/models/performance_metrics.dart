class RiderPerformance {
  final String riderId;
  final int totalDeliveries;
  final double averageRating;
  final double totalEarnings;
  final double averageDeliveryTime; // in minutes
  final double distanceCovered; // in KM
  final int onTimeDeliveries;
  final int lateDeliveries;
  final int cancelledDeliveries;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<DeliveryMetric> deliveryHistory;

  RiderPerformance({
    required this.riderId,
    required this.totalDeliveries,
    required this.averageRating,
    required this.totalEarnings,
    required this.averageDeliveryTime,
    required this.distanceCovered,
    required this.onTimeDeliveries,
    required this.lateDeliveries,
    required this.cancelledDeliveries,
    required this.periodStart,
    required this.periodEnd,
    required this.deliveryHistory,
  });

  double get onTimeRate => 
      totalDeliveries > 0 ? (onTimeDeliveries / totalDeliveries) * 100 : 0;

  double get completionRate => 
      totalDeliveries > 0 ? 
      ((totalDeliveries - cancelledDeliveries) / totalDeliveries) * 100 : 0;

  double get earningsPerHour => 
      averageDeliveryTime > 0 ? (totalEarnings / (averageDeliveryTime * totalDeliveries / 60)) : 0;

  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'totalDeliveries': totalDeliveries,
      'averageRating': averageRating,
      'totalEarnings': totalEarnings,
      'averageDeliveryTime': averageDeliveryTime,
      'distanceCovered': distanceCovered,
      'onTimeDeliveries': onTimeDeliveries,
      'lateDeliveries': lateDeliveries,
      'cancelledDeliveries': cancelledDeliveries,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'deliveryHistory': deliveryHistory.map((d) => d.toJson()).toList(),
    };
  }

  factory RiderPerformance.fromJson(Map<String, dynamic> json) {
    return RiderPerformance(
      riderId: json['riderId'],
      totalDeliveries: json['totalDeliveries'],
      averageRating: json['averageRating'].toDouble(),
      totalEarnings: json['totalEarnings'].toDouble(),
      averageDeliveryTime: json['averageDeliveryTime'].toDouble(),
      distanceCovered: json['distanceCovered'].toDouble(),
      onTimeDeliveries: json['onTimeDeliveries'],
      lateDeliveries: json['lateDeliveries'],
      cancelledDeliveries: json['cancelledDeliveries'],
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      deliveryHistory: (json['deliveryHistory'] as List)
          .map((d) => DeliveryMetric.fromJson(d))
          .toList(),
    );
  }
}

class DeliveryMetric {
  final String orderId;
  final DateTime deliveryTime;
  final double rating;
  final double earnings;
  final double distance;
  final int deliveryDuration; // in minutes
  final bool isOnTime;
  final String customerName;

  DeliveryMetric({
    required this.orderId,
    required this.deliveryTime,
    required this.rating,
    required this.earnings,
    required this.distance,
    required this.deliveryDuration,
    required this.isOnTime,
    required this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'deliveryTime': deliveryTime.toIso8601String(),
      'rating': rating,
      'earnings': earnings,
      'distance': distance,
      'deliveryDuration': deliveryDuration,
      'isOnTime': isOnTime,
      'customerName': customerName,
    };
  }

  factory DeliveryMetric.fromJson(Map<String, dynamic> json) {
    return DeliveryMetric(
      orderId: json['orderId'],
      deliveryTime: DateTime.parse(json['deliveryTime']),
      rating: json['rating'].toDouble(),
      earnings: json['earnings'].toDouble(),
      distance: json['distance'].toDouble(),
      deliveryDuration: json['deliveryDuration'],
      isOnTime: json['isOnTime'],
      customerName: json['customerName'],
    );
  }
}

class PerformanceSummary {
  final List<RiderPerformance> weeklyPerformance;
  final List<RiderPerformance> monthlyPerformance;
  final RiderPerformance currentPeriod;
  final List<String> improvementAreas;

  PerformanceSummary({
    required this.weeklyPerformance,
    required this.monthlyPerformance,
    required this.currentPeriod,
    required this.improvementAreas,
  });

  Map<String, dynamic> toJson() {
    return {
      'weeklyPerformance': weeklyPerformance.map((p) => p.toJson()).toList(),
      'monthlyPerformance': monthlyPerformance.map((p) => p.toJson()).toList(),
      'currentPeriod': currentPeriod.toJson(),
      'improvementAreas': improvementAreas,
    };
  }

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      weeklyPerformance: (json['weeklyPerformance'] as List)
          .map((p) => RiderPerformance.fromJson(p))
          .toList(),
      monthlyPerformance: (json['monthlyPerformance'] as List)
          .map((p) => RiderPerformance.fromJson(p))
          .toList(),
      currentPeriod: RiderPerformance.fromJson(json['currentPeriod']),
      improvementAreas: List<String>.from(json['improvementAreas']),
    );
  }
}