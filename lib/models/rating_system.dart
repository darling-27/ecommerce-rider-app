class Rating {
  final String id;
  final String raterId; // ID of person giving rating
  final String rateeId; // ID of person receiving rating
  final String orderId;
  final double score; // 1-5 stars
  final String? comment;
  final String ratingType; // 'customer_to_rider', 'rider_to_customer'
  final DateTime createdAt;
  final List<RatingAspect> aspects; // Detailed aspect ratings

  Rating({
    required this.id,
    required this.raterId,
    required this.rateeId,
    required this.orderId,
    required this.score,
    this.comment,
    required this.ratingType,
    required this.createdAt,
    required this.aspects,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raterId': raterId,
      'rateeId': rateeId,
      'orderId': orderId,
      'score': score,
      'comment': comment,
      'ratingType': ratingType,
      'createdAt': createdAt.toIso8601String(),
      'aspects': aspects.map((a) => a.toJson()).toList(),
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      raterId: json['raterId'],
      rateeId: json['rateeId'],
      orderId: json['orderId'],
      score: json['score'].toDouble(),
      comment: json['comment'],
      ratingType: json['ratingType'],
      createdAt: DateTime.parse(json['createdAt']),
      aspects: (json['aspects'] as List)
          .map((a) => RatingAspect.fromJson(a))
          .toList(),
    );
  }
}

class RatingAspect {
  final String aspect; // 'punctuality', 'courtesy', 'package_condition', etc.
  final double score; // 1-5 rating for this aspect

  RatingAspect({
    required this.aspect,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'score': score,
    };
  }

  factory RatingAspect.fromJson(Map<String, dynamic> json) {
    return RatingAspect(
      aspect: json['aspect'],
      score: json['score'].toDouble(),
    );
  }
}

class UserRatingProfile {
  final String userId;
  final String userType; // 'rider' or 'customer'
  final double averageRating;
  final int totalRatings;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final List<Rating> recentRatings;
  final Map<String, num> aspectAverages; // Average scores by aspect
  final DateTime lastUpdated;

  UserRatingProfile({
    required this.userId,
    required this.userType,
    required this.averageRating,
    required this.totalRatings,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    required this.recentRatings,
    required this.aspectAverages,
    required this.lastUpdated,
  });

  double get positiveRatingPercentage => 
      totalRatings > 0 ? ((fiveStarCount + fourStarCount) / totalRatings) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'fiveStarCount': fiveStarCount,
      'fourStarCount': fourStarCount,
      'threeStarCount': threeStarCount,
      'twoStarCount': twoStarCount,
      'oneStarCount': oneStarCount,
      'recentRatings': recentRatings.map((r) => r.toJson()).toList(),
      'aspectAverages': aspectAverages,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserRatingProfile.fromJson(Map<String, dynamic> json) {
    return UserRatingProfile(
      userId: json['userId'],
      userType: json['userType'],
      averageRating: json['averageRating'].toDouble(),
      totalRatings: json['totalRatings'],
      fiveStarCount: json['fiveStarCount'],
      fourStarCount: json['fourStarCount'],
      threeStarCount: json['threeStarCount'],
      twoStarCount: json['twoStarCount'],
      oneStarCount: json['oneStarCount'],
      recentRatings: (json['recentRatings'] as List)
          .map((r) => Rating.fromJson(r))
          .toList(),
      aspectAverages: Map<String, double>.from(json['aspectAverages']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class RatingRequest {
  final String id;
  final String orderId;
  final String riderId;
  final String customerId;
  final String requesterId; // Who initiated the rating request
  final String status; // 'pending', 'completed', 'expired'
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime expiresAt;

  RatingRequest({
    required this.id,
    required this.orderId,
    required this.riderId,
    required this.customerId,
    required this.requesterId,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canBeRated => status == 'pending' && !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'riderId': riderId,
      'customerId': customerId,
      'requesterId': requesterId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory RatingRequest.fromJson(Map<String, dynamic> json) {
    return RatingRequest(
      id: json['id'],
      orderId: json['orderId'],
      riderId: json['riderId'],
      customerId: json['customerId'],
      requesterId: json['requesterId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

class RatingStatistics {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution; // 1-5 star counts
  final double completionRate; // Percentage of rating requests completed
  final List<String> topComments; // Most common positive comments
  final DateTime periodStart;
  final DateTime periodEnd;

  RatingStatistics({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.completionRate,
    required this.topComments,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
      'completionRate': completionRate,
      'topComments': topComments,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory RatingStatistics.fromJson(Map<String, dynamic> json) {
    return RatingStatistics(
      averageRating: json['averageRating'].toDouble(),
      totalRatings: json['totalRatings'],
      ratingDistribution: Map<String, int>.from(json['ratingDistribution']),
      completionRate: json['completionRate'].toDouble(),
      topComments: List<String>.from(json['topComments']),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }
}