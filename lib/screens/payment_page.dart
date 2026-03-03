import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_success_page.dart';
import '../services/notification_service.dart';
import '../models/cart_model.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Payment icons using asset images
    Widget paymentIcons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Visa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(
            'assets/images/visa.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.credit_card, color: Colors.blue, size: 36),
          ),
        ),
        // Master
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(
            'assets/images/master.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.credit_card, color: Colors.red, size: 36),
          ),
        ),
        // Google Pay
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(
            'assets/images/google_pay.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_wallet, color: Colors.black, size: 36),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(1),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Enter your details to proceed",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  // Cardholder Name
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Cardholder Name",
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Card Number
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Card Number",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  // Expiration & CVC
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Card Expiration",
                            hintText: "MM/YY",
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "CVC",
                            hintText: "XXX",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Payment icons
                  paymentIcons,
                  const SizedBox(height: 18),
                  // Charge
                  Consumer<CartProvider>(builder: (context, cart, _) {
                    return Text(
                      "Charge :  ${cart.formatRs(cart.subTotal)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                  // Pay Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 63, 76, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // fire a notification immediately (only one will
                        // appear) then navigate to the success screen.
                        NotificationService.showPaymentSuccessNotification();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
                        );
                      },
                      child: const Text(
                        "Pay now",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
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