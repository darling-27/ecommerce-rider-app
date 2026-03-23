import 'package:flutter/material.dart';
import 'package:rider_app/models/rating_system.dart';
import 'package:rider_app/services/rating_service.dart';

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
              _buildAspectRow(entry.key, (entry.value).toDouble())
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
      color: const Color.fromRGBO(33, 150, 243, 0.1),
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
        border: Border.all(color: const Color.fromRGBO(33, 150, 243, 0.3)),
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
        border: Border.all(color: const Color.fromRGBO(158, 158, 158, 0.3)),
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