import 'package:flutter/material.dart';

class ShippingAddress {
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final String? addressLine2;
  final String? phone;
  final String? state;
  final String? country;

  const ShippingAddress({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.addressLine2,
    this.phone,
    this.state,
    this.country,
  });

  String get displayDetails {
    final line1 =
        '$street${addressLine2 != null && addressLine2!.isNotEmpty ? ', $addressLine2' : ''}';
    final line2 = '$city, ${state ?? postalCode}, ${country ?? ''}';
    final line3 = 'Phone: ${phone ?? 'N/A'}';
    return '$line1\n$line2\n$line3';
  }
}

class PaymentMethod {
  final String type;
  final String details;

  const PaymentMethod({required this.type, required this.details});
}

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  ShippingAddress _selectedAddress = const ShippingAddress(
    name: 'John Doe',
    street: '123 Tech Avenue',
    city: 'San Francisco',
    postalCode: '94107',
    addressLine2: 'Apt 101',
    phone: '+92 300 1234567',
    state: 'CA',
    country: 'USA',
  );

  List<ShippingAddress> _availableAddresses = [
    const ShippingAddress(
      name: 'John Doe',
      street: '123 Tech Avenue',
      city: 'San Francisco',
      postalCode: '94107',
      addressLine2: 'Apt 101',
      phone: '+92 300 1234567',
      state: 'CA',
      country: 'USA',
    ),
  ];

  PaymentMethod _selectedPayment = const PaymentMethod(
    type: 'Cash on Delivery',
    details: 'Pay upon delivery',
  );

  List<PaymentMethod> _availablePayments = [
    const PaymentMethod(type: 'Cash on Delivery', details: 'Pay upon delivery'),
    const PaymentMethod(type: 'Card', details: 'Visa ending in 4242'),
    const PaymentMethod(type: 'Card', details: 'MasterCard ending in 1001'),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'Pakistan',
  );

  bool _isCashOnDelivery(PaymentMethod method) =>
      method.type == 'Cash on Delivery';
  bool _isSavedCard(PaymentMethod method) => method.type == 'Card';

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onStepTapped(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _onStepContinue() {
    if (_currentStep < _getSteps().length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _placeOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _placeOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order placed successfully to ${_selectedAddress.city} with ${_selectedPayment.type}!',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Shipping Address'),
        content: _buildAddressStep(),
        isActive: _currentStep == 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Payment Method'),
        content: _buildPaymentStep(),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Review & Pay'),
        content: _buildReviewStep(),
        isActive: _currentStep == 2,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              _selectedAddress.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${_selectedAddress.street}, ${_selectedAddress.city} ${_selectedAddress.postalCode}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showAddressSelector(context, state: this),
            ),
            onTap: () => _showAddressSelector(context, state: this),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add New Address'),
          onPressed: () => _showAddAddressForm(context, state: this),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _isSavedCard(_selectedPayment)
                ? const Icon(Icons.credit_card_outlined)
                : const Icon(Icons.payments_outlined),
            title: Text(
              _selectedPayment.type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_selectedPayment.details),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showPaymentTypeSelector(context, state: this),
            ),
            onTap: () => _showPaymentTypeSelector(context, state: this),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Payable Amount:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Rs. ${widget.totalAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Divider(height: 30),
        _buildReviewSection(
          context,
          'Ship To',
          '${_selectedAddress.name}\n${_selectedAddress.displayDetails}',
          Icons.location_on,
        ),
        const Divider(),
        _buildReviewSection(
          context,
          'Pay With',
          '${_selectedPayment.type}\n(${_selectedPayment.details})',
          Icons.payment,
        ),
      ],
    );
  }

  Widget _buildReviewSection(
    BuildContext context,
    String title,
    String detail,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), elevation: 0.5),
      body: Stepper(
        type: StepperType.vertical,
        physics: const ClampingScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: _onStepTapped,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _getSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _currentStep == _getSteps().length - 1;

          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? 'PLACE ORDER' : 'CONTINUE'),
                ),
                if (_currentStep != 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showAddressSelector(
  BuildContext context, {
  required _CheckoutScreenState state,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Shipping Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: state._availableAddresses.map((address) {
                  return ListTile(
                    leading: Radio(
                      value: address,
                      groupValue: state._selectedAddress,
                      onChanged: (ShippingAddress? newAddress) {
                        if (newAddress != null) {
                          state.setState(() {
                            state._selectedAddress = newAddress;
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                    title: Text(address.name),
                    subtitle: Text('${address.street}, ${address.city}'),
                    onTap: () {
                      state.setState(() {
                        state._selectedAddress = address;
                      });
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddAddressForm(
                          state.context,
                          state: state,
                          addressToEdit: address,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            TextButton.icon(
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add New Address'),
              onPressed: () {
                Navigator.pop(context);
                _showAddAddressForm(state.context, state: state);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showAddAddressForm(
  BuildContext context, {
  required _CheckoutScreenState state,
  ShippingAddress? addressToEdit,
}) {
  final isEditing = addressToEdit != null;

  if (isEditing) {
    state._nameController.text = addressToEdit!.name;
    state._address1Controller.text = addressToEdit.street;
    state._address2Controller.text = addressToEdit.addressLine2 ?? '';
    state._phoneController.text = addressToEdit.phone ?? '';
    state._cityController.text = addressToEdit.city;
    state._stateController.text = addressToEdit.state ?? '';
    state._postalController.text = addressToEdit.postalCode;
    state._countryController.text = addressToEdit.country ?? 'Pakistan';
  } else {
    state._nameController.clear();
    state._address1Controller.clear();
    state._address2Controller.clear();
    state._phoneController.clear();
    state._cityController.clear();
    state._stateController.clear();
    state._postalController.clear();
    state._countryController.text = 'Pakistan';
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEditing
                          ? 'Edit Shipping Address'
                          : 'Add New Shipping Address',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24.0,
                    16.0,
                    24.0,
                    24.0 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: state._nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: state._address1Controller,
                        label: 'Address Line 1',
                        hint: '123 Main St',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: state._address2Controller,
                        label: 'Address Line 2 (Optional)',
                        hint: 'Apt 4B',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: state._phoneController,
                        label: 'Phone Number',
                        hint: 'e.g., +92 123 4567890',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: state._cityController,
                              label: 'City',
                              hint: 'Lahore',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: state._stateController,
                              label: 'State/Province',
                              hint: 'Punjab',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: state._postalController,
                              label: 'Postal Code',
                              hint: '90210',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: state._countryController,
                              label: 'Country',
                              hint: 'Pakistan',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _saveNewAddress(
                              state,
                              isEditing: isEditing,
                              oldAddress: addressToEdit,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Update Address' : 'Save Address',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

void _saveNewAddress(
  _CheckoutScreenState state, {
  bool isEditing = false,
  ShippingAddress? oldAddress,
}) {
  final newAddress = ShippingAddress(
    name: state._nameController.text.trim(),
    street: state._address1Controller.text.trim(),
    addressLine2: state._address2Controller.text.trim(),
    phone: state._phoneController.text.trim(),
    city: state._cityController.text.trim(),
    state: state._stateController.text.trim(),
    postalCode: state._postalController.text.trim(),
    country: state._countryController.text.trim(),
  );

  state.setState(() {
    if (isEditing && oldAddress != null) {
      final index = state._availableAddresses.indexWhere(
        (addr) => addr == oldAddress,
      );
      if (index != -1) {
        state._availableAddresses[index] = newAddress;
      }
    } else {
      state._availableAddresses.add(newAddress);
    }
    state._selectedAddress = newAddress;
  });

  ScaffoldMessenger.of(state.context).showSnackBar(
    SnackBar(
      content: Text(
        '${isEditing ? 'Updated' : 'New'} address for ${newAddress.name} saved and selected.',
      ),
    ),
  );
}

void _showPaymentTypeSelector(
  BuildContext context, {
  required _CheckoutScreenState state,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Payment Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Cash on Delivery'),
              trailing: state._isCashOnDelivery(state._selectedPayment)
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                state.setState(() {
                  PaymentMethod cod = state._availablePayments.firstWhere(
                    state._isCashOnDelivery,
                    orElse: () => const PaymentMethod(
                      type: 'Cash on Delivery',
                      details: 'Pay upon delivery',
                    ),
                  );
                  state._selectedPayment = cod;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Credit/Debit Card'),
              trailing: state._isSavedCard(state._selectedPayment)
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _showCardSelector(state.context, state: state);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showCardSelector(
  BuildContext context, {
  required _CheckoutScreenState state,
}) {
  final savedCards = state._availablePayments
      .where(state._isSavedCard)
      .toList();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Saved Card',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: savedCards.map((card) {
                  return RadioListTile<PaymentMethod>(
                    title: Text(card.type),
                    subtitle: Text(card.details),
                    value: card,
                    groupValue: state._selectedPayment,
                    onChanged: (PaymentMethod? newPayment) {
                      if (newPayment != null) {
                        state.setState(() {
                          state._selectedPayment = newPayment;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            TextButton.icon(
              icon: const Icon(Icons.add_card),
              label: const Text('Add New Card'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(state.context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Add Card form... (Placeholder)'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
