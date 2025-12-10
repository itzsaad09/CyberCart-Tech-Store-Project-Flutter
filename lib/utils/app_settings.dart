import 'package:flutter/material.dart';
import 'package:cybercart/main.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;

  final String _currentLanguage = 'English (US)';

  @override
  void initState() {
    super.initState();
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeMode currentTheme,
    Function(ThemeMode) setTheme,
  ) {
    bool isSelected = currentTheme == mode;
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
      onTap: () => setTheme(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.of(context);
    final currentTheme = themeController.themeMode;
    final setTheme = themeController.setThemeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('App Settings'), elevation: 0.5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    'System Default',
                    ThemeMode.system,
                    currentTheme,
                    setTheme,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildThemeOption(
                    context,
                    'Light Mode',
                    ThemeMode.light,
                    currentTheme,
                    setTheme,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildThemeOption(
                    context,
                    'Dark Mode',
                    ThemeMode.dark,
                    currentTheme,
                    setTheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Product & Promotions'),
                subtitle: const Text('Receive alerts for deals and updates'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Language',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('App Language'),

                trailing: Text(
                  _currentLanguage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                onTap: null,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('App Version'),
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: null,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
