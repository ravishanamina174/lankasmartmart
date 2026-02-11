import 'package:flutter/material.dart';
import 'cart_page.dart';

// ProductDetailsPage - StatelessWidget, UI only
class ProductDetailsPage extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productWeight;
  final String productDescription;

  const ProductDetailsPage({
    Key? key,
    this.productName = 'Fresh Strawberry',
    this.productPrice = 'RS 2650/kg',
    this.productWeight = '1 kg',
    this.productDescription = 'Carefully picked and skillfully packaged farm fresh produce. Images for illustration purposes only.',
  })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar area with back and cart navigation
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main product card
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(child: Icon(Icons.image, size: 120, color: Colors.grey[400])),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(productPrice, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                            child: IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Product name, price, weight, description
              Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              Text(productPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Weight: $productWeight', style: TextStyle(color: Colors.grey[600])),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(productDescription, style: TextStyle(color: Colors.grey[700])),

              const Spacer(),

              // Add to cart button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
