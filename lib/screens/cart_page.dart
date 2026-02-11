import 'package:flutter/material.dart';
import 'delivery_details_page.dart';

// CartPage - StatelessWidget, UI-only
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Widget _cartItem(String name, int qty, String date, String price) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, size: 36, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Quantity : $qty', style: TextStyle(color: Colors.grey[600])),
                Text('date: $date', style: TextStyle(color: Colors.grey[600])),
                Text('price: $price', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate back to previous screen (ProductDetailsPage)
            Navigator.pop(context);
          },
        ),
        title: const Text('Cart Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView(
                  children: [
                    _cartItem('Fresh Orange', 8, '02/03/2026', 'RS 3180'),
                    _cartItem('Brinjal', 5, '02/03/2026', 'RS 270'),
                    _cartItem('Fresh Grapes', 3, '02/03/2026', 'RS 1410'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Summary section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('items :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('4'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('RS 5140.00'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Delivery Charges :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('RS 250.00'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Sub Total :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('RS 5390.00'),
                ],
              ),

              const SizedBox(height: 18),

              // Confirm order button (dummy)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DeliveryDetailsPage()),
                  );
                },
                child: const Text('Confirm Order', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
