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
  String? _currentUserUID;

  CartProvider() {
    _init();
  }

  Future<void> _init() async {
    // prepare local database
    await CartDbHelper.init();
    _listenConnectivity();
    // react to auth changes to load/clear cart based on user
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserUID = user.uid;
        _loadCartForUser(user.uid);
      } else {
        _currentUserUID = null;
        _items.clear();
        notifyListeners();
      }
    });
  }

  Future<void> _loadCartForUser(String uid) async {
    _items.clear();
    
    // Try to load from Firebase first if online
    final online = await _isOnline();
    if (online) {
      await _loadFromFirebase(uid);
    } else {
      // Load from SQLite if offline
      await _loadLocalItems(uid);
    }
    notifyListeners();
  }

  Future<void> _loadFromFirebase(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .get();
      
      // clear local cache and repopulate to keep SQLite in sync
      await CartDbHelper.clearUserCart(uid);
      for (final doc in snapshot.docs) {
        final name = doc['productName'] as String;
        final price = (doc['price'] as num).toDouble();
        final units = doc['units'] as int;
        final image = doc['image'] as String? ?? '';
        _items[name] = CartItem(name: name, image: image, price: price, units: units);
        // store locally as synced cache
        await CartDbHelper.insertOrUpdate(uid, name, price, units, image: image, isSynced: 1);
      }
    } catch (e) {
      // If Firebase fails, fall back to SQLite
      await _loadLocalItems(uid);
    }
  }

  Future<void> _loadLocalItems(String uid) async {
    final rows = await CartDbHelper.getAllRows(uid);
    for (final row in rows) {
      final name = row['productName'] as String;
      final price = row['price'] as num;
      final units = row['units'] as int;
      if (units <= 0) continue; // deleted entry, ignore
      final image = row['image'] as String? ?? '';
      _items[name] = CartItem(name: name, image: image, price: price.toDouble(), units: units);
    }
  }

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (_currentUserUID == null) return;
      if (result != ConnectivityResult.none) {
        // when connection is restored, sync local modifications and refresh from firebase
        _syncUnsynced(_currentUserUID!);
        _loadCartForUser(_currentUserUID!);
      }
    });
  }

  Future<bool> _isOnline() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }

  Future<void> _syncUnsynced(String uid) async {
    final unsynced = await CartDbHelper.getUnsynced(uid);
    for (final row in unsynced) {
      final id = row['id'] as int;
      final name = row['productName'] as String;
      final price = (row['price'] as num).toDouble();
      final units = row['units'] as int;
      final ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .doc(name);
      if (units <= 0) {
        // this is a deletion request
        await ref.delete();
        // remove from local database entirely
        await CartDbHelper.deleteItem(uid, name);
      } else {
        // standard add/update
        await ref.set({
          'productName': name,
          'price': price,
          'units': units,
        });
        await CartDbHelper.markSynced(id);
      }
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
    final uid = _currentUserUID;
    if (uid == null) return;

    final price = parsePrice(priceString);
    if (_items.containsKey(name)) {
      _items[name]!.units += 1;
    } else {
      _items[name] = CartItem(name: name, image: image, price: price);
    }
    notifyListeners();
    // persist according to connectivity
    await _handleAddOrUpdate(uid, name, price, image, _items[name]!.units);
  }

  Future<void> addUnit(String name) async {
    final uid = _currentUserUID;
    if (uid == null || !_items.containsKey(name)) return;
    
    _items[name]!.units += 1;
    notifyListeners();
    await _handleAddOrUpdate(uid, name, _items[name]!.price, _items[name]!.image, _items[name]!.units);
  }

  Future<void> removeUnit(String name) async {
    final uid = _currentUserUID;
    if (uid == null || !_items.containsKey(name)) return;
    
    final item = _items[name]!;
    item.units -= 1;
    if (item.units <= 0) {
      _items.remove(name);
      await _handleRemoval(uid, name);
    } else {
      await _handleAddOrUpdate(uid, name, item.price, item.image, item.units);
    }
    notifyListeners();
  }

  Future<void> removeItem(String name) async {
    final uid = _currentUserUID;
    if (uid == null || !_items.containsKey(name)) return;
    
    _items.remove(name);
    notifyListeners();
    await _handleRemoval(uid, name);
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

  Future<void> _handleAddOrUpdate(String uid, String name, double price, String image, int units) async {
    final online = await _isOnline();
    if (online) {
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
      // update local cache so offline view is consistent
      await CartDbHelper.insertOrUpdate(uid, name, price, units, image: image, isSynced: 1);
    } else {
      // offline: persist locally with isSynced=0
      await CartDbHelper.insertOrUpdate(uid, name, price, units, image: image, isSynced: 0);
    }
  }

  Future<void> _handleRemoval(String uid, String name) async {
    final online = await _isOnline();
    if (online) {
      // remove from firestore only
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('cart')
          .doc(name)
          .delete();
      // also remove from local cache to avoid stale entries
      await CartDbHelper.deleteItem(uid, name);
    } else {
      // offline: remove from local db
      // mark deletion so that sync can process it
      await CartDbHelper.updateUnits(uid, name, 0, isSynced: 0);
    }
  }
}

