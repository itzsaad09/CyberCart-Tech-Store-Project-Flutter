import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final line1 = '$street${addressLine2 != null && addressLine2!.isNotEmpty ? ', $addressLine2' : ''}';
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

  // --- Address State ---
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

  final List<ShippingAddress> _availableAddresses = [
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

  // --- Payment State ---
  PaymentMethod _selectedPayment = const PaymentMethod(
    type: 'Cash on Delivery',
    details: 'Pay upon delivery',
  );

  final List<PaymentMethod> _availablePayments = [
    const PaymentMethod(type: 'Cash on Delivery', details: 'Pay upon delivery'),
    const PaymentMethod(type: 'Card', details: 'Visa ending in 4242'),
  ];

  // --- Controllers (Address) ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'Pakistan');

  // --- Controllers (Card) ---
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

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
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  bool _isCashOnDelivery(PaymentMethod method) => method.type == 'Cash on Delivery';
  bool _isSavedCard(PaymentMethod method) => method.type == 'Card';

  void _onStepTapped(int step) => setState(() => _currentStep = step);

  void _onStepContinue() {
    if (_currentStep < _getSteps().length - 1) {
      setState(() => _currentStep++);
    } else {
      _placeOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _placeOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
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
            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(_selectedAddress.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_selectedAddress.street}, ${_selectedAddress.city}'),
            trailing: const Icon(Icons.edit, color: Colors.grey),
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
            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(_isSavedCard(_selectedPayment) ? Icons.credit_card_outlined : Icons.payments_outlined),
            title: Text(_selectedPayment.type, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_selectedPayment.details),
            trailing: const Icon(Icons.edit, color: Colors.grey),
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
        Text('Total Payable Amount:', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Rs. ${widget.totalAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const Divider(height: 30),
        _buildReviewSection(context, 'Ship To', _selectedAddress.displayDetails, Icons.location_on),
        const Divider(),
        _buildReviewSection(context, 'Pay With', '${_selectedPayment.type}\n${_selectedPayment.details}', Icons.payment),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context, String title, String detail, IconData icon) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
        currentStep: _currentStep,
        onStepTapped: _onStepTapped,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _getSteps(),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'PLACE ORDER' : 'CONTINUE'),
                ),
                if (_currentStep != 0)
                  TextButton(onPressed: details.onStepCancel, child: const Text('BACK')),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Modals & Functions ---

void _showAddressSelector(BuildContext context, {required _CheckoutScreenState state}) {
  showModalBottomSheet(
    context: context,
    builder: (bc) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select Shipping Address', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          ...state._availableAddresses.map((address) => ListTile(
                title: Text(address.name),
                subtitle: Text('${address.street}, ${address.city}'),
                onTap: () {
                  state.setState(() => state._selectedAddress = address);
                  Navigator.pop(context);
                },
              )),
          TextButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add New Address'),
            onPressed: () {
              Navigator.pop(context);
              _showAddAddressForm(context, state: state);
            },
          )
        ],
      ),
    ),
  );
}

void _showAddAddressForm(BuildContext context, {required _CheckoutScreenState state, ShippingAddress? addressToEdit}) {
  final isEditing = addressToEdit != null;
  if (isEditing) {
    state._nameController.text = addressToEdit.name;
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
    builder: (bc) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(isEditing ? 'Edit Shipping Address' : 'Add New Shipping Address', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 32),
            _buildTextField(controller: state._nameController, label: 'Full Name', hint: 'John Doe'),
            const SizedBox(height: 16),
            _buildTextField(controller: state._address1Controller, label: 'Address Line 1', hint: '123 Main St'),
            const SizedBox(height: 16),
            _buildTextField(controller: state._address2Controller, label: 'Address Line 2 (Optional)', hint: 'Apt 4B'),
            const SizedBox(height: 16),
            _buildTextField(controller: state._phoneController, label: 'Phone Number', hint: 'e.g., +92 123 4567890', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: state._cityController, label: 'City', hint: 'Lahore')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: state._stateController, label: 'State/Province', hint: 'Punjab')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: state._postalController, label: 'Postal Code', hint: '90210', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: state._countryController, label: 'Country', hint: 'Pakistan')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newAddr = ShippingAddress(
                    name: state._nameController.text,
                    street: state._address1Controller.text,
                    addressLine2: state._address2Controller.text,
                    phone: state._phoneController.text,
                    city: state._cityController.text,
                    state: state._stateController.text,
                    postalCode: state._postalController.text,
                    country: state._countryController.text,
                  );
                  state.setState(() {
                    if (!isEditing) state._availableAddresses.add(newAddr);
                    state._selectedAddress = newAddr;
                  });
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'UPDATE ADDRESS' : 'SAVE ADDRESS'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

void _showPaymentTypeSelector(BuildContext context, {required _CheckoutScreenState state}) {
  showModalBottomSheet(
    context: context,
    builder: (bc) => Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.payments_outlined),
          title: const Text('Cash on Delivery'),
          onTap: () {
            state.setState(() => state._selectedPayment = state._availablePayments[0]);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.credit_card_outlined),
          title: const Text('Credit/Debit Card'),
          onTap: () {
            Navigator.pop(context);
            _showCardSelector(context, state: state);
          },
        ),
      ],
    ),
  );
}

void _showCardSelector(BuildContext context, {required _CheckoutScreenState state}) {
  final savedCards = state._availablePayments.where(state._isSavedCard).toList();
  showModalBottomSheet(
    context: context,
    builder: (bc) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select Saved Card', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          ...savedCards.map((card) => ListTile(
                title: Text(card.type),
                subtitle: Text(card.details),
                onTap: () {
                  state.setState(() => state._selectedPayment = card);
                  Navigator.pop(context);
                },
              )),
          TextButton.icon(
            icon: const Icon(Icons.add_card),
            label: const Text('Add New Card'),
            onPressed: () {
              Navigator.pop(context);
              _showAddCardForm(context, state: state);
            },
          )
        ],
      ),
    ),
  );
}

void _showAddCardForm(BuildContext context, {required _CheckoutScreenState state}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bc) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Add Card Details', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(height: 32),
            _buildTextField(controller: state._cardNameController, label: 'Cardholder Name', hint: 'John Doe'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: state._cardNumberController,
              label: 'Card Number',
              hint: 'XXXX XXXX XXXX XXXX',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                CardNumberFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: state._cardExpiryController,
                    label: 'Expiry',
                    hint: 'MM/YY',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      CardExpiryFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: state._cardCvvController,
                    label: 'CVV',
                    hint: '***',
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final last4 = state._cardNumberController.text.replaceAll(' ', '');
                  final newCard = PaymentMethod(
                    type: 'Card',
                    details: 'Visa ending in ${last4.substring(last4.length - 4)}',
                  );
                  state.setState(() {
                    state._availablePayments.add(newCard);
                    state._selectedPayment = newCard;
                  });
                  Navigator.pop(context);
                },
                child: const Text('SAVE CARD'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  });
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var index = i + 1;
      if (index % 4 == 0 && index != text.length) buffer.write(' ');
    }
    return newValue.copyWith(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) buffer.write('/');
    }
    return newValue.copyWith(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}