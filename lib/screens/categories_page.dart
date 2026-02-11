import 'package:flutter/material.dart';
import 'product_details_page.dart';
import 'profile_page.dart';

// CategoriesPage - StatelessWidget (UI only)
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  // Helper to build the product card used in horizontal lists
  Widget _productCard(BuildContext context, String name, String price) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailsPage when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: name,
              productPrice: price,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(child: Icon(Icons.image, size: 48, color: Colors.grey[400])),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fruits = [
      {'name': 'Fresh Grapes', 'price': 'RS 1630/500g'},
      {'name': 'Fresh Strawberry', 'price': 'RS 2650/kg'},
      {'name': 'Red Apple', 'price': 'RS 180/kg'},
    ];

    final vegetables = [
      {'name': 'Brinjal', 'price': 'RS 90/kg'},
      {'name': 'Leek', 'price': 'RS 120/kg'},
      {'name': 'Carrot', 'price': 'RS 140/kg'},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: search bar, avatar, notification
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: const TextField(
                        decoration: InputDecoration(border: InputBorder.none, hintText: 'Search products', icon: Icon(Icons.search)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Good Morning', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('H A Nimal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                ],
              ),

              const SizedBox(height: 16),

              // Category navigation (Groceries highlighted)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip(false, 'All'),
                    const SizedBox(width: 8),
                    _categoryChip(true, 'Groceries'),
                    const SizedBox(width: 8),
                    _categoryChip(false, 'Household'),
                    const SizedBox(width: 8),
                    _categoryChip(false, 'Stationary'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Fruits section (horizontal list)
              const Text('Fruits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fruits.length,
                  itemBuilder: (context, index) {
                    final item = fruits[index];
                    return _productCard(context, item['name']!, item['price']!);
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Vegetables section (horizontal list)
              const Text('Vegetables', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vegetables.length,
                  itemBuilder: (context, index) {
                    final item = vegetables[index];
                    return _productCard(context, item['name']!, item['price']!);
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Category chip builder
  Widget _categoryChip(bool selected, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.black87 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.black87 : Colors.grey.shade400),
      ),
      child: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }
}
