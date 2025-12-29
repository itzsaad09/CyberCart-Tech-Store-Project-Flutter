import 'package:flutter/material.dart';
import 'package:cybercart/models/product_model.dart';
import 'package:cybercart/utils/product_view.dart';
import 'package:cybercart/services/product_service.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  List<Product> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery.isNotEmpty) {
      _searchController.text = widget.initialQuery;
      _currentQuery = widget.initialQuery;
      // Fetch initial results if a query was passed from HomeScreen
      _performSearch(widget.initialQuery);
    }

    // Listener for real-time search as the user types
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query != _currentQuery) {
        _performSearch(query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hits the backend via ProductService to get matching products
  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    setState(() {
      _currentQuery = trimmedQuery;
    });

    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Passes the keyword to req.query.keyword in your backend controller
      final results = await ProductService.getProducts(keyword: trimmedQuery);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
                    },
                  )
                : null,
          ),
          onSubmitted: (value) => _performSearch(value),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _buildBody(context),
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
            children: ['Airpods', 'Charger', 'Smart Watch', 'Gaming'].map((tag) {
              return ActionChip(
                label: Text(tag),
                onPressed: () {
                  _searchController.text = tag;
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, size: 20),
                    ),
                  )
                : const Icon(Icons.image_outlined, size: 20, color: Colors.grey),
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
          const Icon(Icons.sentiment_dissatisfied_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No results found for "$_currentQuery"', style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}