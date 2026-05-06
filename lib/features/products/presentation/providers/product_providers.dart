import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_service.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';

final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(
    remote: ProductRemoteDatasource(),
    local: ProductLocalDatasource(HiveService.productsBox),
  );
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  ref.keepAlive();
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProducts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) {
      ref.read(isFromCacheProvider.notifier).state = repo.lastLoadedFromCache;
      return products;
    },
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final allProducts = ref.watch(productsProvider);

  if (query.trim().isEmpty) return allProducts;

  return allProducts.whenData((products) {
    final lower = query.toLowerCase();
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(lower) ||
              p.description.toLowerCase().contains(lower),
        )
        .toList();
  });
});

final productDetailProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProductById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});

final isFromCacheProvider = StateProvider<bool>((ref) => false);
