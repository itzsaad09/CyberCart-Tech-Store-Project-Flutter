import 'package:flutter/material.dart' hide SearchBar;
import 'package:cybercart/utils/search_bar.dart';
import 'package:cybercart/utils/slideshow.dart';
import 'package:flutter/services.dart';
import 'package:cybercart/utils/category_tab.dart';
import 'package:cybercart/utils/viral_products.dart';
import 'package:cybercart/utils/new_arrivals.dart';
import 'package:cybercart/utils/search_screen.dart';
import 'package:cybercart/services/product_service.dart';
import 'package:cybercart/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleCategoryChange(String category) {
    setState(() {
      _activeFilter = category;
    });
  }

  void _navigateToSearchScreen(String initialQuery) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: initialQuery),
          ),
        )
        .then((_) {
          _searchController.clear();
        });
  }

  Widget _buildMainContent() {
    if (_activeFilter == null) {
      return const Column(
        children: [
          ViralProductsComponent(),
          Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          NewArrivalsComponent(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeFilter == 'All'
                    ? 'All Products'
                    : '$_activeFilter Products',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _activeFilter = null),
                child: const Text('Clear Filter'),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Product>>(
          future: ProductService.getProducts(
            category: _activeFilter == 'All' ? '' : _activeFilter,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text("No products available."),
                ),
              );
            }
            
            // Alphabetical sort
            products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Further reduced height
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.8),
                primaryColor.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: "Search products...",
                  onTap: () =>
                      _navigateToSearchScreen(_searchController.text),
                  onSubmitted: _navigateToSearchScreen,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SlideshowWidget(),
                  CategoryTab(
                    selectedCategory: _activeFilter ?? '',
                    onCategorySelected: _handleCategoryChange,
                  ),
                  _buildMainContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}