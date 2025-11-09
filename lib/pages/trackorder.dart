import 'package:flutter/material.dart';

class TrackingStep {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const TrackingStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}

List<TrackingStep> getTrackingSteps(String orderId) {
  if (orderId == 'CC-004512') {
    return const [
      TrackingStep(
        title: 'Order Placed',
        subtitle: 'Nov 07, 2025, 9:00 AM',
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Processing Order',
        subtitle: 'Nov 07, 2025, 11:30 AM',
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Shipped',
        subtitle: 'Nov 08, 2025, 3:00 PM',
        isCompleted: true,
      ),
      TrackingStep(
        title: 'In Transit - Local Hub',
        subtitle: 'Nov 09, 2025, 8:00 AM',
        isCompleted: false,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        subtitle: 'Estimated: Nov 09, 2025',
        isCompleted: false,
      ),
      TrackingStep(
        title: 'Delivered',
        subtitle: 'Signature required',
        isCompleted: false,
      ),
    ];
  } else if (orderId == 'CC-004510') {
    return const [
      TrackingStep(
        title: 'Order Placed',
        subtitle: 'Nov 05, 2025, 2:00 PM',
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Processing Order',
        subtitle: 'Nov 06, 2025, 9:00 AM',
        isCompleted: false,
      ),
      TrackingStep(
        title: 'Shipped',
        subtitle: 'Awaiting Pickup',
        isCompleted: false,
      ),
      TrackingStep(
        title: 'Delivered',
        subtitle: 'Expected in 3 days',
        isCompleted: false,
      ),
    ];
  } else {
    return const [
      TrackingStep(
        title: 'Order ID not found',
        subtitle: 'Please check the ID and try again.',
      ),
    ];
  }
}

class TrackOrder extends StatefulWidget {
  const TrackOrder({super.key});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final TextEditingController _orderIdController = TextEditingController();
  List<TrackingStep> _currentTrackingSteps = [];
  bool _isTracking = false;

  void _trackOrder() {
    final orderId = _orderIdController.text.trim().toUpperCase();

    if (orderId.isEmpty) {
      setState(() {
        _isTracking = false;
        _currentTrackingSteps = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an Order ID.')),
      );
      return;
    }

    setState(() {
      _currentTrackingSteps = getTrackingSteps(orderId);
      _isTracking = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Order ID:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderIdController,
                    decoration: InputDecoration(
                      hintText: 'e.g., CC-004512',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _trackOrder(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _trackOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Track'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (_isTracking)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking Status',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _TrackingTimeline(steps: _currentTrackingSteps),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text(
                    'Enter an order ID to view its current status.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const _TrackingTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        final Color stepColor = step.isCompleted
            ? Theme.of(context).primaryColor
            : Colors.grey.shade400;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stepColor,
                    border: Border.all(
                      color: step.isCompleted
                          ? stepColor
                          : Colors.grey.shade300,
                      width: 3,
                    ),
                  ),
                ),

                if (!isLast)
                  Container(
                    width: 4,
                    height: 80,
                    color: stepColor.withOpacity(0.5),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: step.isCompleted
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: step.isCompleted
                            ? Colors.blueGrey
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
