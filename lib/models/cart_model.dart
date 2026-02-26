import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// local database helper
import '../services/cart_database.dart';

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

  CartProvider() {
    _init();
  }

  Future<void> _init() async {
    // prepare local database and load any existing rows
    await CartDbHelper.init();
    await _loadLocalItems();
    _listenConnectivity();
    // also react to auth changes so we can sync when user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _syncUnsynced();
      } else {
        // user signed out, clear in-memory cart
        _items.clear();
        notifyListeners();
      }
    });
  }

  Future<void> _loadLocalItems() async {
    final rows = await CartDbHelper.getAllRows();
    for (final row in rows) {
      final name = row['productName'] as String;
      final price = row['price'] as num;
      final units = row['units'] as int;
      final image = row['image'] as String? ?? '';
      _items[name] = CartItem(name: name, image: image, price: price.toDouble(), units: units);
    }
    notifyListeners();
  }

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncUnsynced();
      }
    });
  }

  Future<bool> _isOnline() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }

  Future<void> _syncUnsynced() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final unsynced = await CartDbHelper.getUnsynced();
    for (final row in unsynced) {
      final id = row['id'] as int;
      final name = row['productName'] as String;
      final price = (row['price'] as num).toDouble();
      final units = row['units'] as int;
      // push to firestore using doc id = product name to avoid duplicates
      final ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .doc(name);
      await ref.set({
        'productName': name,
        'price': price,
        'units': units,
      });
      await CartDbHelper.markSynced(id);
    }
  }

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

  Future<void> addItem({required String name, required String priceString, required String image}) async {
    final price = parsePrice(priceString);
    if (_items.containsKey(name)) {
      _items[name]!.units += 1;
    } else {
      _items[name] = CartItem(name: name, image: image, price: price);
    }
    notifyListeners();
    // persist according to connectivity
    await _handleAddOrUpdate(name, price, image, _items[name]!.units);
  }

  Future<void> addUnit(String name) async {
    if (_items.containsKey(name)) {
      _items[name]!.units += 1;
      notifyListeners();
      await _handleAddOrUpdate(name, _items[name]!.price, _items[name]!.image, _items[name]!.units);
    }
  }

  Future<void> removeUnit(String name) async {
    if (!_items.containsKey(name)) return;
    final item = _items[name]!;
    item.units -= 1;
    if (item.units <= 0) {
      _items.remove(name);
      await _handleRemoval(name);
    } else {
      await _handleAddOrUpdate(name, item.price, item.image, item.units);
    }
    notifyListeners();
  }

  Future<void> removeItem(String name) async {
    if (_items.containsKey(name)) {
      _items.remove(name);
      notifyListeners();
      await _handleRemoval(name);
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

  Future<void> _handleAddOrUpdate(String name, double price, String image, int units) async {
    final online = await _isOnline();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (online && uid != null) {
      // save/update on firestore only
      final ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .doc(name);
      await ref.set({
        'productName': name,
        'price': price,
        'units': units,
      });
      // do not touch local DB when online per requirements
    } else {
      // offline: persist locally with isSynced=0
      await CartDbHelper.insertOrUpdate(name, price, units, image: image, isSynced: 0);
    }
  }

  Future<void> _handleRemoval(String name) async {
    final online = await _isOnline();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (online && uid != null) {
      // remove from firestore only
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .doc(name)
          .delete();
    } else {
      // offline: remove from local db
      await CartDbHelper.deleteItem(name);
    }
  }
}
