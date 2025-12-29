import 'package:flutter/material.dart';
import 'package:cybercart/services/order_service.dart';

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

  // Factory to create an Order from Backend JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['_id'],
      // Formatting the date from deliveryDate or statusHistory timestamp
      date: json['orderDate'].toString().split('T')[0], 
      total: (json['amount'] as num).toDouble(),
      status: json['status'],
      itemCount: (json['items'] as List).length,
    );
  }
}

class MyOrdersScreen extends StatelessWidget {
  final String userId; // Pass these from your Auth State
  final String token;

  const MyOrdersScreen({super.key, required this.userId, required this.token});

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
        body: FutureBuilder<List<Order>>(
          future: OrderService.fetchUserOrders(userId, token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            }

            final allOrders = snapshot.data!;
            
            // Filter orders based on status defined in your controller
            final pending = allOrders.where((o) => 
              o.status == 'Order Placed'  || o.status == 'Order Confirmed' || o.status == 'Order Packed'  || o.status == 'Ready To Ship' || o.status == 'Shipped' || o.status == 'Out For Delivery'
            ).toList();
            
            final past = allOrders.where((o) => 
              o.status == 'Delivered' || o.status == 'Cancelled'
            ).toList();

            return TabBarView(
              children: [
                _OrderList(orders: pending, isPending: true),
                _OrderList(orders: past, isPending: false),
              ],
            );
          },
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
              // FIX START: Use Expanded and Ellipsis to prevent overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order ID: ${order.orderId}',
                      overflow: TextOverflow.ellipsis, // Adds "..." if too long
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8), // Added small gap
                  Text(
                    order.date,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              // FIX END
              
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