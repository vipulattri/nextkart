import 'package:flutter/material.dart';
import 'package:nexkart6/screens/search/search_results.dart'; // import your new widget

class SearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts;
  const SearchScreen({super.key, required this.allProducts});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.allProducts;
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.allProducts;
      } else {
        _filteredProducts =
            widget.allProducts
                .where(
                  (product) => product['name'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches = _recentSearches.sublist(0, 5);
          }
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  void _onProductTap(Map<String, dynamic> product) {
    Navigator.pushNamed(context, '/product_details', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Recent Searches",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ActionChip(
                      label: Text(_recentSearches[index]),
                      onPressed: () => _performSearch(_recentSearches[index]),
                    ),
                  );
                },
              ),
            ),
          ],
          Expanded(
            child: SearchResultsList(
              filteredProducts: _filteredProducts,
              onProductTap: _onProductTap,
            ),
          ),
        ],
      ),
    );
  }
}
