import 'package:flutter/material.dart';
import 'package:nexkart6/screens/categories/electronics.dart';
import 'package:nexkart6/screens/categories/toys.dart';
import 'package:nexkart6/screens/profile/browse.dart';
import 'package:nexkart6/screens/profile/terms.dart';
import 'package:provider/provider.dart';
import 'package:nexkart6/providers/adress_provider.dart';
import 'package:nexkart6/providers/cart_provider.dart' as cart_provider;
import 'package:nexkart6/providers/user_provider.dart'; // Ensure this file exists and exports UserProvider
import 'package:nexkart6/providers/wishlist_provider.dart';
import 'package:nexkart6/screens/product_details_screen.dart';
import 'package:nexkart6/screens/profile/account_screen.dart';
import 'package:nexkart6/screens/profile/addaddress.dart';
import 'package:nexkart6/screens/profile/adress_management.dart';
import 'package:nexkart6/screens/profile/edit_profile.dart';
import 'package:nexkart6/screens/profile/order_history.dart';
import 'package:nexkart6/screens/profile/profile_screen.dart';
import 'package:nexkart6/screens/search/search_list.dart';
import 'package:nexkart6/screens/onboarding_screen.dart';
import 'package:nexkart6/screens/auth/login_screen.dart';
import 'package:nexkart6/screens/categories/bueaty.dart';
import 'package:nexkart6/screens/categories/shoes.dart';
import 'package:nexkart6/screens/categories/mensware.dart';
import 'package:nexkart6/screens/categories/womensware.dart';
// import product details screen

import 'screens/home/home_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/cart/cart_screen.dart' as cart;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => cart_provider.CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // Make sure UserProvider is defined in user_provider.dart
        ChangeNotifierProvider(create: (_) => AddressProvider()),

        // add other providers here
      ],
      child: const MyApp(),
    ),
  );
}

// Example product list for passing to SearchScreen
final List<Map<String, dynamic>> allProductsList = [
  {
    'name': 'iPhone 15',
    'price': 79999,
    'image': 'assets/images/iphone_14_pro.png',
  },
  {
    'name': 'Galaxy S24',
    'price': 69999,
    'image': 'assets/images/iphone8_mobile_back.png',
  },
  {
    'name': 'MacBook Pro',
    'price': 129999,
    'image': 'assets/images/iphone_12_black.png',
  },
  {
    'name': 'Sony Headphones',
    'price': 9999,
    'image': 'assets/images/acer_laptop_var_1.png',
  },
  // Add all your products here...
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexKart',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      initialRoute: '/onboarding',
      debugShowCheckedModeBanner: false,
      routes: {
        '/mens': (context) => const Mensware(),
        '/womens': (context) => const WoMenWearScreen(),
        '/electronics': (context) => const ElectronicsScreen(),
        '/main': (context) => const MainNavigation(),
        '/shoes': (context) => const ShoesScreen(),
        '/bueaty': (context) => BeautyScreen(),
        '/toys': (context) => const ToysScreen(),
        'Faqs': (context) => const Terms(),
        '/policypage': (context) => Browse(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/account': (context) => const AccountScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/addresses': (context) => const SavedAddressesScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/cart': (context) => const cart.CartScreen(),
        '/add-address': (_) => const AddAddressScreen(),
        '/homescreen':
            (context) => HomeScreen(
              onSearchPressed: () {
                Navigator.pushNamed(context, '/search');
              },
            ),
        '/search': (context) => SearchScreen(allProducts: allProductsList),
        '/product_details': (context) {
          final product =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProductDetailsScreen(product: product);
        },
        // Add other named routes here
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Pass the onSearchPressed callback to HomeScreen to handle navigation
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onSearchPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      const WishlistScreen(),
      const cart.CartScreen(),
      const ProfileSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
