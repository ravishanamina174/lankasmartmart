import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy map placeholder
    Widget mapBox = Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Display location image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.asset(
              'assets/images/location.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Zoom controls (dummy)
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 8),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: const Icon(Icons.remove, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 16,
                  child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map area
            mapBox,
            const SizedBox(height: 32),
            // Order status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Order Packing",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Arriving in 1-2 hours",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}