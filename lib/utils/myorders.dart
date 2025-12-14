import 'package:flutter/material.dart';

class Order {
  final String orderId;
  final String date;
  final double total;
  final String status;
  final int itemCount;

  const Order({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
    required this.itemCount,
  });
}

final List<Order> pendingOrders = [
  const Order(
    orderId: 'CC-004512',
    date: 'Nov 09, 2025',
    total: 125.99,
    status: 'Shipped',
    itemCount: 2,
  ),
  const Order(
    orderId: 'CC-004510',
    date: 'Nov 07, 2025',
    total: 45.00,
    status: 'Processing',
    itemCount: 1,
  ),
];

final List<Order> pastOrders = [
  const Order(
    orderId: 'CC-004505',
    date: 'Oct 25, 2025',
    total: 299.50,
    status: 'Delivered',
    itemCount: 4,
  ),
  const Order(
    orderId: 'CC-004498',
    date: 'Oct 15, 2025',
    total: 89.99,
    status: 'Delivered',
    itemCount: 1,
  ),
  const Order(
    orderId: 'CC-004481',
    date: 'Sep 30, 2025',
    total: 512.20,
    status: 'Cancelled',
    itemCount: 3,
  ),
];

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending', icon: Icon(Icons.access_time_filled)),
              Tab(text: 'Past Orders', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(orders: pendingOrders, isPending: true),
            _OrderList(orders: pastOrders, isPending: false),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool isPending;

  const _OrderList({required this.orders, required this.isPending});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending orders found.' : 'You have no past orders.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index]);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Shipped':
      case 'Processing':
        return Colors.orange.shade700;
      case 'Delivered':
        return Colors.green.shade600;
      case 'Cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing details for Order ${order.orderId}'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${order.orderId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.date,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.itemCount} Items',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // MODIFIED: Changed currency display from 'PKR Rs. ' to 'Rs. '
                  Text(
                    'Rs. ${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}