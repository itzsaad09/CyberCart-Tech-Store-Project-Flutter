import 'package:cybercart/utils/login_screen.dart';
import 'package:cybercart/utils/signup_screen.dart';
import 'package:cybercart/utils/myorders.dart';
import 'package:cybercart/utils/faqs_screen.dart';
import 'package:cybercart/utils/app_settings.dart';
import 'package:cybercart/utils/whishlist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum AuthViewState { profile, login, signup }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _loggedInKey = 'is_user_logged_in';

  bool _isLoggedIn = false;
  bool _isLoading = true;
  AuthViewState _currentView = AuthViewState.login;

  // NEW STATE: To hold the local file of the selected profile picture
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  void _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    // You could also load the saved profile picture path here
    // final String? imagePath = prefs.getString('_profileImageKey');

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _currentView = isLoggedIn ? AuthViewState.profile : AuthViewState.login;
        _isLoading = false;
        // if (imagePath != null) _profileImageFile = File(imagePath);
      });
    }
  }

  void _handleLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);

    setState(() {
      _isLoggedIn = true;
      _currentView = AuthViewState.profile;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out of CyberCart?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(_loggedInKey, false);
                // Optionally clear profile image state as well:
                // await prefs.remove('_profileImageKey');

                setState(() {
                  _isLoggedIn = false;
                  _profileImageFile = null; // Clear image state on logout
                  _currentView = AuthViewState.login;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You have been logged out.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSignup() {
    setState(() {
      _currentView = AuthViewState.signup;
    });
  }

  void _navigateToLogin() {
    setState(() {
      _currentView = AuthViewState.login;
    });
  }

  // --- NEW: Image Picker Logic ---

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // FINALIZED: Implementation of the image picking logic
  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        _profileImageFile = imageFile;
      });

      // TODO: 1. Upload imageFile to your server/storage.
      // TODO: 2. Save the resulting image URL/path to SharedPreferences here.

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated from ${source.name}!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image selected.')));
    }
  }

  void _changeProfilePicture() {
    _showImageSourcePicker();
  }

  // --- END NEW LOGIC ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isLoggedIn) {
      return KeyedSubtree(
        key: const ValueKey('profile_content'),
        child: _buildProfileContent(context),
      );
    }

    switch (_currentView) {
      case AuthViewState.login:
        return KeyedSubtree(
          key: const ValueKey('login_screen'),
          child: LoginScreen(
            onLoginSuccess: _handleLoginSuccess,
            onNavigateToSignup: _navigateToSignup,
          ),
        );
      case AuthViewState.signup:
        return KeyedSubtree(
          key: const ValueKey('signup_screen'),
          child: SignupScreen(
            onSignupSuccess: _navigateToLogin,
            onNavigateToLogin: _navigateToLogin,
          ),
        );
      case AuthViewState.profile:
        return KeyedSubtree(
          key: const ValueKey('login_screen_fallback'),
          child: LoginScreen(
            onLoginSuccess: _handleLoginSuccess,
            onNavigateToSignup: _navigateToSignup,
          ),
        );
    }
  }

  Widget _buildProfileContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              width: double.infinity,
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              child: Column(
                children: [
                  // MODIFIED: Make the CircleAvatar tappable and display the image
                  GestureDetector(
                    onTap: _changeProfilePicture, // Calls the source picker
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      // Display the selected image if _profileImageFile is set
                      backgroundImage: _profileImageFile != null
                          ? FileImage(_profileImageFile!)
                          : null,
                      child: _profileImageFile == null
                          ? const Icon(
                              // Show icon only if no image is selected
                              Icons.person_rounded,
                              size: 50,
                              color: Colors.blueGrey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CyberUser',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'cyberuser@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionCard(
                        context,
                        icon: Icons.paid_outlined,
                        title: 'Payments',
                        onTap: () {},
                      ),
                      _buildQuickActionCard(
                        context,
                        icon: Icons.local_offer_outlined,
                        title: 'Coupons',
                        onTap: () {},
                      ),
                      _buildQuickActionCard(
                        context,
                        icon: Icons.star_border_rounded,
                        title: 'Reviews',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Account & Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          context,
                          icon: Icons.shopping_bag_outlined,
                          title: 'My Orders',
                          subtitle: 'Track, return, or buy again',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          context,
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          subtitle: 'Your saved items',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WishlistScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          context,
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          subtitle: 'Manage shipping locations',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          context,
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          subtitle: 'Theme, notifications, language',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AppSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          context,
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact us',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FaqsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, thickness: 0.5),
    );
  }
}
