import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart' as cartProv;
import '../product_details_screen.dart'; // Adjust path as needed

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final wishlist = context.watch<WishlistProvider>();

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/main');
            },
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'My Wishlist',
            style: TextStyle(
              color: const Color.fromARGB(255, 6, 6, 6),
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF4A00E0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Color.fromARGB(255, 5, 5, 5)),
        ),
        body:
            wishlist.items.isEmpty
                ? const _EmptyWishlist()
                : Padding(
                  padding: EdgeInsets.all(
                    8.w,
                  ), // Reduced from 12.w for more width
                  child: GridView.builder(
                    itemCount: wishlist.items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 400.h, // Kept for taller cards
                      crossAxisSpacing: 4.w, // Reduced for wider cards
                      mainAxisSpacing: 12.h,
                    ),
                    itemBuilder: (context, index) {
                      final product = wishlist.items[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 300 + index * 100),
                        child: _WishlistCard(product: product),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

// -------------------- Empty Wishlist Widget --------------------
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Icon(
              Icons.favorite_border,
              size: 100.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your wishlist is empty 💔',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some products to your wishlist!',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/main');
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
              'Explore Products',
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

// -------------------- Wishlist Card Widget --------------------
class _WishlistCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _WishlistCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<cartProv.CartProvider>();
    final isInWishlist = wishlist.isInWishlist(product['name']);
    final bool isInStock = product['stock'] ?? true;
    final double price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final double oldPrice = (product['oldPrice'] as num?)?.toDouble() ?? price;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child:
                      product['image'].startsWith('assets/')
                          ? Image.asset(
                            product['image'],
                            height: 170.h, // Kept for proportion
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                'Asset load error for ${product['image']}: $error',
                              );
                              return _imageErrorWidget();
                            },
                          )
                          : CachedNetworkImage(
                            imageUrl: product['image'],
                            height: 170.h, // Kept for proportion
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _imagePlaceholder(),
                            errorWidget: (context, url, error) {
                              print(
                                'Network image load error for $url: $error',
                              );
                              return _imageErrorWidget();
                            },
                          ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isInWishlist),
                      color: isInWishlist ? Colors.red : Colors.grey,
                      size: 24.sp,
                    ),
                  ),
                  onPressed: () {
                    wishlist.toggleWishlist(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              isInWishlist
                                  ? Icons.remove_circle
                                  : Icons.favorite,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${product['name']} ${isInWishlist ? 'removed from' : 'added to'} wishlist',
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
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand'] ?? 'Unknown Brand',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  product['name'] ?? 'Unknown Product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${product['rating'] ?? 4.5} (${product['reviews'] ?? 1200})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${product['discount'] ?? 0}% OFF',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '₹${oldPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13.sp, // Reduced from 14.sp
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w), // Reduced from 8.w
                    Flexible(
                      child: Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A00E0),
                          fontSize: 14.sp, // Reduced from 16.sp
                        ),
                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: GestureDetector(
              onTapDown: (_) => Feedback.forTap(context),
              child: ElevatedButton(
                onPressed:
                    isInStock
                        ? () {
                          final productToAdd = {
                            'name': product['name'],
                            'price': price,
                            'image': product['image'],
                            'brand': product['brand'],
                            'discount': product['discount'],
                            'oldPrice': oldPrice,
                            'quantity': 1,
                            'rating': product['rating'],
                            'reviews': product['reviews'],
                            'stock': product['stock'],
                          };
                          cart.addItem(productToAdd);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${product['name']} added to cart',
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
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInStock
                          ? const Color(0xFF4A00E0)
                          : Colors.grey.shade400,
                  minimumSize: Size.fromHeight(36.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
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
