import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // User info (dummy)
    const userName = "H A Nimal";
    const email = "nimalperera98@gmail.com";
    const mobile = "0775434991";
    const nic = "199845768567";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, size: 60, color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 18),
            // User Info Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Email ID", email),
                  const SizedBox(height: 8),
                  _infoRow("Mobile No", mobile),
                  const SizedBox(height: 8),
                  _infoRow("NIC", nic),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // About Us Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "About Us",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Lanka Smart Mart is your one-stop mobile shopping solution for groceries, household items, personal care products, and stationery. With branches in Maharagama, Gampaha, and Kandy, we bring trusted local shopping to your fingertips.\nEnjoy convenient ordering, quality products, and exciting offers like New Year promotions and weekend discounts — all in one smart app.",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  static Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}