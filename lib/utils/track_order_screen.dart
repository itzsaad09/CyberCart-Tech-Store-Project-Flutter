import 'package:flutter/material.dart';
import 'package:cybercart/services/order_service.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  final String token;

  const TrackOrderScreen({super.key, required this.orderId, required this.token});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final List<Map<String, String>> orderSteps = [
    {"name": "Order Placed", "key": "order placed"},
    {"name": "Order Confirmed", "key": "order confirmed"},
    {"name": "Order Packed", "key": "order packed"},
    {"name": "Ready To Ship", "key": "ready to ship"},
    {"name": "Shipped", "key": "shipped"},
    {"name": "Out For Delivery", "key": "out for delivery"},
    {"name": "Delivered", "key": "delivered"},
    {"name": "Cancelled", "key": "cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId.substring(widget.orderId.length - 8).toUpperCase()}'),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: OrderService.fetchOrderById(widget.orderId, widget.token), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final order = snapshot.data!;
          final String currentStatus = order['status'].toString().toLowerCase();
          final bool isCancelled = currentStatus == 'cancelled';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, order, isDark),
                const SizedBox(height: 24),
                Text(
                  "Order Progress", 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStepper(context, order, currentStatus, isCancelled, isDark),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildAddressSection(context, order['address']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, dynamic> order, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow(context, "Total Amount", "Rs. ${order['amount']}", isDark),
            _summaryRow(context, "Status", order['status'], isDark, isStatus: true),
            _summaryRow(context, "Scheduled Delivery", "${order['deliveryDate'].toString().split('T')[0]}", isDark),
            _summaryRow(context, "Time Slot", "${order['deliveryTimeSlot']}", isDark),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, bool isDark, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isStatus ? Colors.blue : (isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context, Map<String, dynamic> order, String currentStatus, bool isCancelled, bool isDark) {
    int currentIndex = orderSteps.indexWhere((s) => s['key'] == currentStatus);
    List<dynamic> history = order['statusHistory'] ?? [];

    return Column(
      children: orderSteps.map((step) {
        int stepIndex = orderSteps.indexOf(step);
        
        if (isCancelled) {
          if (step['key'] != "order placed" && step['key'] != "cancelled") return const SizedBox.shrink();
        } else if (step['key'] == "cancelled") {
          return const SizedBox.shrink();
        }

        bool isCompleted = stepIndex <= currentIndex;
        var historyItem = history.firstWhere(
          (h) => h['status'].toString().toLowerCase() == step['key'], 
          orElse: () => null,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : (isDark ? Colors.grey[700] : Colors.grey[400]),
                  size: 24,
                ),
                if (stepIndex != orderSteps.length - 1 && !(isCancelled && step['key'] == 'cancelled'))
                  Container(
                    width: 2, 
                    height: 40, 
                    color: isCompleted ? Colors.green : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['name']!, 
                    style: TextStyle(
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    historyItem != null ? historyItem['timestamp'].toString().split('T')[0] : "Pending",
                    style: TextStyle(
                      fontSize: 13, 
                      color: isCompleted ? (isDark ? Colors.grey[400] : Colors.grey[600]) : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAddressSection(BuildContext context, Map<String, dynamic>? address) {
    if (address == null) return const Text("Address not available");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Address", 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
          ),
          child: Text(
            "${address['fullName']}\n${address['addressLine1']}\n${address['city']}, ${address['stateProvince']}",
            style: TextStyle(
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}