import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexkart6/providers/cart_provider.dart' as cart_provider;
import 'package:nexkart6/screens/categories/bueaty.dart';
import 'package:nexkart6/screens/categories/electronics.dart';
import 'package:nexkart6/screens/categories/mensware.dart';
import 'package:nexkart6/screens/categories/shoes.dart';
import 'package:nexkart6/screens/categories/toys.dart';
import 'package:nexkart6/screens/categories/womensware.dart';
import 'package:nexkart6/screens/product_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:nexkart6/providers/wishlist_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSearchPressed;

  const HomeScreen({Key? key, required this.onSearchPressed}) : super(key: key);

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
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _SearchBar(onSearchPressed: onSearchPressed),
              ),
              SliverToBoxAdapter(child: _BannerCarousel()),
              SliverToBoxAdapter(child: _CategoryList()),
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: _ProductGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Search Bar --------------------
class _SearchBar extends StatelessWidget {
  final VoidCallback onSearchPressed;

  const _SearchBar({required this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSearchPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 1),
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 246, 245, 248).withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600, size: 22.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Search products',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.mic, color: Colors.grey.shade600, size: 22.sp),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.camera_alt,
                color: Colors.grey.shade600,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Banner Carousel --------------------
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _pageController = PageController();
  final List<String> bannerImages = [
    'assets/images/banner_2.jpg',
    'assets/images/banner_3.jpg',
    'assets/images/banner_4.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    bannerImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                        'Error loading banner asset: ${bannerImages[index]} - $error',
                      );
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        SmoothPageIndicator(
          controller: _pageController,
          count: bannerImages.length,
          effect: WormEffect(
            dotHeight: 8.h,
            dotWidth: 8.w,
            activeDotColor: const Color(0xFF4A00E0),
            dotColor: Colors.grey.shade300,
            spacing: 8.w,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// -------------------- Category List --------------------
class _CategoryList extends StatelessWidget {
  _CategoryList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'asset': 'assets/images/shirt.png',
        'label': 'Mens',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Mensware(onSearchPressed: () {}),
            ),
          );
        },
      },
      {
        'asset': 'assets/images/girldress.png',
        'label': 'Womens',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WoMenWearScreen()),
          );
        },
      },
      {
        'asset': 'assets/images/tv.png',
        'label': 'Electronics',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ElectronicsScreen()),
          );
        },
      },
      {
        'asset': 'assets/images/lotionbottle.png',
        'label': 'Beauty',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeautyScreen()),
          );
        },
      },
      {
        'asset': 'assets/images/Group.png',
        'label': 'Toys',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ToysScreen()),
          );
        },
      },
      {
        'asset': 'assets/images/shoes.png',
        'label': 'Foot wear',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShoesScreen()),
          );
        },
      },
    ];

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              categories
                  .map(
                    (category) => categoryItem(
                      category['asset'],
                      category['label'],
                      category['onTap'],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

// -------------------- Category Item Widget --------------------
Widget categoryItem(String assetPath, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A00E0).withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading category asset: $assetPath - $error');
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A00E0),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

// -------------------- Product Grid --------------------
class _ProductGrid extends StatelessWidget {
  const _ProductGrid();
  static const List<Map<String, dynamic>> products = [
    {
      'name': 'iPhone 15',
      'price': 79999,
      'oldPrice': 89999,
      'discount': 11,
      'brand': 'Apple',
      'image': 'assets/images/iphone_14_pro.png',
      'rating': 4.7,
      'reviews': 1500,
      'stock': true,
      'isNew': true,
    },
    {
      'name': 'Galaxy S24',
      'price': 69999,
      'oldPrice': 79999,
      'discount': 13,
      'brand': 'Samsung',
      'image': 'assets/images/iphone8_mobile_dual_side.png',
      'rating': 4.5,
      'reviews': 1200,
      'stock': true,
      'isNew': false,
    },
    {
      'name': 'MacBook Pro',
      'price': 129999,
      'oldPrice': 149999,
      'discount': 13,
      'brand': 'Apple',
      'image': 'assets/images/leather_jacket_4.png',
      'rating': 4.8,
      'reviews': 800,
      'stock': false,
      'isNew': true,
    },
    {
      'name': 'Sony Headphones',
      'price': 9999,
      'oldPrice': 12999,
      'discount': 23,
      'brand': 'Sony',
      'image': 'assets/images/acer_laptop_var_4.png',
      'rating': 4.3,
      'reviews': 600,
      'stock': true,
      'isNew': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 300 + index * 100),
          child: _ProductCard(product: product),
        );
      }, childCount: products.length),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 420.h,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
    );
  }
}

// -------------------- Product Card --------------------

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final isInWishlist = wishlist.isInWishlist(product['name']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: Image.asset(
                    product['image'],
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                        'Error loading product asset: ${product['image']} - $error',
                      );
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 6.h,
                right: 6.w,
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
              if (product['isNew'] == true) // Example badge for "New" products
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand'],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  product['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
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
                  '${product['discount']}% OFF',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '₹${product['oldPrice']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '₹${product['price']}',
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
                  product['stock'] ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: product['stock'] ? Colors.green : Colors.red,
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
                    product['stock']
                        ? () {
                          final productToAdd = {
                            'name': product['name'],
                            'price': product['price'],
                            'image': product['image'],
                            'brand': product['brand'],
                          };
                          context.read<cart_provider.CartProvider>().addItem(
                            productToAdd,
                          );
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
                        : null, // Disable button if out of stock
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(36.h),
                  backgroundColor:
                      product['stock']
                          ? const Color(0xFF4A00E0)
                          : Colors.grey.shade400,
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

  // ignore: unused_element
  Widget _imagePlaceholder() => const Center(
    child: SpinKitFadingCircle(color: Color(0xFF4A00E0), size: 40),
  );

  // ignore: unused_element
  Widget _imageErrorWidget() => const Center(
    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
  );
}
