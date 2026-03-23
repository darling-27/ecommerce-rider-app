class PricingConfig {
  final double baseFare; // Minimum fare
  final double perKmRate; // Rate per kilometer
  final double perMinuteRate; // Rate per minute for delays
  final double bookingFee; // Fixed booking fee
  final double serviceFeePercentage; // Percentage of total fare
  final double peakMultiplier; // Multiplier during peak hours
  final double nightSurcharge; // Additional charge for night deliveries
  final double heavyItemSurcharge; // For heavy/bulky items
  final double rushHourStart; // 24-hour format (e.g., 18.0 for 6 PM)
  final double rushHourEnd; // 24-hour format (e.g., 22.0 for 10 PM)
  final double nightStart; // Night time start (e.g., 22.0 for 10 PM)
  final double nightEnd; // Night time end (e.g., 6.0 for 6 AM)

  PricingConfig({
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    required this.bookingFee,
    required this.serviceFeePercentage,
    required this.peakMultiplier,
    required this.nightSurcharge,
    required this.heavyItemSurcharge,
    required this.rushHourStart,
    required this.rushHourEnd,
    required this.nightStart,
    required this.nightEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseFare': baseFare,
      'perKmRate': perKmRate,
      'perMinuteRate': perMinuteRate,
      'bookingFee': bookingFee,
      'serviceFeePercentage': serviceFeePercentage,
      'peakMultiplier': peakMultiplier,
      'nightSurcharge': nightSurcharge,
      'heavyItemSurcharge': heavyItemSurcharge,
      'rushHourStart': rushHourStart,
      'rushHourEnd': rushHourEnd,
      'nightStart': nightStart,
      'nightEnd': nightEnd,
    };
  }

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      baseFare: json['baseFare'].toDouble(),
      perKmRate: json['perKmRate'].toDouble(),
      perMinuteRate: json['perMinuteRate'].toDouble(),
      bookingFee: json['bookingFee'].toDouble(),
      serviceFeePercentage: json['serviceFeePercentage'].toDouble(),
      peakMultiplier: json['peakMultiplier'].toDouble(),
      nightSurcharge: json['nightSurcharge'].toDouble(),
      heavyItemSurcharge: json['heavyItemSurcharge'].toDouble(),
      rushHourStart: json['rushHourStart'].toDouble(),
      rushHourEnd: json['rushHourEnd'].toDouble(),
      nightStart: json['nightStart'].toDouble(),
      nightEnd: json['nightEnd'].toDouble(),
    );
  }
}

class DeliveryQuote {
  final double distance; // in kilometers
  final int estimatedTime; // in minutes
  final DateTime deliveryTime;
  final bool isPeakHour;
  final bool isNightDelivery;
  final bool hasHeavyItems;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double bookingFee;
  final double peakSurcharge;
  final double nightSurcharge;
  final double heavyItemSurcharge;
  final double serviceFee;
  final double totalFare;
  final double riderEarnings;

  DeliveryQuote({
    required this.distance,
    required this.estimatedTime,
    required this.deliveryTime,
    required this.isPeakHour,
    required this.isNightDelivery,
    required this.hasHeavyItems,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.bookingFee,
    required this.peakSurcharge,
    required this.nightSurcharge,
    required this.heavyItemSurcharge,
    required this.serviceFee,
    required this.totalFare,
    required this.riderEarnings,
  });

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'estimatedTime': estimatedTime,
      'deliveryTime': deliveryTime.toIso8601String(),
      'isPeakHour': isPeakHour,
      'isNightDelivery': isNightDelivery,
      'hasHeavyItems': hasHeavyItems,
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'timeFare': timeFare,
      'bookingFee': bookingFee,
      'peakSurcharge': peakSurcharge,
      'nightSurcharge': nightSurcharge,
      'heavyItemSurcharge': heavyItemSurcharge,
      'serviceFee': serviceFee,
      'totalFare': totalFare,
      'riderEarnings': riderEarnings,
    };
  }

  factory DeliveryQuote.fromJson(Map<String, dynamic> json) {
    return DeliveryQuote(
      distance: json['distance'].toDouble(),
      estimatedTime: json['estimatedTime'],
      deliveryTime: DateTime.parse(json['deliveryTime']),
      isPeakHour: json['isPeakHour'],
      isNightDelivery: json['isNightDelivery'],
      hasHeavyItems: json['hasHeavyItems'],
      baseFare: json['baseFare'].toDouble(),
      distanceFare: json['distanceFare'].toDouble(),
      timeFare: json['timeFare'].toDouble(),
      bookingFee: json['bookingFee'].toDouble(),
      peakSurcharge: json['peakSurcharge'].toDouble(),
      nightSurcharge: json['nightSurcharge'].toDouble(),
      heavyItemSurcharge: json['heavyItemSurcharge'].toDouble(),
      serviceFee: json['serviceFee'].toDouble(),
      totalFare: json['totalFare'].toDouble(),
      riderEarnings: json['riderEarnings'].toDouble(),
    );
  }
}