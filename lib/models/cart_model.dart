import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String image;
  final double price; // price per unit
  int units;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    this.units = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {}; // keyed by product name

  static double parsePrice(String priceString) {
    try {
      final cleaned = priceString.replaceAll(',', '');
      final reg = RegExp(r"(\d+\.?\d*)");
      final match = reg.firstMatch(cleaned);
      if (match != null) {
        return double.parse(match.group(0)!);
      }
    } catch (_) {}
    return 0.0;
  }

  void addItem({required String name, required String priceString, required String image}) {
    final price = parsePrice(priceString);
    if (_items.containsKey(name)) {
      _items[name]!.units += 1;
    } else {
      _items[name] = CartItem(name: name, image: image, price: price);
    }
    notifyListeners();
  }

  void addUnit(String name) {
    if (_items.containsKey(name)) {
      _items[name]!.units += 1;
      notifyListeners();
    }
  }

  void removeUnit(String name) {
    if (!_items.containsKey(name)) return;
    final item = _items[name]!;
    item.units -= 1;
    if (item.units <= 0) {
      _items.remove(name);
    }
    notifyListeners();
  }

  void removeItem(String name) {
    if (_items.containsKey(name)) {
      _items.remove(name);
      notifyListeners();
    }
  }

  List<CartItem> get items => _items.values.toList();

  int get itemTypesCount => _items.length;

  double get total {
    double sum = 0.0;
    for (final it in _items.values) {
      sum += it.price * it.units;
    }
    return sum;
  }

  double get deliveryCharges => 250.0;

  double get subTotal => total + deliveryCharges;

  String formatRs(double value) => 'RS ${value.toStringAsFixed(2)}';
}
