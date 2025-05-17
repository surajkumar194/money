import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

class WithdrawPage extends StatefulWidget {
  final double availableBalance;

  const WithdrawPage({super.key, required this.availableBalance});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Razorpay _razorpay;
  String _selectedMethod = 'UPI';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _requestWithdrawal() {
    final upiId = _upiController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (upiId.isEmpty) {
      _showSnackBar('Please enter your UPI ID.');
      return;
    }
    if (amount == null || amount < 10) {
      _showSnackBar('Minimum withdrawal amount is ₹10.');
      return;
    }
    if (amount > widget.availableBalance) {
      _showSnackBar('Amount exceeds your available balance.');
      return;
    }

    var options = {
      'key': 'rzp_live_fTGMNyEb4EOu9r', // Use test key in development
      'amount': (amount * 100).toInt(),
      'name': 'Quanta Withdrawal',
      'description': 'Withdrawal to UPI',
      'prefill': {
        'contact': '6297981229',
        'email': 'Soumiksaha20237@gmail.com',
        'method': 'upi',
        'vpa': upiId,
      },
      'method': {'upi': true},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      _showSnackBar('Something went wrong while opening Razorpay.');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final upiId = _upiController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    await FirebaseFirestore.instance.collection('withdrawals').add({
      'transactionId': response.paymentId,
      'status': 'success',
      'mode': _selectedMethod,
      'amount': amount,
      'address': upiId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(msg: "Withdrawal Successful: ${response.paymentId}");
    Navigator.pop(context);
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    final upiId = _upiController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    await FirebaseFirestore.instance.collection('withdrawals').add({
      'transactionId': response.code.toString(),
      'status': 'failed',
      'error': response.message,
      'mode': _selectedMethod,
      'amount': amount,
      'address': upiId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(msg: "Withdrawal Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf6fafd), Color(0xFFFFD6A5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8BB5), Color(0xFFFFB6B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Withdraw Earnings',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available Balance: ₹${widget.availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    items: const [DropdownMenuItem(value: 'UPI', child: Text('UPI'))],
                    onChanged: (value) => setState(() => _selectedMethod = value!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _upiController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'e.g. username@upi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'e.g. 10.00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestWithdrawal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Request Withdrawal', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
