import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Simulated tracking stages based on order status
  List<Map<String, dynamic>> getTrackingStages() {
    final status = widget.order['status'] ?? 'Processing';
    final orderDate = DateTime.parse(
      widget.order['date'] ?? DateTime.now().toString(),
    );
    final stages = [
      {'status': 'Ordered', 'date': orderDate, 'completed': true},
      {
        'status': 'Shipped',
        'date': orderDate.add(const Duration(days: 1)),
        'completed': status != 'Processing',
      },
      {
        'status': 'Out for Delivery',
        'date': orderDate.add(const Duration(days: 2)),
        'completed': status == 'Out for Delivery' || status == 'Delivered',
      },
      {
        'status': 'Delivered',
        'date': orderDate.add(const Duration(days: 3)),
        'completed': status == 'Delivered',
      },
    ];
    return stages;
  }

  // Estimated delivery date (3 days from order date)
  DateTime getEstimatedDeliveryDate() {
    final orderDate = DateTime.parse(
      widget.order['date'] ?? DateTime.now().toString(),
    );
    return orderDate.add(const Duration(days: 3));
  }

  // Get icon for payment method (same as OrderSummaryScreen)
  IconData _getPaymentIcon(String? method) {
    if (method == null) return Icons.payment;
    switch (method.toLowerCase()) {
      case 'cash on delivery':
        return Icons.money;
      case 'upi':
        return Icons.qr_code;
      case 'credit/debit card':
        return Icons.credit_card;
      case 'wallet (phonepe)':
        return Icons.account_balance_wallet;
      case 'net banking':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  // Get payment status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'initiated':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final items = widget.order['items'] as List<Map<String, dynamic>>;
    final trackingStages = getTrackingStages();
    final paymentStatus =
        widget.order['paymentStatus'] ??
        (widget.order['paymentMethod'] == 'Cash on Delivery'
            ? 'Pending'
            : 'Initiated');

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
            'Order Tracking',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Text(
                'Order #${items.hashCode} - ${widget.order['status']}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Ordered on ${widget.order['date'] ?? 'N/A'}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              Text(
                'Estimated Delivery: ${getEstimatedDeliveryDate().toString().substring(0, 10)}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 24.h),

              // Tracking Map Animation
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                child: SizedBox(
                  height: 200.h,
                  child: Stack(
                    children: [
                      // Simulated map background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Map Simulation',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      // Animated delivery path
                      CustomPaint(
                        size: Size(double.infinity, 200.h),
                        painter: DeliveryPathPainter(
                          progress: _animation.value,
                        ),
                      ),
                      // Delivery marker
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            left:
                                50.w +
                                (_animation.value *
                                    (MediaQuery.of(context).size.width -
                                        150.w)),
                            top: 50.h,
                            child: Icon(
                              Icons.local_shipping,
                              color: const Color(0xFF4A00E0),
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Tracking Timeline
              Text(
                'Tracking Status',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
              ...trackingStages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                return _TrackingStage(
                  status: stage['status'],
                  date: stage['date'],
                  isCompleted: stage['completed'],
                  isLast: index == trackingStages.length - 1,
                );
              }),
              SizedBox(height: 24.h),

              // Order Items
              Text(
                'Ordered Items (${items.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
              ...items.map((item) => _OrderItem(item: item)),
              SizedBox(height: 24.h),

              // Order Summary
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
                            'Items (${items.length}):',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '₹${(widget.order['totalPrice'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
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
                            '₹0.00', // Placeholder
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
                            '₹${(widget.order['totalPrice'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
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
              SizedBox(height: 24.h),

              // Shipping Address
              Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Text(
                    '${widget.order['address']?['name'] ?? 'N/A'}\n'
                    '${widget.order['address']?['phone'] ?? 'N/A'}\n'
                    '${widget.order['address']?['street'] ?? 'N/A'}, '
                    '${widget.order['address']?['city'] ?? 'N/A'}, '
                    '${widget.order['address']?['state'] ?? 'N/A'} - '
                    '${widget.order['address']?['pincode'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Enhanced Payment Details
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
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
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(widget.order['paymentMethod']),
                            color: const Color(0xFF4A00E0),
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              widget.order['paymentMethod'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '₹${(widget.order['totalPrice'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
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
                            'Payment Status:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            paymentStatus,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(paymentStatus),
                            ),
                          ),
                        ],
                      ),
                      if (widget.order['paymentId'] != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Payment ID: ${widget.order['paymentId']}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Text(
                        'Transaction Date: ${widget.order['date'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Delivery Path Animation
class DeliveryPathPainter extends CustomPainter {
  final double progress;

  DeliveryPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    final progressPaint =
        Paint()
          ..color = const Color(0xFF4A00E0)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    // Draw a simple curved path
    final path =
        Path()
          ..moveTo(50.w, 150.h)
          ..quadraticBezierTo(size.width / 2, 50.h, size.width - 50.w, 150.h);

    // Draw full path (background)
    canvas.drawPath(path, paint);

    // Draw progress path
    final progressPath = Path();
    final pathMetrics = path.computeMetrics();
    final pathMetric = pathMetrics.first;
    final length = pathMetric.length * progress;
    progressPath.addPath(pathMetric.extractPath(0, length), Offset.zero);
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Tracking Stage Widget
class _TrackingStage extends StatelessWidget {
  final String status;
  final DateTime date;
  final bool isCompleted;
  final bool isLast;

  const _TrackingStage({
    required this.status,
    required this.date,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color:
                    isCompleted
                        ? const Color(0xFF4A00E0)
                        : Colors.grey.shade400,
                size: 24.sp,
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 40.h,
                  color:
                      isCompleted
                          ? const Color(0xFF4A00E0)
                          : Colors.grey.shade400,
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCompleted
                            ? Colors.grey.shade800
                            : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date.toString().substring(0, 10),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        isCompleted
                            ? Colors.grey.shade800
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Order Item Widget
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
