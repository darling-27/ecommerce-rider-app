import 'package:rider_app/models/pricing_system.dart';

class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  // Default pricing configuration
  PricingConfig getDefaultConfig() {
    return PricingConfig(
      // Simplified pricing: ₹10 per km only, no base/min fare, no booking/service/peak/extra fees
      baseFare: 0.0,
      perKmRate: 10.0, // ₹10 per kilometer
      perMinuteRate: 0.0, // not used
      bookingFee: 0.0,
      serviceFeePercentage: 0.0,
      peakMultiplier: 1.0,
      nightSurcharge: 10.0, // Flat ₹10 per order during night
      heavyItemSurcharge: 0.0,
      rushHourStart: 24.0, // disabled
      rushHourEnd: 24.0, // disabled
      nightStart: 22.0, // 10 PM
      nightEnd: 6.0, // 6 AM
    );
  }

  DeliveryQuote calculateDeliveryQuote({
    required double distance,
    required int estimatedTime,
    required DateTime deliveryTime,
    bool hasHeavyItems = false,
    PricingConfig? config,
  }) {
    config ??= getDefaultConfig();
    
    final isPeakHour = _isPeakHour(deliveryTime, config);
    final isNightDelivery = _isNightDelivery(deliveryTime, config);
    
    // Calculate base components
    final baseFare = config.baseFare;
    final distanceFare = distance * config.perKmRate;
    final timeFare = estimatedTime * config.perMinuteRate;
    final bookingFee = config.bookingFee;
    
    // Calculate surcharges
    final peakSurcharge = isPeakHour ? (baseFare + distanceFare) * (config.peakMultiplier - 1) : 0.0;
    final nightSurcharge = isNightDelivery ? config.nightSurcharge : 0.0;
    final heavyItemSurcharge = hasHeavyItems ? config.heavyItemSurcharge : 0.0;
    
    // Calculate subtotal
    final subtotal = baseFare + distanceFare + timeFare + bookingFee + 
                   peakSurcharge + nightSurcharge + heavyItemSurcharge;
    
    // Calculate service fee
    final serviceFee = (subtotal * config.serviceFeePercentage) / 100;
    
    // Calculate total fare
    final totalFare = subtotal + serviceFee;
    
    // Calculate rider earnings (total fare minus service fee)
    final riderEarnings = totalFare - serviceFee;
    
    return DeliveryQuote(
      distance: distance,
      estimatedTime: estimatedTime,
      deliveryTime: deliveryTime,
      isPeakHour: isPeakHour,
      isNightDelivery: isNightDelivery,
      hasHeavyItems: hasHeavyItems,
      baseFare: baseFare,
      distanceFare: distanceFare,
      timeFare: timeFare,
      bookingFee: bookingFee,
      peakSurcharge: peakSurcharge,
      nightSurcharge: nightSurcharge,
      heavyItemSurcharge: heavyItemSurcharge,
      serviceFee: serviceFee,
      totalFare: totalFare,
      riderEarnings: riderEarnings,
    );
  }

  bool _isPeakHour(DateTime time, PricingConfig config) {
    final hour = time.hour + (time.minute / 60);
    return hour >= config.rushHourStart && hour <= config.rushHourEnd;
  }

  bool _isNightDelivery(DateTime time, PricingConfig config) {
    final hour = time.hour + (time.minute / 60);
    return hour >= config.nightStart || hour <= config.nightEnd;
  }

  // Dynamic pricing based on demand
  double calculateDynamicMultiplier({
    required int currentActiveRiders,
    required int pendingOrders,
    required double baseMultiplier,
  }) {
    if (currentActiveRiders == 0) return baseMultiplier * 3.0; // High demand
    
    final ratio = pendingOrders / currentActiveRiders;
    
    if (ratio > 2.0) return baseMultiplier * 2.0; // Very high demand
    if (ratio > 1.5) return baseMultiplier * 1.5; // High demand
    if (ratio > 1.0) return baseMultiplier * 1.2; // Moderate demand
    if (ratio < 0.5) return baseMultiplier * 0.8; // Low demand
    
    return baseMultiplier; // Normal demand
  }

  // Surge pricing calculation
  DeliveryQuote calculateSurgePricing({
    required DeliveryQuote baseQuote,
    required double surgeMultiplier,
  }) {
    return DeliveryQuote(
      distance: baseQuote.distance,
      estimatedTime: baseQuote.estimatedTime,
      deliveryTime: baseQuote.deliveryTime,
      isPeakHour: baseQuote.isPeakHour,
      isNightDelivery: baseQuote.isNightDelivery,
      hasHeavyItems: baseQuote.hasHeavyItems,
      baseFare: baseQuote.baseFare * surgeMultiplier,
      distanceFare: baseQuote.distanceFare * surgeMultiplier,
      timeFare: baseQuote.timeFare * surgeMultiplier,
      bookingFee: baseQuote.bookingFee,
      peakSurcharge: baseQuote.peakSurcharge * surgeMultiplier,
      nightSurcharge: baseQuote.nightSurcharge,
      heavyItemSurcharge: baseQuote.heavyItemSurcharge,
      serviceFee: baseQuote.serviceFee * surgeMultiplier,
      totalFare: baseQuote.totalFare * surgeMultiplier,
      riderEarnings: baseQuote.riderEarnings * surgeMultiplier,
    );
  }

  // Get pricing breakdown for display
  List<Map<String, dynamic>> getFareBreakdown(DeliveryQuote quote) {
    final breakdown = <Map<String, dynamic>>[];
    
    breakdown.add({
      'label': 'Base Fare',
      'amount': quote.baseFare,
      'description': 'Minimum fare for the delivery'
    });
    
    breakdown.add({
      'label': 'Distance Fare',
      'amount': quote.distanceFare,
      'description': '${quote.distance.toStringAsFixed(1)} km × ₹${(quote.distanceFare/quote.distance).toStringAsFixed(2)}/km'
    });
    
    if (quote.estimatedTime > 0) {
      breakdown.add({
        'label': 'Time Fare',
        'amount': quote.timeFare,
        'description': '${quote.estimatedTime} minutes × ₹${(quote.timeFare/quote.estimatedTime).toStringAsFixed(2)}/min'
      });
    }
    
    breakdown.add({
      'label': 'Booking Fee',
      'amount': quote.bookingFee,
      'description': 'Fixed booking charge'
    });
    
    if (quote.peakSurcharge > 0) {
      breakdown.add({
        'label': 'Peak Hour Surcharge',
        'amount': quote.peakSurcharge,
        'description': 'Applied during high-demand hours'
      });
    }
    
    if (quote.nightSurcharge > 0) {
      breakdown.add({
        'label': 'Night Delivery Surcharge',
        'amount': quote.nightSurcharge,
        'description': 'Applied for late-night deliveries'
      });
    }
    
    if (quote.heavyItemSurcharge > 0) {
      breakdown.add({
        'label': 'Heavy Item Surcharge',
        'amount': quote.heavyItemSurcharge,
        'description': 'Applied for heavy/bulky items'
      });
    }
    
    breakdown.add({
      'label': 'Service Fee (${(quote.serviceFee/quote.totalFare*100).toStringAsFixed(1)}%)',
      'amount': quote.serviceFee,
      'description': 'Platform service charge'
    });
    
    return breakdown;
  }

  // Calculate earnings for rider based on performance
  double calculateRiderEarnings({
    required double baseEarnings,
    required double rating, // 1-5 scale
    required bool isOnTime,
    required int deliveriesCount,
  }) {
    double earnings = baseEarnings;
    
    // Rating bonus
    if (rating >= 4.5) {
      earnings *= 1.1; // 10% bonus for excellent rating
    } else if (rating >= 4.0) {
      earnings *= 1.05; // 5% bonus for good rating
    } else if (rating < 3.5) {
      earnings *= 0.9; // 10% penalty for poor rating
    }
    
    // Punctuality bonus
    if (isOnTime) {
      earnings *= 1.05; // 5% bonus for on-time delivery
    }
    
    // Volume bonus
    if (deliveriesCount >= 20) {
      earnings *= 1.15; // 15% bonus for high volume
    } else if (deliveriesCount >= 10) {
      earnings *= 1.1; // 10% bonus for moderate volume
    }
    
    return earnings;
  }
}