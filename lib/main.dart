

import 'package:flutter/material.dart';
import 'dart:convert';

import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GarmentPulseApp());
}


class GarmentOrder {
  final int id;
  final String buyer;
  final String product;
  final int quantity;
  final String status;
  final DateTime? deliveryDate;

  // Quality Control fields
  final int? qualityRating;
  final String? inspectionRemarks;

  GarmentOrder({
    required this.id,
    required this.buyer,
    required this.product,
    required this.quantity,
    required this.status,
    this.deliveryDate,
    this.qualityRating,
    this.inspectionRemarks,
  });

  factory GarmentOrder.fromJson(Map<String, dynamic> json) {
    return GarmentOrder(
      id: json['id'],
      buyer: json['buyer'],
      product: json['product'],
      quantity: json['quantity'],
      status: json['status'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      qualityRating: json['qualityRating'] == null
          ? null
          : (json['qualityRating'] as num).toInt(),
      inspectionRemarks: json['inspectionRemarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyer,
      'product': product,
      'quantity': quantity,
      'status': status,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'qualityRating': qualityRating,
      'inspectionRemarks': inspectionRemarks,
    };
  }

  GarmentOrder copyWith({
    int? qualityRating,
    String? inspectionRemarks,
  }) {
    return GarmentOrder(
      id: id,
      buyer: buyer,
      product: product,
      quantity: quantity,
      status: status,
      deliveryDate: deliveryDate,
      qualityRating: qualityRating ?? this.qualityRating,
      inspectionRemarks: inspectionRemarks ?? this.inspectionRemarks,
    );
  }
}


class GarmentPulseApp extends StatefulWidget {
  const GarmentPulseApp({super.key});

  @override
  State<GarmentPulseApp> createState() => _GarmentPulseAppState();
}

class _GarmentPulseAppState extends State<GarmentPulseApp> {
  final List<GarmentOrder> orders = [];
  bool isLoggedIn = false;

  // Save all orders to local storage
  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();

    final ordersJson = orders
        .map((order) => order.toJson())
        .toList();

    await prefs.setString(
      'saved_orders',
      jsonEncode(ordersJson),
    );
  }

  // Load saved orders from local storage
  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString('saved_orders');

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);

