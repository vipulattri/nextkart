import 'package:flutter/material.dart';

class SearchResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredProducts;
  final void Function(Map<String, dynamic>) onProductTap;

  const SearchResultsList({
    super.key,
    required this.filteredProducts,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          leading: Image.asset(product['image'], width: 50),
          title: Text(product['name']),
          subtitle: Text('₹${product['price']}'),
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
