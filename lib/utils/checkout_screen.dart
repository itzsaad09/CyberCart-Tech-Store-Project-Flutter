import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';

class PaymentMethod {
  final String type;
  final String details;

  const PaymentMethod({required this.type, required this.details});
}

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<dynamic> cartItems;

  const CheckoutScreen({super.key, required this.totalAmount, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  
  List<ShippingAddress> _availableAddresses = [];
  bool _isLoadingAddresses = true;
  ShippingAddress? _selectedAddress;

  
  DateTime? _selectedDeliveryDate;
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    "08:00 AM - 09:00 AM", "09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM", "03:00 PM - 04:00 PM", "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM", "06:00 PM - 07:00 PM", "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM", "09:00 PM - 10:00 PM", "10:00 PM - 11:00 PM",
    "11:00 PM - 12:00 AM",
  ];

  DateTime get _minDate => DateTime.now().add(const Duration(days: 3));
  DateTime get _maxDate => DateTime.now().add(const Duration(days: 10));

  
  PaymentMethod _selectedPayment = const PaymentMethod(
    type: 'Cash on Delivery',
    details: 'Pay upon delivery',
  );

  final List<PaymentMethod> _availablePayments = [
    const PaymentMethod(type: 'Cash on Delivery', details: 'Pay upon delivery'),
    const PaymentMethod(type: 'Card', details: 'Visa ending in 4242'),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'Pakistan');
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddresses(); 
  }

  
  Future<void> _fetchAddresses() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    if (!mounted) return;
    setState(() => _isLoadingAddresses = true);
    
    try {
      final results = await AddressService.fetchAddresses(auth.userId!);
      setState(() {
        _availableAddresses = results;
        if (_availableAddresses.isNotEmpty && _selectedAddress == null) {
          _selectedAddress = _availableAddresses[0];
        }
      });
    } catch (e) {
      debugPrint("Address Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

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
    if (_currentStep == 0 && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a shipping address.')),
      );
      return;
    }
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


  Future<void> _placeOrder() async {
    if (_selectedDeliveryDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please schedule your delivery.')),
      );
      return;
    }
    
    void _showSuccessAnimation() {
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: OrderSuccessDialog(),
          );
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop(true);
        }
      });
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    const double shippingFee = 150.0;
    
    
    final String paymentMethodKey = _selectedPayment.type == 'Card' 
        ? 'credit_card' 
        : 'cash_on_delivery';

    
    final result = await OrderService.placeOrder(
      userId: auth.userId!,
      token: auth.token!,
      items: widget.cartItems,
      amount: widget.totalAmount,
      shippingCharges: shippingFee,
      address: {
        'fullName': _selectedAddress!.fullName,
        'addressLine1': _selectedAddress!.addressLine1,
        'addressLine2': _selectedAddress!.addressLine2,
        'city': _selectedAddress!.city,
        'state': _selectedAddress!.state,
        'postalCode': _selectedAddress!.postalCode,
        'phoneNumber': _selectedAddress!.phoneNumber,
      },
      paymentMethod: paymentMethodKey,
      deliveryDate: _selectedDeliveryDate!,
      deliveryTimeSlot: _selectedTimeSlot!,
      cardDetails: paymentMethodKey == 'credit_card' ? {
        'cardName': _cardNameController.text,
        'cardNumber': _cardNumberController.text,
        'expiryDate': _cardExpiryController.text,
      } : null,
    );

    if (result['success'] == true) {
      _showSuccessAnimation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to place order'), backgroundColor: Colors.red),
      );
    }
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Shipping Address'),
        content: _isLoadingAddresses 
            ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())) 
            : _buildAddressStep(),
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
        content: Column(
          children: [
            _buildScheduleDeliverySection(),
            const SizedBox(height: 20),
            _buildReviewStep(),
          ],
        ),
        isActive: _currentStep == 2,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildScheduleDeliverySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Date', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _minDate,
                            firstDate: _minDate,
                            lastDate: _maxDate,
                          );
                          if (picked != null) setState(() => _selectedDeliveryDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDeliveryDate == null ? 'dd/mm/yyyy' : "${_selectedDeliveryDate!.day}/${_selectedDeliveryDate!.month}/${_selectedDeliveryDate!.year}",
                                style: TextStyle(color: _selectedDeliveryDate == null ? Colors.grey : null, fontSize: 12),
                              ),
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time Slot', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Select Slot', style: TextStyle(fontSize: 12)),
                            value: _selectedTimeSlot,
                            items: _timeSlots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) => setState(() => _selectedTimeSlot = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAddress != null)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(_selectedAddress!.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${_selectedAddress!.addressLine1}, ${_selectedAddress!.city}'),
              trailing: const Icon(Icons.edit, color: Colors.grey),
              onTap: () => _showAddressSelector(context, state: this),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("No saved addresses found.", style: TextStyle(color: Colors.grey)),
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
    
    const double freeShippingThreshold = 1999.0;
    const double standardShippingFee = 150.0;

    
    double appliedShipping = widget.totalAmount >= freeShippingThreshold ? 0.0 : standardShippingFee;
    double finalPayable = widget.totalAmount + appliedShipping;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal:'),
            Text('Rs. ${widget.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shipping Fee:'),
            Text(appliedShipping == 0 ? 'FREE' : 'Rs. ${appliedShipping.toStringAsFixed(2)}', 
                 style: TextStyle(color: appliedShipping == 0 ? Colors.green : null)),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Payable:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('Rs. ${finalPayable.toStringAsFixed(2)}', 
                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontWeight: FontWeight.bold, 
                   color: Theme.of(context).primaryColor
                 )),
          ],
        ),
        const Divider(height: 30),
        if (_selectedAddress != null)
          _buildReviewSection(
            context,
            'Ship To',
            '${_selectedAddress!.fullName}\n${_selectedAddress!.addressLine1}${_selectedAddress!.addressLine2 != null && _selectedAddress!.addressLine2!.isNotEmpty ? ', ${_selectedAddress!.addressLine2}' : ''}\n${_selectedAddress!.city}, ${_selectedAddress!.state ?? ''} ${_selectedAddress!.postalCode}',
            Icons.location_on,
          ),
        const Divider(),
        _buildReviewSection(
          context,
          'Pay With',
          '${_selectedPayment.type}\n${_selectedPayment.details}',
          Icons.payment,
        ),
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
                ElevatedButton(onPressed: details.onStepContinue, child: Text(_currentStep == 2 ? 'PLACE ORDER' : 'CONTINUE')),
                if (_currentStep != 0) TextButton(onPressed: details.onStepCancel, child: const Text('BACK')),
              ],
            ),
          );
        },
      ),
    );
  }
}



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
          if (state._availableAddresses.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text("No saved addresses.")),
          ...state._availableAddresses.map((address) => ListTile(
            title: Text(address.fullName),
            subtitle: Text('${address.addressLine1}, ${address.city}'),
            onTap: () {
              state.setState(() => state._selectedAddress = address);
              Navigator.pop(context);
            },
          )),
          TextButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add New Address'),
            onPressed: () { Navigator.pop(context); _showAddAddressForm(context, state: state); },
          )
        ],
      ),
    ),
  );
}

