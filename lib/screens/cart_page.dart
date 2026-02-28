import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'delivery_details_page.dart';
import '../widgets/notification_popup.dart';
import '../models/cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _online = false;
  late final StreamSubscription<ConnectivityResult> _connSub;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final nowOnline = result != ConnectivityResult.none;
      if (nowOnline != _online) {
        setState(() {
          _online = nowOnline;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final res = await Connectivity().checkConnectivity();
    setState(() {
      _online = res != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
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
          child: _buildCartContent(cart, user),
        ),
      ),
    );
  }

  Widget _buildCartContent(CartProvider cart, User? user) {
    if (_online && user != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          final items = docs.map((doc) {
            final name = doc['productName'] as String;
            final price = (doc['price'] as num).toDouble();
            final units = doc['units'] as int;
            // support legacy documents that stored 'image' instead of 'imagePath'
            String image = '';
            // safely cast doc data map
            final dataMap = doc.data() as Map<String, dynamic>?;
            if (dataMap != null) {
              if (dataMap.containsKey('imagePath')) {
                image = dataMap['imagePath'] as String? ?? '';
              } else if (dataMap.containsKey('image')) {
                image = dataMap['image'] as String? ?? '';
              }
            }
            return CartItem(name: name, imagePath: image, price: price, units: units);
          }).toList();
          final itemCount = items.length;
          double total = 0;
          for (var it in items) {
            total += it.price * it.units;
          }
          final delivery = cart.deliveryCharges;
          final subTotal = total + delivery;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
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
                              item.imagePath,
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
              _buildSummary(itemCount, total, delivery, subTotal, cart),
            ],
          );
        },
      );
    }
    final items = cart.items;

// 🔥 DEBUG: Print SQLite items
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print("========== SQLITE CART DATA ==========");
    for (var item in items) {
      print("✅Name: ${item.name}");
      print("Price: ${item.price}");
      print("Units: ${item.units}");
      print("Image: ${item.imagePath}");
      print("----------------------------------");
    }
  });

  final itemCount = items.length;
  final total = cart.total;
  final delivery = cart.deliveryCharges;
  final subTotal = cart.subTotal;

    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
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
                              item.imagePath,
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
        _buildSummary(itemCount, total, delivery, subTotal, cart),
      ],
    );
  }

  Widget _buildSummary(int itemCount, double total, double delivery, double subTotal, CartProvider cart) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('items :', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$itemCount'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total :', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cart.formatRs(total)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery Charges :', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cart.formatRs(delivery)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sub Total :', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cart.formatRs(subTotal)),
          ],
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: Colors.orange,
          ),
          onPressed: itemCount == 0
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DeliveryDetailsPage()),
                  );
                },
          child: const Text('Confirm Order', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }
}