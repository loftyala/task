import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract interface class IProductLocalDatasource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
}

final class ProductLocalDatasource implements IProductLocalDatasource {
  static const _cacheKey = 'products_data';
  final Box<String> _box;

  const ProductLocalDatasource(this._box);

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final jsonStr = _box.get(_cacheKey);
      if (jsonStr == null) throw const CacheException('No cached products');
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const CacheException('Failed to read cached products');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
      await _box.put(_cacheKey, encoded);
    } catch (e) {
      throw const CacheException('Failed to cache products');
    }
  }
}

abstract interface class IProductRemoteDatasource {
  Future<List<ProductModel>> getProducts();
}

final class ProductRemoteDatasource implements IProductRemoteDatasource {
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/products.json');
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const ServerException('Failed to load products');
    }
  }
}
