import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final Box<String> _box;

  FavoritesNotifier() : _box = HiveService.favoritesBox, super({}) {
    _loadFromHive();
  }

  FavoritesNotifier.withBox(Box<String> box) : _box = box, super({}) {
    _loadFromHive();
  }

  void _loadFromHive() {
    try {
      final jsonStr = _box.get('favorite_ids');
      if (jsonStr == null) return;
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      state = decoded.cast<String>().toSet();
    } catch (_) {
      state = {};
    }
  }

  void _persist() {
    try {
      final encoded = jsonEncode(state.toList());
      _box.put('favorite_ids', encoded);
    } catch (_) {}
  }

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _persist();
  }

  bool isFavorite(String productId) => state.contains(productId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final ids = ref.watch(favoritesProvider);
  final allProducts = ref.watch(productsProvider);
  return allProducts.whenData(
    (products) => products.where((p) => ids.contains(p.id)).toList(),
  );
});

final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).length;
});
