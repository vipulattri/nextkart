import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexkart6/data/orders_data.dart';
import 'package:nexkart6/providers/adress_provider.dart';
import 'package:nexkart6/screens/profile/order_history.dart';
import 'package:provider/provider.dart';
import 'package:nexkart6/models/adrees.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

enum PaymentMethod { cod, upi, card, wallet, netBanking }

String paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cod:
      return 'Cash on Delivery';
    case PaymentMethod.upi:
      return 'UPI';
    case PaymentMethod.card:
      return 'Credit/Debit Card';
    case PaymentMethod.wallet:
      return 'Wallet';
    case PaymentMethod.netBanking:
      return 'Net Banking';
  }
}

class OrderSummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  Address? selectedAddress;
  PaymentMethod? selectedPaymentMethod;
  Razorpay? _razorpay;
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print('OrderSummaryScreen: Razorpay initialized');
  }

  @override
  void dispose() {
    print('OrderSummaryScreen: Disposing resources');
    _razorpay?.clear();
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _selectAddress(BuildContext context) async {
    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => const _AddressSelectionScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        selectedAddress = result;
        print(
          'OrderSummaryScreen: Selected address - ${selectedAddress!.name}',
        );
      });
    }
  }

  void _selectPaymentMethod(BuildContext context) async {
    final result = await Navigator.push<PaymentMethod>(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodSelectionScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        selectedPaymentMethod = result;
        _upiController.clear();
        _cardNumberController.clear();
        _expiryController.clear();
        _cvvController.clear();
        _selectedBank = null;
        print(
          'OrderSummaryScreen: Selected payment method - ${paymentMethodToString(result)}',
        );
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(
      'OrderSummaryScreen: Payment success - Payment ID: ${response.paymentId}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response.paymentId}'),
        backgroundColor: const Color(0xFF4A00E0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
    _confirmOrder(
      context,
      paymentId: response.paymentId,
      paymentStatus: 'Completed',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
      'OrderSummaryScreen: Payment error - Code: ${response.code}, Message: ${response.message}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(
      'OrderSummaryScreen: External wallet - Wallet: ${response.walletName}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: const Color(0xFF4A00E0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  bool _validateInputs() {
    print('OrderSummaryScreen: Validating inputs for ${selectedPaymentMethod}');
    if (selectedPaymentMethod == PaymentMethod.upi) {
      final upi = _upiController.text;
      final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
      if (!upiRegex.hasMatch(upi)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid UPI ID (e.g., user@phonepe)'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        print('OrderSummaryScreen: Invalid UPI ID - $upi');
        return false;
      }
    }
    if (selectedPaymentMethod == PaymentMethod.card) {
      final cardNumber = _cardNumberController.text;
      final expiry = _expiryController.text;
      final cvv = _cvvController.text;
      final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
      if (cardNumber.length != 16 ||
          !RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid 16-digit card number'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        print('OrderSummaryScreen: Invalid card number - $cardNumber');
        return false;
      }
      if (!expiryRegex.hasMatch(expiry)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid expiry date (MM/YY)'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        print('OrderSummaryScreen: Invalid expiry - $expiry');
        return false;
      }
      if (cvv.length != 3 || !RegExp(r'^\d{3}$').hasMatch(cvv)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid 3-digit CVV'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        print('OrderSummaryScreen: Invalid CVV - $cvv');
        return false;
      }
    }
    if (selectedPaymentMethod == PaymentMethod.netBanking &&
        _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a bank'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
      print('OrderSummaryScreen: No bank selected');
      return false;
    }
    print('OrderSummaryScreen: Inputs validated successfully');
    return true;
  }

  void _proceedToPay() {
    print('OrderSummaryScreen: _proceedToPay called');
    if (selectedAddress == null || selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Please select address and payment method',
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
      print('OrderSummaryScreen: Missing address or payment method');
      return;
    }

    if (!_validateInputs()) {
      print('OrderSummaryScreen: Input validation failed');
      return;
    }

    if (selectedPaymentMethod == PaymentMethod.cod) {
      print('OrderSummaryScreen: Processing COD order');
      _confirmOrder(context, paymentStatus: 'Pending');
      return;
    }

    print('OrderSummaryScreen: Initiating Razorpay payment');
    var options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with your Razorpay key
      'amount': (widget.totalPrice * 100).toInt(),
      'name': 'Nexkart',
      'description': 'Order #${widget.cartItems.hashCode}',
      'prefill': {
        'contact': selectedAddress?.phone ?? '',
        'email': 'customer@example.com', // Replace with actual user email
      },
      'external': {
        'wallets': ['phonepe'],
      },
      if (selectedPaymentMethod == PaymentMethod.upi)
        'vpa': _upiController.text,
      if (selectedPaymentMethod == PaymentMethod.card)
        'card': {
          'number': _cardNumberController.text,
          'expiry_month': _expiryController.text.split('/')[0],
          'expiry_year':
              '20${_expiryController.text.split('/')[1]}', // Ensure full year
          'cvv': _cvvController.text,
        },
      if (selectedPaymentMethod == PaymentMethod.netBanking)
        'bank': _selectedBank,
      if (selectedPaymentMethod == PaymentMethod.wallet) 'wallet': 'phonepe',
    };

    try {
      print('OrderSummaryScreen: Opening Razorpay with options: $options');
      _razorpay?.open(options);
    } catch (e, stackTrace) {
      print('OrderSummaryScreen: Error initiating payment: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _confirmOrder(
    BuildContext context, {
    String? paymentId,
    required String paymentStatus,
  }) {
    print(
      'OrderSummaryScreen: _confirmOrder called with paymentStatus: $paymentStatus, paymentId: $paymentId',
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Order',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to place this order?',
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print(
                    'OrderSummaryScreen: Confirmation dialog - Cancel pressed',
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  print(
                    'OrderSummaryScreen: Confirmation dialog - Confirm pressed',
                  );
                  final newOrder = {
                    'items': widget.cartItems,
                    'totalPrice': widget.totalPrice,
                    'address': selectedAddress!.toJson(),
                    'paymentMethod': paymentMethodToString(
                      selectedPaymentMethod!,
                    ),
                    'paymentId': paymentId,
                    'paymentStatus': paymentStatus,
                    'status': 'Processing',
                    'date': DateTime.now().toString().substring(0, 10),
                  };

                  print(
                    'OrderSummaryScreen: Adding new order to orderList: $newOrder',
                  );
                  orderList.add(newOrder);

                  Navigator.pop(context); // Close dialog
                  print('OrderSummaryScreen: Dialog closed');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Order confirmed!',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF4A00E0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                    ),
                  );

                  print('OrderSummaryScreen: Navigating to OrderHistoryScreen');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                  );
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF4A00E0),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF4A00E0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A00E0),
          secondary: Color(0xFFFF8C00),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF4A00E0),
          title: Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.history, size: 24.sp),
              onPressed: () {
                print(
                  'OrderSummaryScreen: Navigating to OrderHistoryScreen via app bar',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                );
              },
              tooltip: 'View Order History',
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            children: [
              Text(
                'Order Items (${widget.cartItems.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
              if (widget.cartItems.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'No items in the order.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              else
                ...widget.cartItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 300 + index * 100),
                    child: _OrderItem(item: item),
                  );
                }),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectPaymentMethod(context),
                    child: Text(
                      selectedPaymentMethod == null ? 'Select' : 'Change',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF4A00E0),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  key: ValueKey(selectedPaymentMethod),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => _selectPaymentMethod(context),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Icon(
                            selectedPaymentMethod == null
                                ? Icons.payment
                                : _getPaymentIcon(selectedPaymentMethod!),
                            color: const Color(0xFF4A00E0),
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              selectedPaymentMethod == null
                                  ? 'Select a payment method'
                                  : paymentMethodToString(
                                    selectedPaymentMethod!,
                                  ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (selectedPaymentMethod == PaymentMethod.upi)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: TextField(
                      controller: _upiController,
                      decoration: InputDecoration(
                        labelText: 'UPI ID (e.g., user@phonepe)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: Icon(
                          Icons.qr_code,
                          color: const Color(0xFF4A00E0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),
              if (selectedPaymentMethod == PaymentMethod.card)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      children: [
                        TextField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            prefixIcon: Icon(
                              Icons.credit_card,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expiryController,
                                decoration: InputDecoration(
                                  labelText: 'Expiry (MM/YY)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                keyboardType: TextInputType.datetime,
                                maxLength: 5,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _cvvController,
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (selectedPaymentMethod == PaymentMethod.netBanking)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: DropdownButton<String>(
                      hint: Text(
                        'Select Bank',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      value: _selectedBank,
                      isExpanded: true,
                      items:
                          ['HDFC', 'SBI', 'ICICI', 'Axis', 'Kotak'].map((bank) {
                            return DropdownMenuItem<String>(
                              value: bank,
                              child: Text(
                                bank,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBank = value;
                          print('OrderSummaryScreen: Selected bank - $value');
                        });
                      },
                    ),
                  ),
                ),
              if (selectedPaymentMethod == PaymentMethod.wallet)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: const Color(0xFF4A00E0),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'PhonePe Wallet',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectAddress(context),
                    child: Text(
                      selectedAddress == null ? 'Select' : 'Change',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF4A00E0),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  key: ValueKey(selectedAddress),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => _selectAddress(context),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF4A00E0),
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              selectedAddress == null
                                  ? 'Select a shipping address'
                                  : '${selectedAddress!.name}\n'
                                      '${selectedAddress!.phone}\n'
                                      '${selectedAddress!.street}, ${selectedAddress!.city}, '
                                      '${selectedAddress!.state} - ${selectedAddress!.pincode}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${widget.cartItems.length}):',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '₹${widget.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '₹0.00',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '₹${widget.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              ElevatedButton(
                onPressed: () {
                  print('OrderSummaryScreen: Pay button pressed');
                  _proceedToPay();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Pay ₹${widget.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.netBanking:
        return Icons.account_balance;
    }
  }
}

// -------------------- Order Item Widget --------------------
class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isInStock = item['stock'] ?? true;
    final int quantity = item['quantity'] ?? 1;
    final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final double oldPrice = (item['oldPrice'] as num?)?.toDouble() ?? price;
    final double subtotal = price * quantity;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child:
                  item['image']?.startsWith('assets/') ?? false
                      ? Image.asset(
                        item['image'] ?? 'assets/images/placeholder.png',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            'Asset load error for ${item['image']}: $error',
                          );
                          return _imageErrorWidget();
                        },
                      )
                      : CachedNetworkImage(
                        imageUrl:
                            item['image'] ?? 'https://via.placeholder.com/80',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _imagePlaceholder(),
                        errorWidget: (context, url, error) {
                          print('Network image load error for $url: $error');
                          return _imageErrorWidget();
                        },
                      ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['brand'] ?? 'Unknown Brand',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['name'] ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Size: ${item['selectedSize'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Color: ${item['selectedColor'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${item['rating'] ?? 4.5} (${item['reviews'] ?? 1200})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 6.h),
                      Text(
                        '${item['discount'] ?? 0}% OFF',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '₹${oldPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A00E0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isInStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isInStock ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Quantity: $quantity',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Subtotal: ₹${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A00E0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => const Center(
    child: SpinKitFadingCircle(color: Color(0xFF4A00E0), size: 40),
  );

  Widget _imageErrorWidget() => const Center(
    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
  );
}

// -------------------- Address Selection Screen --------------------
class _AddressSelectionScreen extends StatelessWidget {
  const _AddressSelectionScreen();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF4A00E0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A00E0),
          secondary: Color(0xFFFF8C00),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Select Address',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body:
            addresses.isEmpty
                ? const _EmptyAddresses()
                : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 300 + index * 100),
                      child: _AddressCard(address: address),
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4A00E0),
          onPressed: () {
            Navigator.pushNamed(context, '/add-address');
          },
          child: Icon(Icons.add, size: 24.sp, color: Colors.white),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

// -------------------- Empty Addresses Widget --------------------
class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 100.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No saved addresses 📍',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add an address to proceed with checkout!',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-address');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'Add Address',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Address Card Widget --------------------
class _AddressCard extends StatelessWidget {
  final Address address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.read<AddressProvider>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => Navigator.pop(context, address),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF4A00E0),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${address.street}, ${address.city}, ${address.state}, ${address.pincode}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Phone: ${address.phone}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 24.sp),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'Delete Address',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          content: Text(
                            'Are you sure you want to delete this address?',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                addressProvider.removeAddress(address.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Address deleted',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF4A00E0),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    margin: EdgeInsets.all(16.w),
                                  ),
                                );
                              },
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Payment Method Selection Screen --------------------
class PaymentMethodSelectionScreen extends StatelessWidget {
  const PaymentMethodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF4A00E0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A00E0),
          secondary: Color(0xFFFF8C00),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Select Payment Method',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.w),
          children:
              PaymentMethod.values.map((method) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => Navigator.pop(context, method),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentIcon(method),
                            color: const Color(0xFF4A00E0),
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            paymentMethodToString(method),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.netBanking:
        return Icons.account_balance;
    }
  }
}
