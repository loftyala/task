import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Box<String> _box;

  CartNotifier() : _box = HiveService.cartBox, super([]) {
    _loadFromHive();
  }

  CartNotifier.withBox(Box<String> box) : _box = box, super([]) {
    _loadFromHive();
  }

  void _loadFromHive() {
    try {
      final jsonStr = _box.get('cart_items');
      if (jsonStr == null) return;
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      state = decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = [];
    }
  }

  void _persistCart() {
    try {
      final encoded = jsonEncode(state.map((i) => i.toJson()).toList());
      _box.put('cart_items', encoded);
    } catch (_) {}
  }

  void addProduct(Product product) {
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
    _persistCart();
  }

  void removeProduct(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
    _persistCart();
  }

  void incrementQuantity(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
    _persistCart();
  }

  void decrementQuantity(String productId) {
    final index = state.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (state[index].quantity <= 1) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ];
    _persistCart();
  }

  void clearCart() {
    state = [];
    _persistCart();
  }

  double get totalPrice => state.fold(
        0,
        (sum, item) => sum + item.product.price * item.quantity,
      );

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  bool isInCart(String productId) =>
      state.any((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final index = state.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? state[index].quantity : 0;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.totalPrice;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.totalItems;
});
