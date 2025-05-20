import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexkart6/data/orders_data.dart';
import 'package:nexkart6/screens/home/order_tracking_screen.dart'; // Import OrderTrackingScreen

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

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
            'Order History',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body:
            orderList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 100.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Place an order to see it here!',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    final order = orderList[index];
                    final items = order['items'] as List<Map<String, dynamic>>;
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 300 + index * 100),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => OrderTrackingScreen(order: order),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${index + 1} - ${order['status']}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ...items
                                    .take(2)
                                    .map(
                                      (item) => Padding(
                                        padding: EdgeInsets.only(bottom: 8.h),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child:
                                                  item['image']?.startsWith(
                                                            'assets/',
                                                          ) ??
                                                          false
                                                      ? Image.asset(
                                                        item['image'] ??
                                                            'assets/images/placeholder.png',
                                                        width: 60.w,
                                                        height: 60.h,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return _imageErrorWidget();
                                                        },
                                                      )
                                                      : CachedNetworkImage(
                                                        imageUrl:
                                                            item['image'] ??
                                                            'https://via.placeholder.com/60',
                                                        width: 60.w,
                                                        height: 60.h,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                _imagePlaceholder(),
                                                        errorWidget: (
                                                          context,
                                                          url,
                                                          error,
                                                        ) {
                                                          return _imageErrorWidget();
                                                        },
                                                      ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'] ??
                                                        'Unknown Product',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    'Size: ${item['selectedSize'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Color: ${item['selectedColor'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${(item['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'} x ${item['quantity'] ?? 1}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                if (items.length > 2)
                                  Text(
                                    '+ ${items.length - 2} more item${items.length > 3 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Total: ₹${(order['totalPrice'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4A00E0),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Ordered on ${order['date'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Payment: ${order['paymentMethod'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Address: ${(order['address'] as Map?)?['street'] ?? 'N/A'}, ${(order['address'] as Map?)?['city'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
