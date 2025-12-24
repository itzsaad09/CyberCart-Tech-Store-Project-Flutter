import 'package:flutter/material.dart';

import 'package:cybercart/models/product_model.dart';

import 'package:cybercart/utils/product_view.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';

  final List<Product> _allProducts = [
    const Product(
      id: 'S001',
      name: 'Airpods Pro Max Headset',
      price: 9999.0,
      imageUrl: '',
      category: 'Headphones',
    ),
    const Product(
      id: 'S002',
      name: 'Type-C Fast Charger Cable',
      price: 599.0,
      imageUrl: '',
      category: 'Charger & Cables',
    ),
    const Product(
      id: 'S003',
      name: 'Gaming Mouse Pad XXL',
      price: 1450.0,
      imageUrl: '',
      category: 'Gaming',
    ),
    const Product(
      id: 'S004',
      name: 'Smart Watch Series 8',
      price: 7999.0,
      imageUrl: '',
      category: 'Smart Watches',
    ),
    const Product(
      id: 'S005',
      name: 'Mini Portable Speaker',
      price: 2100.0,
      imageUrl: '',
      category: 'Speakers',
    ),
    const Product(
      id: 'V001',
      name: 'D106 Mooon Mobile Phone Cooler',
      price: 3500.0,
      imageUrl: '',
      category: 'Smart Watches',
    ),
    const Product(
      id: 'N001',
      name: 'JBL S278 Wireless Bluetooth Speaker',
      price: 2450.0,
      imageUrl: '',
      category: 'Speakers',
    ),
  ];

  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery.isNotEmpty) {
      _searchController.text = widget.initialQuery;
      _currentQuery = widget.initialQuery;
    }

    _searchController.addListener(_filterResults);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _filterResults());
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResults);
    _searchController.dispose();
    super.dispose();
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _currentQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
        return;
      }

      _searchResults = _allProducts.where((product) {
        final nameLower = product.name.toLowerCase();
        final categoryLower = product.category.toLowerCase();
        return nameLower.contains(query) || categoryLower.contains(query);
      }).toList();
    });
  }

  void _handleProductTap(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductViewScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search CyberCart...",
            border: InputBorder.none,

            suffixIcon: _currentQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _filterResults();
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            _filterResults();
          },
        ),
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_currentQuery.isEmpty) {
      return _buildSuggestions(context);
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults(context);
    }

    return _buildResultsList(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          Wrap(
            spacing: 8.0,
            children: ['Airpods', 'Charger', 'Smart Watch', 'Gaming'].map((
              tag,
            ) {
              return ActionChip(
                label: Text(tag),
                onPressed: () {
                  _searchController.text = tag;

                  _filterResults();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ),
          title: Text(product.name),
          subtitle: Text(
            'Rs. ${product.price.toStringAsFixed(2)} | ${product.category}',
          ),
          onTap: () => _handleProductTap(product),
        );
      },
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_currentQuery"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search terms.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
