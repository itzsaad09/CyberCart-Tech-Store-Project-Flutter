import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class MyAddressesScreen extends StatefulWidget {
  final String token;
  final String userId;

  const MyAddressesScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  List<ShippingAddress> _addresses = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await AddressService.fetchAddresses(widget.userId);
      setState(() {
        _addresses = results;
      });
    } catch (e) {
      debugPrint("Address Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSaveAddress({ShippingAddress? existingAddress}) async {
    final newAddress = ShippingAddress(
      id: existingAddress?.id,
      fullName: _nameController.text,
      addressLine1: _address1Controller.text,
      addressLine2: _address2Controller.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalController.text,
      phoneNumber: _phoneController.text,
      country: _countryController.text,
    );

    bool success = false;
    if (existingAddress != null) {
      success = await AddressService.editAddress(
        widget.token,
        widget.userId,
        newAddress,
      );
    } else {
      success = await AddressService.addAddress(widget.userId, newAddress);
    }

    if (success) {
      _fetchAddresses();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingAddress != null
                ? 'Address updated!'
                : 'Address saved successfully!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save address.')));
    }
  }

  void _deleteAddress(int index) async {
    final addressId = _addresses[index].id;
    if (addressId == null) return;

    final success = await AddressService.deleteAddress(
      widget.token,
      widget.userId,
      addressId,
    );

    if (success) {
      _fetchAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address deleted permanently'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete address')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressCard(address, index, isDark);
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showAddressForm(),
          icon: const Icon(Icons.add),
          label: const Text('ADD NEW ADDRESS'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No addresses saved yet',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address, int index, bool isDark) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit')
                      _showAddressForm(address: address, index: index);
                    if (value == 'delete') _deleteAddress(index);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${address.addressLine1}${address.addressLine2 != null && address.addressLine2!.isNotEmpty ? ', ${address.addressLine2}' : ''}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              '${address.city}, ${address.state ?? ''} ${address.postalCode}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Country: ${address.country ?? 'Pakistan'}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${address.phoneNumber ?? 'N/A'}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressForm({ShippingAddress? address, int? index}) {
    final isEditing = address != null;
    if (isEditing) {
      _nameController.text = address.fullName;
      _address1Controller.text = address.addressLine1;
      _address2Controller.text = address.addressLine2 ?? '';
      _cityController.text = address.city;
      _stateController.text = address.state ?? '';
      _postalController.text = address.postalCode;
      _phoneController.text = address.phoneNumber ?? '';
      _countryController.text = address.country ?? '';
    } else {
      _nameController.clear();
      _address1Controller.clear();
      _address2Controller.clear();
      _cityController.clear();
      _stateController.clear();
      _postalController.clear();
      _phoneController.clear();
      _countryController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Address' : 'New Address',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _buildField(_nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildField(
                _address1Controller,
                'Street Address',
                Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                _address2Controller,
                'Apt / Suite (Optional)',
                Icons.apartment_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(_countryController, 'Country', Icons.public),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _cityController,
                      'City',
                      Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      _stateController,
                      'State',
                      Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _postalController,
                      'Postal Code',
                      Icons.markunread_mailbox_outlined,
                      type: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      _phoneController,
                      'Phone',
                      Icons.phone_android,
                      type: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleSaveAddress(existingAddress: address),
                  child: Text(isEditing ? 'UPDATE' : 'SAVE ADDRESS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
