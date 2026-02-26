import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'categories_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'product_details_page.dart';
import '../models/cart_model.dart';
import '../widgets/notification_popup.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// HomePage - StatelessWidget, UI only
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // A small helper to build product cards
  Widget _buildProductCard(BuildContext context, String name, String price, String imageAsset) {
    return GestureDetector(
      onTap: () {
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 56, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Product name and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(price, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                // Add button -> add to cart (no navigation)
                GestureDetector(
                  onTap: () {
                    Provider.of<CartProvider>(context, listen: false).addItem(name: name, priceString: price, image: imageAsset);
                  },
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                    child: IconButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(name: name, priceString: price, image: imageAsset);
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productNames = ['Fresh Strawberry', 'Red Apple', 'Banana', 'Mango'];
    final productPrices = ['RS 1300/500g', 'RS 280/500g', 'RS 120/500g', 'RS 350/500g'];
    final productImages = [
      'assets/images/strawberry.png',
      'assets/images/red_apple.png',
      'assets/images/banana.png',
      'assets/images/mango.png',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: profile + name + notification
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage('assets/images/boy.png'),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Good Morning', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('H A Nimal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showNotificationPopup(context);
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  IconButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await FirebaseAuth.instance.signOut();

                        navigator.pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      } on FirebaseAuthException catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Sign out failed')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              // Search bar area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Search products', icon: Icon(Icons.search)),
                ),
              ),

              const SizedBox(height: 16),

              // Category navigation (horizontal)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(true, 'All'),
                    const SizedBox(width: 8),
                    // Groceries chip navigates to CategoriesPage when tapped
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoriesPage()),
                        );
                      },
                      child: _buildCategoryChip(false, 'Groceries'),
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryChip(false, 'Household'),
                    const SizedBox(width: 8),
                    _buildCategoryChip(false, 'Stationary'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Product grid (4 dummy products)
              // Wrap GridView with Expanded inside Column to size properly
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: List.generate(4, (index) {
                    return _buildProductCard(context, productNames[index], productPrices[index], productImages[index]);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black87),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesPage()),
                );
              },
              child: const Icon(Icons.list, color: Colors.grey),
            ),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: const Icon(Icons.shopping_cart, color: Colors.grey),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Category chip builder (static, no state)
  Widget _buildCategoryChip(bool selected, String label) {
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
