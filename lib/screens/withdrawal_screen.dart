import 'package:flutter/material.dart';
import 'package:rider_app/models/withdrawal_system.dart';
import 'package:rider_app/services/withdrawal_service.dart';
import 'package:rider_app/controllers/user_controller.dart';

class WithdrawalScreen extends StatefulWidget {
  final String riderId;
  
  const WithdrawalScreen({Key? key, required this.riderId}) : super(key: key);

  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final WithdrawalService _service = WithdrawalService();
  final TextEditingController _amountController = TextEditingController();
  
  late PayoutSettings _payoutSettings;
  late WithdrawalHistory _withdrawalHistory;
  late WithdrawalEligibility _eligibility;
  String _selectedMethod = 'bank_transfer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _payoutSettings = _service.getDefaultPayoutSettings(widget.riderId);
    _withdrawalHistory = _service.getFullWithdrawalHistory(widget.riderId);
    _eligibility = _service.checkWithdrawalEligibility(widget.riderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Earnings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildEligibilityCard(),
            const SizedBox(height: 20),
            _buildWithdrawalForm(),
            const SizedBox(height: 20),
            _buildWithdrawalHistory(),
            const SizedBox(height: 20),
            _buildPayoutSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '₹${userController.currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ready to withdraw',
              style: TextStyle(
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

  Widget _buildEligibilityCard() {
    final isEligible = _eligibility.isEligible;
    final color = isEligible ? Colors.green : Colors.orange;
    final icon = isEligible ? Icons.check_circle : Icons.info;
    final title = isEligible ? 'Eligible for Withdrawal' : 'Withdrawal Not Available';

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (_eligibility.reason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _eligibility.reason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                  if (_eligibility.nextEligibleDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Next available: ${_service.formatDate(_eligibility.nextEligibleDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Withdrawal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Withdraw',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: _eligibility.isEligible,
            ),
            const SizedBox(height: 20),
            const Text(
              'Withdrawal Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._service.getWithdrawalMethods().map((method) => 
              RadioListTile<String>(
                title: Text(_service.getMethodName(method)),
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
              )
            ).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _eligibility.isEligible ? _requestWithdrawal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Request Withdrawal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalHistory() {
    final completed = _withdrawalHistory.completedWithdrawals;
    final pending = _withdrawalHistory.pendingWithdrawals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withdrawal History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            if (pending.isNotEmpty) ...[
              const Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              ...pending.map((withdrawal) => _buildHistoryItem(withdrawal, true)).toList(),
              const SizedBox(height: 20),
            ],
            const Text(
              'Completed Withdrawals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (completed.isEmpty)
              const Text(
                'No completed withdrawals yet',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...completed.map((withdrawal) => _buildHistoryItem(withdrawal, false)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(WithdrawalRequest withdrawal, bool isPending) {
    final statusColor = isPending ? Colors.orange : Colors.green;
    final statusText = isPending ? 'Processing' : 'Completed';
    
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${withdrawal.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Method: ${_service.getMethodName(withdrawal.withdrawalMethod)}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            'Date: ${_service.formatDate(withdrawal.createdAt)}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          if (withdrawal.completedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Completed: ${_service.formatDate(withdrawal.completedAt!)}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayoutSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payout Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildSettingItem('Bank Account', _payoutSettings.bankAccountNumber),
            _buildSettingItem('Account Holder', _payoutSettings.accountHolderName),
            _buildSettingItem('Frequency', _payoutSettings.withdrawalFrequency),
            _buildSettingItem('Minimum Amount', '₹${_payoutSettings.minimumWithdrawalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editPayoutSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Edit Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _requestWithdrawal() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter withdrawal amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount < _eligibility.minimumAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum withdrawal amount is ₹${_eligibility.minimumAmount.toStringAsFixed(0)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > _eligibility.availableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Withdrawal'),
        content: Text('Are you sure you want to withdraw ₹${amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processWithdrawal(amount);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdrawal(double amount) async {
    final withdrawal = await _service.requestWithdrawal(
      riderId: widget.riderId,
      amount: amount,
      withdrawalMethod: _selectedMethod,
    );

    if (withdrawal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh data
      setState(() {
        _loadData();
        _amountController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process withdrawal request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editPayoutSettings() {
    // Navigate to payout settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payout settings editing feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}