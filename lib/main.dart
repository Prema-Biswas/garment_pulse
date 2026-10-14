
import 'package:flutter/material.dart';

void main() {
  runApp(const GarmentPulseApp());
}

class GarmentOrder {
  final String buyer;
  final String product;
  final int quantity;
  final String status;

  GarmentOrder({
    required this.buyer,
    required this.product,
    required this.quantity,
    required this.status,
  });
}

class GarmentPulseApp extends StatefulWidget {
  const GarmentPulseApp({super.key});

  @override
  State<GarmentPulseApp> createState() => _GarmentPulseAppState();
}

class _GarmentPulseAppState extends State<GarmentPulseApp> {
  final List<GarmentOrder> orders = [];

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
      home: DashboardPage(
        orders: orders,
        onOpenOrders: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderManagementPage(
                orders: orders,
                onAddOrder: (order) {
                  setState(() {
                    orders.add(order);
                  });
                },
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<GarmentOrder> orders;
  final VoidCallback onOpenOrders;

  const DashboardPage({
    super.key,
    required this.orders,
    required this.onOpenOrders,
  });

  @override
  Widget build(BuildContext context) {
    final inProduction =
        orders.where((o) => o.status == 'In Production').length;
    final completed =
        orders.where((o) => o.status == 'Completed').length;
    final qualityIssues =
        orders.where((o) => o.status == 'Quality Issue').length;

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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Monitor your garment production lifecycle.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 22),
          const Text(
            'Production Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 26),
          const Text(
            'Management Modules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ModuleTile(
            icon: Icons.assignment_outlined,
            title: 'Production Tracking',
            subtitle: 'Track orders and production progress',
            onTap: onOpenOrders,
          ),
          const ModuleTile(
            icon: Icons.verified_outlined,
            title: 'Quality Control',
            subtitle: 'Monitor inspections and quality issues',
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

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
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

class OrderManagementPage extends StatefulWidget {
  final List<GarmentOrder> orders;
  final ValueChanged<GarmentOrder> onAddOrder;

  const OrderManagementPage({
    super.key,
    required this.orders,
    required this.onAddOrder,
  });

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final buyerController = TextEditingController();
  final productController = TextEditingController();
  final quantityController = TextEditingController();

  String status = 'In Production';

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

    if (buyer.isEmpty || product.isEmpty || quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter buyer, product and a valid quantity.'),
        ),
      );
      return;
    }

    widget.onAddOrder(
      GarmentOrder(
        buyer: buyer,
        product: product,
        quantity: quantity,
        status: status,
      ),
    );

    buyerController.clear();
    productController.clear();
    quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order added successfully!')),
    );
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            value: status,
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (widget.orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No orders yet. Add your first order above.'),
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
                  'Quantity: ${order.quantity} | Status: ${order.status}',
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