      setState(() {
        orders.clear();

        orders.addAll(
          decodedData.map(
            (item) => GarmentOrder.fromJson(item),
          ),
        );
      });
    }
  }
    @override
  void initState() {
    super.initState();
    loadOrders();
  }

 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Garment Pulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF146C60),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
       home: isLoggedIn
    ? Builder(
        builder: (homeContext) => DashboardPage(
          orders: orders,
          onOpenOrders: () async {
            await Navigator.push(
              homeContext,
              MaterialPageRoute(
                builder: (context) => OrderManagementPage(
                  orders: orders,
                 
                   onAddOrder: (order) {
                         setState(() {
                         orders.add(order);
                          });

                          saveOrders();
                   },

                ),
              ),
            );
            setState(() {});
          },
          onOpenTracking: () {
            Navigator.push(
              homeContext,
              MaterialPageRoute(
                builder: (context) => ProductionTrackingPage(
                  orders: orders,
                ),
              ),
            );
          },
          onOpenQuality: () {
  Navigator.push(
    homeContext,
    MaterialPageRoute(
      builder: (context) => QualityControlPage(
        orders: orders,
        onSave: saveOrders,
      ),
    ),
  );
},
        ),
      )
    : LoginPage(
        onLoginSuccess: () {
          setState(() {
            isLoggedIn = true;
          });
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<GarmentOrder> orders;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenTracking;
  final VoidCallback onOpenQuality;

  const DashboardPage({
    super.key,
    required this.orders,
    required this.onOpenOrders,
    required this.onOpenTracking,
    required this.onOpenQuality,
  });

  @override
  Widget build(BuildContext context) {
    final inProduction =
        orders.where((o) => o.status == 'In Production').length;
    final completed =
        orders.where((o) => o.status == 'Completed').length;
    final qualityIssues =
        orders.where((o) => o.status == 'Quality Issue').length;
       final ratedOrders =
    orders.where((o) => o.qualityRating != null);

final inspectedOrders = ratedOrders.length;

final averageRating = inspectedOrders == 0
    ? 0.0
    : ratedOrders
            .map((o) => o.qualityRating!)
            .reduce((a, b) => a + b) /
        inspectedOrders; 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF146C60),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.factory_outlined, size: 30),
            SizedBox(width: 10),
            Text('Garment Pulse'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Production Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Monitor your garment production lifecycle.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 22),
          const Text(
            'Production Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OverviewCard(
                  title: 'Total Orders',
                  value: '${orders.length}',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF246BFD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                  title: 'In Production',
                  value: '$inProduction',
                  icon: Icons.precision_manufacturing_outlined,
                  color: const Color(0xFFDE8A18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OverviewCard(
                  title: 'Completed',
                  value: '$completed',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF16865B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                  title: 'Quality Issues',
                  value: '$qualityIssues',
                  icon: Icons.fact_check_outlined,
                  color: const Color(0xFFD74646),
                ),
              ),
            ],
          ),
                    const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OverviewCard(
                  title: 'Average Rating',
                  value: '${averageRating.toStringAsFixed(1)} / 5',
                  icon: Icons.star_rate_rounded,
                  color: const Color(0xFFE5A000),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                  title: 'Inspected Orders',
                  value: '$inspectedOrders',
                  icon: Icons.fact_check_outlined,
                  color: const Color(0xFF16865B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Management Modules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ModuleTile(
            icon: Icons.assignment_outlined,
            title: 'Production Tracking',
            subtitle: 'Track orders and production progress',
            onTap: onOpenTracking,
          ),
          ModuleTile(
  icon: Icons.verified_outlined,
  title: 'Quality Control',
  subtitle: 'Monitor inspections and quality issues',
  onTap: onOpenQuality,
),
          ModuleTile(
            icon: Icons.inventory_outlined,
            title: 'Order Management',
            subtitle: 'Organize garment production orders',
            onTap: onOpenOrders,
          ),
          const ModuleTile(
            icon: Icons.analytics_outlined,
            title: 'Reports & Analytics',
            subtitle: 'Review production performance',
          ),
        ],
      ),
    );
  }
}

class OverviewCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.delay = 0,
  });

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: widget.color, size: 28),
                const SizedBox(height: 14),
                Text(
                  widget.value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 

class ModuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ModuleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF146C60),
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// Separate Production Tracking page
class ProductionTrackingPage extends StatelessWidget {
  final List<GarmentOrder> orders;

  const ProductionTrackingPage({
    super.key,
    required this.orders,
  });

