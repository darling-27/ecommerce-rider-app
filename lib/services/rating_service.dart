import 'package:flutter/material.dart';
import 'package:rider_app/models/rating_system.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  // Mock data for demonstration
  List<Rating> getRatingsForUser(String userId, String userType) {
    if (userType == 'rider') {
      return _getRiderRatings(userId);
    } else {
      return _getCustomerRatings(userId);
    }
  }

  List<Rating> _getRiderRatings(String riderId) {
    return [
      Rating(
        id: "rating_1",
        raterId: "customer_101",
        rateeId: riderId,
        orderId: "#ORD-101",
        score: 5.0,
        comment: "Excellent service! Very punctual and friendly.",
        ratingType: "customer_to_rider",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        aspects: [
          RatingAspect(aspect: "punctuality", score: 5.0),
          RatingAspect(aspect: "courtesy", score: 5.0),
          RatingAspect(aspect: "package_condition", score: 5.0),
        ],
      ),
      Rating(
        id: "rating_2",
        raterId: "customer_102",
        rateeId: riderId,
        orderId: "#ORD-102",
        score: 4.0,
        comment: "Good delivery, arrived on time.",
        ratingType: "customer_to_rider",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        aspects: [
          RatingAspect(aspect: "punctuality", score: 4.0),
          RatingAspect(aspect: "courtesy", score: 4.0),
          RatingAspect(aspect: "package_condition", score: 4.0),
        ],
      ),
      Rating(
        id: "rating_3",
        raterId: "customer_103",
        rateeId: riderId,
        orderId: "#ORD-103",
        score: 3.0,
        comment: "Average service, delivery was a bit late.",
        ratingType: "customer_to_rider",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        aspects: [
          RatingAspect(aspect: "punctuality", score: 2.0),
          RatingAspect(aspect: "courtesy", score: 4.0),
          RatingAspect(aspect: "package_condition", score: 3.0),
        ],
      ),
    ];
  }

  List<Rating> _getCustomerRatings(String customerId) {
    return [
      Rating(
        id: "rating_4",
        raterId: "rider_123",
        rateeId: customerId,
        orderId: "#ORD-101",
        score: 4.5,
        comment: "Good customer, clear instructions.",
        ratingType: "rider_to_customer",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        aspects: [
          RatingAspect(aspect: "communication", score: 5.0),
          RatingAspect(aspect: "availability", score: 4.0),
        ],
      ),
    ];
  }

  UserRatingProfile getRatingProfile(String userId, String userType) {
    final ratings = getRatingsForUser(userId, userType);
    final stats = _calculateRatingStats(ratings);
    
    return UserRatingProfile(
      userId: userId,
      userType: userType,
      averageRating: (stats['average'] as num).toDouble(),
      totalRatings: stats['total'] as int,
      fiveStarCount: stats['fiveStar'] as int,
      fourStarCount: stats['fourStar'] as int,
      threeStarCount: stats['threeStar'] as int,
      twoStarCount: stats['twoStar'] as int,
      oneStarCount: stats['oneStar'] as int,
      recentRatings: ratings.take(10).toList(),
      aspectAverages: _calculateAspectAverages(ratings),
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> _calculateRatingStats(List<Rating> ratings) {
    int total = ratings.length;
    int fiveStar = ratings.where((r) => r.score == 5.0).length;
    int fourStar = ratings.where((r) => r.score == 4.0).length;
    int threeStar = ratings.where((r) => r.score == 3.0).length;
    int twoStar = ratings.where((r) => r.score == 2.0).length;
    int oneStar = ratings.where((r) => r.score == 1.0).length;
    
    double average = total > 0 
        ? ratings.fold(0.0, (sum, rating) => sum + rating.score) / total
        : 0.0;

    return {
      'total': total,
      'fiveStar': fiveStar,
      'fourStar': fourStar,
      'threeStar': threeStar,
      'twoStar': twoStar,
      'oneStar': oneStar,
      'average': average,
    };
  }

  Map<String, num> _calculateAspectAverages(List<Rating> ratings) {
    Map<String, List<double>> aspectScores = {};
    
    for (var rating in ratings) {
      for (var aspect in rating.aspects) {
        if (!aspectScores.containsKey(aspect.aspect)) {
          aspectScores[aspect.aspect] = [];
        }
        aspectScores[aspect.aspect]!.add(aspect.score);
      }
    }
    
    return aspectScores.map((aspect, scores) => 
        MapEntry(aspect, scores.reduce((a, b) => a + b) / scores.length));
  }

  List<RatingRequest> getPendingRatingRequests(String userId) {
    return [
      RatingRequest(
        id: "req_1",
        orderId: "#ORD-104",
        riderId: "rider_123",
        customerId: userId == "customer_104" ? userId : "customer_104",
        requesterId: "system",
        status: "pending",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
    ];
  }

  Future<void> submitRating(Rating rating) async {
    // In real implementation, this would save to database
    print("Rating submitted: ${rating.id}");
  }

  Future<void> completeRatingRequest(String requestId) async {
    // In real implementation, this would update the request status
    print("Rating request completed: $requestId");
  }

  RatingStatistics getRatingStatistics(String userId, String userType, DateTime periodStart, DateTime periodEnd) {
    final ratings = getRatingsForUser(userId, userType);
    final periodRatings = ratings.where((r) => 
      r.createdAt.isAfter(periodStart) && r.createdAt.isBefore(periodEnd)
    ).toList();
    
    final stats = _calculateRatingStats(periodRatings);
    final distribution = {
      '5': stats['fiveStar'] as int,
      '4': stats['fourStar'] as int,
      '3': stats['threeStar'] as int,
      '2': stats['twoStar'] as int,
      '1': stats['oneStar'] as int,
    };
    
    return RatingStatistics(
      averageRating: (stats['average'] as num).toDouble(),
      totalRatings: stats['total'] as int,
      ratingDistribution: distribution,
      completionRate: 85.0, // Mock data
      topComments: ["Excellent service", "Very punctual", "Friendly rider"],
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }
}

class RatingScreen extends StatefulWidget {
  final String userId;
  final String userType; // 'rider' or 'customer'
  
  const RatingScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingService _ratingService = RatingService();
  late UserRatingProfile _ratingProfile;
  List<RatingRequest> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _ratingProfile = _ratingService.getRatingProfile(widget.userId, widget.userType);
    _pendingRequests = _ratingService.getPendingRatingRequests(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSummary(),
            const SizedBox(height: 20),
            _buildRatingDistribution(),
            const SizedBox(height: 20),
            _buildAspectRatings(),
            const SizedBox(height: 20),
            _buildPendingRequests(),
            const SizedBox(height: 20),
            _buildRecentRatings(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _ratingProfile.averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < _ratingProfile.averageRating.floor() 
                      ? Icons.star 
                      : index < _ratingProfile.averageRating 
                          ? Icons.star_half 
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              '${_ratingProfile.totalRatings} total ratings',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${_ratingProfile.positiveRatingPercentage.toStringAsFixed(1)}% positive ratings',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildDistributionRow(5, _ratingProfile.fiveStarCount, _ratingProfile.totalRatings),
            _buildDistributionRow(4, _ratingProfile.fourStarCount, _ratingProfile.totalRatings),
            _buildDistributionRow(3, _ratingProfile.threeStarCount, _ratingProfile.totalRatings),
            _buildDistributionRow(2, _ratingProfile.twoStarCount, _ratingProfile.totalRatings),
            _buildDistributionRow(1, _ratingProfile.oneStarCount, _ratingProfile.totalRatings),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(int stars, int count, int total) {
    double percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text('${count}'),
        ],
      ),
    );
  }

  Widget _buildAspectRatings() {
    if (_ratingProfile.aspectAverages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aspect Ratings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ..._ratingProfile.aspectAverages.entries.map((entry) => 
              _buildAspectRow(entry.key, entry.value.toDouble())
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRow(String aspect, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              _formatAspectName(aspect),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 5,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    if (_pendingRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Ratings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            ..._pendingRequests.map((request) => _buildRequestItem(request)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(RatingRequest request) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.rate_review, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate your ${widget.userType == 'rider' ? 'customer' : 'rider'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Order: ${request.orderId}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showRatingDialog(request),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRatings() {
    if (_ratingProfile.recentRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Ratings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ..._ratingProfile.recentRatings.take(5).map((rating) => 
              _buildRatingItem(rating)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(Rating rating) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.score.floor() 
                        ? Icons.star 
                        : index < rating.score 
                            ? Icons.star_half 
                            : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const Spacer(),
              Text(
                rating.createdAt.toString().split(' ')[0],
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          if (rating.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              rating.comment!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingDialog(RatingRequest request) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        request: request,
        onSubmit: (rating) {
          _ratingService.submitRating(rating);
          _ratingService.completeRatingRequest(request.id);
          setState(() {
            _pendingRequests.remove(request);
            // Refresh rating profile
            _ratingProfile = _ratingService.getRatingProfile(widget.userId, widget.userType);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatAspectName(String aspect) {
    switch (aspect) {
      case 'punctuality': return 'Punctuality';
      case 'courtesy': return 'Courtesy';
      case 'package_condition': return 'Package Condition';
      case 'communication': return 'Communication';
      case 'availability': return 'Availability';
      default: return aspect;
    }
  }
}

class RatingDialog extends StatefulWidget {
  final RatingRequest request;
  final Function(Rating) onSubmit;

  const RatingDialog({
    Key? key,
    required this.request,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _aspects = [
    {'name': 'punctuality', 'label': 'Punctuality', 'rating': 0.0},
    {'name': 'courtesy', 'label': 'Courtesy', 'rating': 0.0},
    {'name': 'package_condition', 'label': 'Package Condition', 'rating': 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Experience'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Overall Rating'),
            const SizedBox(height: 10),
            _buildStarRating(),
            const SizedBox(height: 20),
            ..._aspects.map((aspect) => _buildAspectRating(aspect)).toList(),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 ? _submitRating : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating.floor() 
                ? Icons.star 
                : index < _rating 
                    ? Icons.star_half 
                    : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () => setState(() => _rating = index + 1.0),
        );
      }),
    );
  }

  Widget _buildAspectRating(Map<String, dynamic> aspect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(aspect['label']),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < aspect['rating'].floor() 
                    ? Icons.star 
                    : index < aspect['rating'] 
                        ? Icons.star_half 
                        : Icons.star_border,
                color: Colors.blue,
                size: 24,
              ),
              onPressed: () => setState(() => aspect['rating'] = index + 1.0),
            );
          }),
        ),
      ],
    );
  }

  void _submitRating() {
    final rating = Rating(
      id: "rating_${DateTime.now().millisecondsSinceEpoch}",
      raterId: widget.request.requesterId,
      rateeId: widget.request.riderId == widget.request.requesterId 
          ? widget.request.customerId 
          : widget.request.riderId,
      orderId: widget.request.orderId,
      score: _rating,
      comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      ratingType: widget.request.riderId == widget.request.requesterId 
          ? "rider_to_customer" 
          : "customer_to_rider",
      createdAt: DateTime.now(),
      aspects: _aspects
          .where((a) => a['rating'] > 0)
          .map((a) => RatingAspect(
                aspect: a['name'],
                score: a['rating'],
              ))
          .toList(),
    );

    widget.onSubmit(rating);
  }
}