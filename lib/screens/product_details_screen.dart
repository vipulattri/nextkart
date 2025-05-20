import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexkart6/screens/wishlist/ordersummery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/cart_provider.dart' as cart_provider;
import '../../providers/wishlist_provider.dart' as wishlist_provider;

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];
  final List<String> _colors = ['Red', 'Blue', 'Black', 'White'];
  final PageController _imageController = PageController();

  @override
  void initState() {
    super.initState();
    if (_sizes.isNotEmpty) {
      _selectedSize = _sizes[0];
    }
    if (_colors.isNotEmpty) {
      _selectedColor = _colors[0];
    }
    _imageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(String image) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PhotoView(
                  imageProvider:
                      image.startsWith('assets/')
                          ? AssetImage(image)
                          : NetworkImage(image) as ImageProvider,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final wishlist = context.watch<wishlist_provider.WishlistProvider>();
    final cart = context.read<cart_provider.CartProvider>();
    final isInWishlist = wishlist.isInWishlist(widget.product['name']);
    final bool isInStock = widget.product['stock'] ?? true;
    final double price = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
    final double oldPrice =
        (widget.product['oldPrice'] as num?)?.toDouble() ?? price;

    // Dynamically access images from product
    final List<String> images =
        widget.product['images'] != null &&
                (widget.product['images'] as List<dynamic>).isNotEmpty
            ? (widget.product['images'] as List<dynamic>).cast<String>()
            : [widget.product['image'] ?? 'assets/images/placeholder.png'];
    print('Images for ${widget.product['name']}: $images');

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
            widget.product['name'] ?? 'Product',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.share, size: 24.sp),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing ${widget.product['name']}')),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 300.h,
                    child: PageView.builder(
                      controller: _imageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(image),
                          child:
                              image.startsWith('assets/')
                                  ? Image.asset(
                                    image,
                                    height: 300.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                        'Asset load error for $image: $error',
                                      );
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  )
                                  : CachedNetworkImage(
                                    imageUrl: image,
                                    height: 300.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: SpinKitFadingCircle(
                                            color: Color(0xFF4A00E0),
                                            size: 40,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) {
                                      print(
                                        'Network image load error for $url: $error',
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
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: SmoothPageIndicator(
                      controller: _imageController,
                      count: images.length,
                      effect: WormEffect(
                        dotHeight: 8.h,
                        dotWidth: 8.w,
                        activeDotColor: const Color(0xFF4A00E0),
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
              // Product Details
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['brand'] ?? 'Unknown Brand',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.product['rating'] ?? 4.5} (${widget.product['reviews'] ?? 1000} reviews)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A00E0),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹${oldPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${widget.product['discount'] ?? 0}% OFF',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isInStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isInStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children:
                          _sizes.map((size) {
                            return ChoiceChip(
                              label: Text(size),
                              selected: _selectedSize == size,
                              onSelected:
                                  isInStock
                                      ? (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedSize = size;
                                          });
                                        }
                                      }
                                      : null,
                              selectedColor: const Color(0xFF4A00E0),
                              labelStyle: TextStyle(
                                color:
                                    _selectedSize == size
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 14.sp,
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Select Color',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children:
                          _colors.map((color) {
                            return ChoiceChip(
                              label: Text(color),
                              selected: _selectedColor == color,
                              onSelected:
                                  isInStock
                                      ? (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedColor = color;
                                          });
                                        }
                                      }
                                      : null,
                              selectedColor: const Color(0xFF4A00E0),
                              labelStyle: TextStyle(
                                color:
                                    _selectedColor == color
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 14.sp,
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 24.sp),
                          onPressed:
                              _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                        ),
                        Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 24.sp),
                          onPressed:
                              isInStock
                                  ? () => setState(() => _quantity++)
                                  : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ExpansionTile(
                      title: Text(
                        'Product Description',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            widget.product['description'] ??
                                'This is a high-quality product designed for comfort and style. Made with premium materials, it ensures durability and satisfaction.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        'Delivery & Returns',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery: Estimated 3-5 days',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Returns: 30-day return policy',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.grey,
                  size: 28.sp,
                ),
                onPressed: () {
                  wishlist.toggleWishlist(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product['name']} ${isInWishlist ? 'removed from' : 'added to'} wishlist',
                        style: TextStyle(fontSize: 14.sp),
                      ),
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
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isInStock
                          ? () {
                            if (_selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select a size',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final productToAdd = {
                              ...widget.product,
                              'quantity': _quantity,
                              'selectedSize': _selectedSize,
                              'selectedColor': _selectedColor,
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
                                      '${widget.product['name']} added to cart',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
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
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isInStock
                          ? () {
                            if (_selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select a size',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final productForOrder = {
                              ...widget.product,
                              'quantity': _quantity,
                              'selectedSize': _selectedSize,
                              'selectedColor': _selectedColor,
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OrderSummaryScreen(
                                      cartItems: [productForOrder],
                                      totalPrice: price * _quantity,
                                    ),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isInStock
                            ? const Color(0xFFFF8C00)
                            : Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
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