  double getProgress(String status) {
    switch (status) {
      case 'Completed':
        return 1.0;
      case 'Quality Issue':
        return 0.25;
      default:
        return 0.5;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF16865B);
      case 'Quality Issue':
        return const Color(0xFFD74646);
      default:
        return const Color(0xFFDE8A18);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Tracking'),
        backgroundColor: const Color(0xFF146C60),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Production Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Monitor the status of every garment order.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 36,
                    color: Color(0xFF146C60),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Tracked Orders'),
                        const SizedBox(height: 4),
                        Text(
                          '${orders.length}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 42,
                      color: Color(0xFF146C60),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No orders to track yet.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Open Order Management and add an order first.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ...orders.map((order) {
            final progress = getProgress(order.status);
            final color = getStatusColor(order.status);

            return Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.precision_manufacturing_outlined,
                          color: Color(0xFF146C60),
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.product,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('Buyer: ${order.buyer}'),
                    const SizedBox(height: 6),
                    Text('Quantity: ${order.quantity} pieces'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Current Status',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Progress',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                'Note: Progress percentages are demo estimates based on '
                'the selected status, not live factory measurements.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderManagementPage extends StatefulWidget {
  final List<GarmentOrder> orders;
  final ValueChanged<GarmentOrder> onAddOrder;

  const OrderManagementPage({
    super.key,
    required this.orders,
    required this.onAddOrder,
  });

  @override
  State<OrderManagementPage> createState() =>
      _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final buyerController = TextEditingController();
  final productController = TextEditingController();
  final quantityController = TextEditingController();

  String status = 'In Production';
  DateTime? deliveryDate;

  @override
  void dispose() {
    buyerController.dispose();
    productController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void addOrder() {
    final buyer = buyerController.text.trim();
    final product = productController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());

    if (buyer.isEmpty ||
        product.isEmpty ||
        quantity == null ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter buyer, product and a valid quantity.',
          ),
        ),
      );
      return;
    }

widget.onAddOrder(
  GarmentOrder(
    id: DateTime.now().millisecondsSinceEpoch,
    buyer: buyer,
    product: product,
    quantity: quantity,
    status: status,
    deliveryDate: deliveryDate,
  ),
);

    setState(() {});

    buyerController.clear();
    productController.clear();
    quantityController.clear();
    setState(() {
  deliveryDate = null;
});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order added successfully!'),
      ),
    );
  }
  Future<void> pickDeliveryDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: deliveryDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );

  if (pickedDate != null) {
    setState(() {
      deliveryDate = pickedDate;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: const Color(0xFF146C60),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Add New Order',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: buyerController,
            decoration: const InputDecoration(
              labelText: 'Buyer Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: productController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(
              labelText: 'Production Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'In Production',
                child: Text('In Production'),
              ),
              DropdownMenuItem(
                value: 'Completed',
                child: Text('Completed'),
              ),
              DropdownMenuItem(
                value: 'Quality Issue',
                child: Text('Quality Issue'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => status = value);
              }
            },
          ),
                    const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: pickDeliveryDate,
            icon: const Icon(Icons.calendar_month),
            label: Text(
              deliveryDate == null
                  ? 'Select Delivery Date'
                  : 'Delivery Date: ${deliveryDate!.day}/${deliveryDate!.month}/${deliveryDate!.year}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 12),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: addOrder,
              icon: const Icon(Icons.add),
              label: const Text('Add Order'),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Orders (${widget.orders.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No orders yet. Add your first order above.',
                ),
              ),
            ),
          ...widget.orders.map(
            (order) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF146C60),
                ),
                title: Text(order.product),
                subtitle: Text(
                     'Buyer: ${order.buyer}\n'
                     'Quantity: ${order.quantity} | '
                     'Status: ${order.status}\n'
                     'Delivery Date: ${order.deliveryDate == null ? 'Not set' : '${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}'}',
                    ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QualityControlPage extends StatefulWidget {
  final List<GarmentOrder> orders;
  final Future<void> Function() onSave;

  const QualityControlPage({
    super.key,
    required this.orders,
    required this.onSave,
  });

  @override
  State<QualityControlPage> createState() =>
      _QualityControlPageState();
}

class _QualityControlPageState
    extends State<QualityControlPage> {

  String getQualityStatus(int rating) {
    if (rating <= 2) return 'Needs Improvement';
    if (rating == 3) return 'Fair';
    if (rating == 4) return 'Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Control'),
        backgroundColor: const Color(0xFF146C60),
        foregroundColor: Colors.white,
      ),

      body: widget.orders.isEmpty
          ? const Center(
              child: Text('No orders available for inspection.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.orders.length,

              itemBuilder: (context, index) {
                final order = widget.orders[index];
                final rating = order.qualityRating ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          order.product,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text('Buyer: ${order.buyer}'),
                        Text('Order ID: ${order.id}'),

                        const Divider(height: 24),

                        const Text(
                          'Product Quality Rating',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: List.generate(5, (starIndex) {
                            final starNumber = starIndex + 1;

                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.orders[index] =
                                      order.copyWith(
                                    qualityRating: starNumber,
                                  );
                                });
                              },

                              icon: Icon(
                                starNumber <= rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                            );
                          }),
                        ),

                        Text(
                          rating == 0
                              ? 'Not rated yet'
                              : '$rating / 5 - ${getQualityStatus(rating)}',
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue:
                              order.inspectionRemarks ?? '',

                          decoration: const InputDecoration(
                            labelText: 'Inspection Remarks',
                            hintText: 'Write inspection comments...',
                            border: OutlineInputBorder(),
                          ),

                          maxLines: 3,

                          onChanged: (value) {
                            widget.orders[index] =
                                widget.orders[index].copyWith(
                              inspectionRemarks: value,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: rating == 0
                                ? null
                                : () async {
                                    await widget.onSave();

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Quality inspection saved successfully!',
                                        ),
                                      ),
                                    );
                                  },

                            icon: const Icon(Icons.save),
                            label: const Text('Save Inspection'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
