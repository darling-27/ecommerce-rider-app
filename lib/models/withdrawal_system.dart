class WithdrawalRequest {
  final String id;
  final String riderId;
  final double amount;
  final String status; // 'pending', 'processing', 'completed', 'rejected'
  final String bankAccountNumber;
  final String withdrawalMethod; // 'bank_transfer', 'upi', 'wallet'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;

  WithdrawalRequest({
    required this.id,
    required this.riderId,
    required this.amount,
    required this.status,
    required this.bankAccountNumber,
    required this.withdrawalMethod,
    this.rejectionReason,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderId': riderId,
      'amount': amount,
      'status': status,
      'bankAccountNumber': bankAccountNumber,
      'withdrawalMethod': withdrawalMethod,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      riderId: json['riderId'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      bankAccountNumber: json['bankAccountNumber'],
      withdrawalMethod: json['withdrawalMethod'],
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
}

class PayoutSettings {
  final String riderId;
  final String bankAccountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String withdrawalFrequency; // 'weekly', 'biweekly', 'monthly'
  final String emergencyWithdrawalPeriod; // '1_day', '2_days', '3_days'
  final double minimumWithdrawalAmount;
  final DateTime lastWithdrawalDate;
  final bool emergencyWithdrawalEnabled;

  PayoutSettings({
    required this.riderId,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.withdrawalFrequency,
    required this.emergencyWithdrawalPeriod,
    required this.minimumWithdrawalAmount,
    required this.lastWithdrawalDate,
    required this.emergencyWithdrawalEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'withdrawalFrequency': withdrawalFrequency,
      'emergencyWithdrawalPeriod': emergencyWithdrawalPeriod,
      'minimumWithdrawalAmount': minimumWithdrawalAmount,
      'lastWithdrawalDate': lastWithdrawalDate.toIso8601String(),
      'emergencyWithdrawalEnabled': emergencyWithdrawalEnabled,
    };
  }

  factory PayoutSettings.fromJson(Map<String, dynamic> json) {
    return PayoutSettings(
      riderId: json['riderId'],
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      accountHolderName: json['accountHolderName'],
      withdrawalFrequency: json['withdrawalFrequency'],
      emergencyWithdrawalPeriod: json['emergencyWithdrawalPeriod'],
      minimumWithdrawalAmount: json['minimumWithdrawalAmount'].toDouble(),
      lastWithdrawalDate: DateTime.parse(json['lastWithdrawalDate']),
      emergencyWithdrawalEnabled: json['emergencyWithdrawalEnabled'],
    );
  }
}

class WithdrawalHistory {
  final List<WithdrawalRequest> completedWithdrawals;
  final List<WithdrawalRequest> pendingWithdrawals;
  final double totalWithdrawn;
  final double totalPending;

  WithdrawalHistory({
    required this.completedWithdrawals,
    required this.pendingWithdrawals,
    required this.totalWithdrawn,
    required this.totalPending,
  });

  Map<String, dynamic> toJson() {
    return {
      'completedWithdrawals': completedWithdrawals.map((w) => w.toJson()).toList(),
      'pendingWithdrawals': pendingWithdrawals.map((w) => w.toJson()).toList(),
      'totalWithdrawn': totalWithdrawn,
      'totalPending': totalPending,
    };
  }

  factory WithdrawalHistory.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistory(
      completedWithdrawals: (json['completedWithdrawals'] as List)
          .map((w) => WithdrawalRequest.fromJson(w))
          .toList(),
      pendingWithdrawals: (json['pendingWithdrawals'] as List)
          .map((w) => WithdrawalRequest.fromJson(w))
          .toList(),
      totalWithdrawn: json['totalWithdrawn'].toDouble(),
      totalPending: json['totalPending'].toDouble(),
    );
  }
}

class WithdrawalEligibility {
  final bool isEligible;
  final double availableAmount;
  final String? reason; // Why not eligible
  final DateTime? nextEligibleDate;
  final double minimumAmount;

  WithdrawalEligibility({
    required this.isEligible,
    required this.availableAmount,
    this.reason,
    this.nextEligibleDate,
    required this.minimumAmount,
  });
}