void _showAddAddressForm(BuildContext context, {required _CheckoutScreenState state, ShippingAddress? addressToEdit}) {
  final isEditing = addressToEdit != null;
  if (isEditing) {
    state._nameController.text = addressToEdit.fullName;
    state._address1Controller.text = addressToEdit.addressLine1;
    state._address2Controller.text = addressToEdit.addressLine2 ?? '';
    state._phoneController.text = addressToEdit.phoneNumber ?? '';
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
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
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
            Row(children: [Expanded(child: _buildTextField(controller: state._cityController, label: 'City', hint: 'Lahore')), const SizedBox(width: 16), Expanded(child: _buildTextField(controller: state._stateController, label: 'State/Province', hint: 'Punjab'))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _buildTextField(controller: state._postalController, label: 'Postal Code', hint: '90210', keyboardType: TextInputType.number)), const SizedBox(width: 16), Expanded(child: _buildTextField(controller: state._countryController, label: 'Country', hint: 'Pakistan'))]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final newAddr = ShippingAddress(
                    fullName: state._nameController.text,
                    addressLine1: state._address1Controller.text,
                    addressLine2: state._address2Controller.text,
                    phoneNumber: state._phoneController.text,
                    city: state._cityController.text,
                    state: state._stateController.text,
                    postalCode: state._postalController.text,
                    country: state._countryController.text,
                  );
                  
                  bool success = await AddressService.addAddress(auth.userId!, newAddr);
                  if (success) {
                    await state._fetchAddresses();
                    state.setState(() => state._selectedAddress = newAddr);
                    Navigator.pop(context);
                  }
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
  showModalBottomSheet(context: context, builder: (bc) => Wrap(children: [ListTile(leading: const Icon(Icons.payments_outlined), title: const Text('Cash on Delivery'), onTap: () { state.setState(() => state._selectedPayment = state._availablePayments[0]); Navigator.pop(context); }), ListTile(leading: const Icon(Icons.credit_card_outlined), title: const Text('Credit/Debit Card'), onTap: () { Navigator.pop(context); _showCardSelector(context, state: state); })]));
}

void _showCardSelector(BuildContext context, {required _CheckoutScreenState state}) {
  final savedCards = state._availablePayments.where(state._isSavedCard).toList();
  showModalBottomSheet(context: context, builder: (bc) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Select Saved Card', style: Theme.of(context).textTheme.titleLarge), const Divider(), ...savedCards.map((card) => ListTile(title: Text(card.type), subtitle: Text(card.details), onTap: () { state.setState(() => state._selectedPayment = card); Navigator.pop(context); })), TextButton.icon(icon: const Icon(Icons.add_card), label: const Text('Add New Card'), onPressed: () { Navigator.pop(context); _showAddCardForm(context, state: state); })])));
}

void _showAddCardForm(BuildContext context, {required _CheckoutScreenState state}) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (bc) => Container(decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [Text('Add Card Details', style: Theme.of(context).textTheme.headlineSmall), const Divider(height: 32), _buildTextField(controller: state._cardNameController, label: 'Cardholder Name', hint: 'John Doe'), const SizedBox(height: 16), _buildTextField(controller: state._cardNumberController, label: 'Card Number', hint: 'XXXX XXXX XXXX XXXX', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberFormatter()]), const SizedBox(height: 16), Row(children: [Expanded(child: _buildTextField(controller: state._cardExpiryController, label: 'Expiry', hint: 'MM/YY', inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), CardExpiryFormatter()])), const SizedBox(width: 16), Expanded(child: _buildTextField(controller: state._cardCvvController, label: 'CVV', hint: '***', keyboardType: TextInputType.number, inputFormatters: [LengthLimitingTextInputFormatter(3)]))]), const SizedBox(height: 32), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { final last4 = state._cardNumberController.text.replaceAll(' ', ''); final newCard = PaymentMethod(type: 'Card', details: 'Visa ending in ${last4.substring(last4.length - 4)}'); state.setState(() { state._availablePayments.add(newCard); state._selectedPayment = newCard; }); Navigator.pop(context); }, child: const Text('SAVE CARD'))), const SizedBox(height: 16)]))));
}

Widget _buildTextField({required TextEditingController controller, required String label, String? hint, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: isDark ? Colors.grey[850] : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)));
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

class OrderSuccessDialog extends StatefulWidget {
  const OrderSuccessDialog({super.key});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 16),
              Text(
                "Order Placed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Thank you for shopping.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}