import 'package:flutter/material.dart' hide SearchBar;
import 'package:cybercart/utils/location_bar.dart';
import 'package:cybercart/utils/search_bar.dart'; // Must contain onSubmitted prop
import 'package:cybercart/utils/slideshow.dart';
import 'package:flutter/services.dart';
import 'package:cybercart/utils/category_tab.dart'; // Assuming this is CategoryChipsComponent
import 'package:cybercart/utils/viral_products.dart';
import 'package:cybercart/utils/new_arrivals.dart';
// NEW: Import SearchScreen (assuming path)
import 'package:cybercart/utils/search_screen.dart'; 


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State from the second block
  String _selectedCategory = ''; 
  final TextEditingController _searchController = TextEditingController(); 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Method from the first block
  void _handleCategoryChange(String category) {
    setState(() {
      _selectedCategory = category;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Filtering products by: $category')));
  }

  // Method from the second block
  void _navigateToSearchScreen(String initialQuery) {
    if (initialQuery.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          // Assuming SearchScreen can accept an initialQuery parameter
          builder: (context) => SearchScreen(initialQuery: initialQuery),
        ),
      ).then((_) {
        _searchController.clear(); 
      });
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a search term.')),
        );
    }
  }

  // Placeholder from the second block (Integrated for completeness)
  Widget WishlistButton({required VoidCallback onTap}) {
    return IconButton(
      icon: const Icon(Icons.favorite_border, color: Colors.white),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness = MediaQuery.of(
      context,
    ).platformBrightness;
    final Brightness iconBrightness = platformBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.9),
                  primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 5.0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: iconBrightness,
                systemNavigationBarIconBrightness: iconBrightness,
              ),
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 5.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const LocationBar(location: "San Francisco, CA"),
                          WishlistButton(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wishlist button tapped!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // MODIFIED: SearchBar now uses onSubmitted for navigation
                      SearchBar(
                        controller: _searchController,
                        hintText: "Search products...",
                        // This triggers navigation when Enter is pressed or search icon is tapped.
                        onSubmitted: _navigateToSearchScreen, 
                        onChanged: (value) {},
                      ),
                    ],
                  ),
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

                  // Assuming CategoryTab is the CategoryChipsComponent
                  CategoryTab(onCategorySelected: _handleCategoryChange), 

                  const ViralProductsComponent(),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),

                  const NewArrivalsComponent(),

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