import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'delivery_details_page.dart';
import '../widgets/notification_popup.dart';
import '../models/cart_model.dart';

// CartPage - StatelessWidget, UI-only
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cart Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () { showNotificationPopup(context); }, icon: const Icon(Icons.notifications_none, color: Colors.black))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Cart items list
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(child: Text('Your cart is empty'))
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
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
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                  child: Image.asset(
                                    item.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 36, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('price: RS ${item.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600])),
                                      const SizedBox(height: 6),
                                      Text('Units = ${item.units}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => cart.addUnit(item.name),
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    ),
                                    IconButton(
                                      onPressed: () => cart.removeUnit(item.name),
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                    ),
                                    IconButton(
                                      onPressed: () => cart.removeItem(item.name),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // Summary section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('items :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${cart.itemTypesCount}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(cart.formatRs(cart.total)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Charges :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(cart.formatRs(cart.deliveryCharges)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sub Total :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(cart.formatRs(cart.subTotal)),
                ],
              ),

              const SizedBox(height: 18),

              // Confirm order button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: Colors.orange,
                ),
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DeliveryDetailsPage()),
                        );
                      },
                child: const Text('Confirm Order', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}