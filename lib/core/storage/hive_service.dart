import 'package:hive_flutter/hive_flutter.dart';

abstract final class HiveService {
  static Box<String>? _productsBox;
  static Box<String>? _cartBox;
  static Box<String>? _favoritesBox;

  static Box<String> get productsBox => _productsBox!;
  static Box<String> get cartBox => _cartBox!;
  static Box<String> get favoritesBox => _favoritesBox!;

  static Future<void> init() async {
    await Hive.initFlutter();
    _productsBox = await Hive.openBox<String>('products_cache');
    _cartBox = await Hive.openBox<String>('cart_box');
    _favoritesBox = await Hive.openBox<String>('favorites_box');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
