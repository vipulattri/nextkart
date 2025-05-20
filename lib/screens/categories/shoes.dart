import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart' as wishlist_provider;
import '../../providers/cart_provider.dart' as cart_provider;
import '../product_details_screen.dart'; // Adjust path as needed

class ShoesScreen extends StatefulWidget {
  final VoidCallback? onSearchPressed;

  const ShoesScreen({super.key, this.onSearchPressed});

  @override
  State<ShoesScreen> createState() => _ShoesScreenState();
}

class _ShoesScreenState extends State<ShoesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Sample shoe products with fields matching other screens
  static const List<Map<String, dynamic>> shoeProducts = [
    {
      'name': 'Nike Air Jordan',
      'price': 999,
      'oldPrice': 1299,
      'discount': 23,
      'brand': 'Nike',
      'image': 'assets/images/NikeAirJordonSingleBlue.png',
      'rating': 4.6,
      'reviews': 950,
      'stock': true,
    },
    {
      'name': 'Nike Air Max',
      'price': 1999,
      'oldPrice': 2499,
      'discount': 20,
      'brand': 'Nike',
      'image': 'assets/images/NikeAirMax.png',
      'rating': 4.8,
      'reviews': 1200,
      'stock': true,
    },
    {
      'name': 'Adidas Running Shoes',
      'price': 2999,
      'oldPrice': 3799,
      'discount': 21,
      'brand': 'Adidas',
      'image': 'assets/images/nike-shoes.png',
      'rating': 4.5,
      'reviews': 800,
      'stock': false,
    },
    {
      'name': 'Puma Slippers',
      'price': 3499,
      'oldPrice': 4299,
      'discount': 19,
      'brand': 'Puma',
      'image': 'assets/images/slipper-product.png',
      'rating': 4.4,
      'reviews': 650,
      'stock': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final filteredProducts =
        shoeProducts.where((product) {
          final nameLower = product['name']?.toString().toLowerCase() ?? '';
          final brandLower = product['brand']?.toString().toLowerCase() ?? '';
          final queryLower = searchQuery.toLowerCase();
          return nameLower.contains(queryLower) ||
              brandLower.contains(queryLower);
        }).toList();

    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF3F51B5), // Blue theme for Shoes
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3F51B5),
          secondary: Color(0xFFFF8C00),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'NexKart',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF3F51B5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            Container(
              width: 300.w,
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              child:
                  widget.onSearchPressed != null
                      ? GestureDetector(
                        onTap: widget.onSearchPressed,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              252,
                              252,
                              253,
                            ).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.black),
                              SizedBox(width: 8.w),
                              Text(
                                'Search Shoes...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Shoes...',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(
                            255,
                            252,
                            252,
                            253,
                          ).withOpacity(0.8),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16.w,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                      ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child:
                filteredProducts.isEmpty
                    ? Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 430.h,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 300 + index * 100),
                          child: _ProductCard(product: product),
                        );
                      },
                    ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // Adjust if Toys tab is at another index
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/main');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/wishlist');

            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/cart');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/account');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<wishlist_provider.WishlistProvider>();
    final cart = context.read<cart_provider.CartProvider>();
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
                            height: 170.h,
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
                            height: 170.h,
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
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${product['name']} ${isInWishlist ? 'removed from' : 'added to'} wishlist',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF3F51B5),
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
                      '${product['rating'] ?? 4.5} (${product['reviews'] ?? 1000})',
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
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3F51B5),
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  isInStock ? 'In Stock' : ' Out of Stock',
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
                              backgroundColor: const Color(0xFF3F51B5),
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
                          ? const Color(0xFF3F51B5)
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
    child: SpinKitFadingCircle(color: Color(0xFF3F51B5), size: 40),
  );

  Widget _imageErrorWidget() => const Center(
    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
  );
}
